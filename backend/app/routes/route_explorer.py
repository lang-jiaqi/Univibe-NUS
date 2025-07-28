from flask import Blueprint, request, jsonify
from app.db import get_connection

route_explorer_bp = Blueprint('route_explorer', __name__)

@route_explorer_bp.route('/record_route', methods=['POST'])
def record_route():
    data = request.get_json()
    route_name = data.get('route_name')
    user_id = data.get('user_id')
    length = data.get('length')
    points = data.get('points')
    
    if not all([route_name, user_id, length, points]):
        return jsonify({'message': 'Missing route name, user id, length, or points'}), 400

    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute("SELECT COUNT(*) FROM routes")
    num_of_routes = cursor.fetchone()[0]
    if num_of_routes >= 30:
        cursor.execute("SELECT id FROM routes ORDER BY points ASC, id ASC LIMIT 1")
        route_to_delete = cursor.fetchone()[0]
        cursor.execute("DELETE FROM routes WHERE id = %s", (route_to_delete,))
        cursor.execute("DELETE FROM route_points WHERE route_id = %s", (route_to_delete,))
        connection.commit()

    route_sql = "INSERT INTO routes (name, user_id, length) VALUES (%s, %s, %s)"
    route_values = (route_name, user_id, length)
    cursor.execute(route_sql, route_values)
    connection.commit()

    route_id = cursor.lastrowid

    for point in points:
        point_sql = "INSERT INTO route_points (route_id, latitude, longitude) VALUES (%s, %s, %s)"
        point_values = (route_id, point['latitude'], point['longitude'])
        cursor.execute(point_sql, point_values)

    connection.commit()
    cursor.close()
    connection.close()

    return jsonify({'message': 'Route recorded successfully', 'route_id': route_id}), 200

@route_explorer_bp.route('/get_best_routes', methods=['POST'])
def get_best_routes():
    data = request.get_json() or {}
    rejected_ids = data.get('rejected_route_ids', [])  # optional list

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    if rejected_ids:
        # Create placeholders for SQL query
        placeholders = ','.join(['%s'] * len(rejected_ids))
        query = f"""
            SELECT id FROM routes 
            WHERE id NOT IN ({placeholders}) 
            ORDER BY points DESC, id ASC LIMIT 1
        """
        cursor.execute(query, rejected_ids)
    else:
        cursor.execute("SELECT id FROM routes ORDER BY points DESC, id ASC LIMIT 1")

    result = cursor.fetchone()
    if not result:
        return jsonify({'message': 'No more available routes'}), 404

    best_route_id = result['id']

    cursor.execute("SELECT latitude, longitude FROM route_points WHERE route_id = %s", (best_route_id,))
    points = cursor.fetchall()

    cursor.execute("SELECT id, name, user_id, length FROM routes WHERE id = %s", (best_route_id,))
    route_info = cursor.fetchone()
    route_info['path'] = points

    cursor.close()
    connection.close()

    return jsonify({
        'message': 'Next best route retrieved successfully',
        'route': route_info
    }), 200


@route_explorer_bp.route('/update_points', methods=['POST'])
def update_points():
    data = request.get_json()
    route_id = data.get('route_id')
    comment = data.get('comment')

    print(f"[DEBUG] Received route_id: {route_id}, comment: '{comment}'")

    rating_map = {
        'good': 1,
        'moderate': 0,
        'bad': -1
    }

    if comment not in rating_map:
        return jsonify({'error': 'Invalid comment'}), 400

    connection = get_connection()
    cursor = connection.cursor()

    # First, check if the route exists
    cursor.execute("SELECT points FROM routes WHERE id = %s", (route_id,))
    row = cursor.fetchone()
    
    if row is None:
        print("[ERROR] Route ID not found in database.")
        cursor.close()
        connection.close()
        return jsonify({'error': 'Route not found'}), 404

    current_points = row[0]
    new_points = current_points + rating_map[comment]

    cursor.execute("UPDATE routes SET points = %s WHERE id = %s", (new_points, route_id))
    connection.commit()
    cursor.close()
    connection.close()

    print(f"[DEBUG] Updated points: {current_points} -> {new_points}")

    return jsonify({'message': 'Points updated successfully', 'new_points': new_points}), 200

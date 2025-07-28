from flask import Blueprint, request, jsonify
from app.db import get_connection

connection_bp = Blueprint('connections', __name__)

@connection_bp.route('/add_connections', methods=['POST'])
def add_connections():
    data = request.get_json()
    user_id = data.get('user_id')
    target_id = data.get('target_id')
    connection = get_connection()
    cursor = connection.cursor()
    sql = "INSERT INTO connections (user_id, following_id) VALUES (%s, %s)"
    values = (user_id, target_id)
    cursor.execute(sql, values)
    connection.commit()
    cursor.close()
    connection.close()
    return jsonify({'message': 'connection successfully added'}), 200

@connection_bp.route('/find_following', methods=['GET'])
def find_following():
    user_id = request.args.get('user_id')
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)
    sql = """
        SELECT users.id AS user_id, users.username, users.email, users.character_image AS avatar
        FROM connections
        JOIN users ON connections.following_id = users.id
        WHERE connections.user_id = %s
    """
    values = (user_id,)
    cursor.execute(sql, values)
    followings = cursor.fetchall()
    cursor.close()
    connection.close()
    if len(followings) == 0:
        return jsonify({'message': 'no following found'}), 404
    return jsonify({
        'message': 'successfully connected',
        'followings': followings
    }), 200

@connection_bp.route('/remove_following', methods=['POST'])
def remove_following():
    data = request.get_json()
    user_id = data.get('user_id')
    target_id = data.get('target_id')
    connection = get_connection()
    cursor = connection.cursor()
    sql = "DELETE FROM connections WHERE user_id = %s AND following_id = %s"
    values = (user_id, target_id)
    cursor.execute(sql, values)
    connection.commit()
    cursor.close()
    connection.close()
    return jsonify({'message': 'connection successfully removed'}), 200

@connection_bp.route('/find_follower', methods=['GET'])
def find_follower():
    user_id = request.args.get('user_id')
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)
    sql = """
        SELECT users.id AS user_id, users.username, users.email, users.character_image AS avatar
        FROM connections
        JOIN users ON connections.user_id = users.id
        WHERE connections.following_id = %s
    """
    values = (user_id,)
    cursor.execute(sql, values)
    followers = cursor.fetchall()
    cursor.close()
    connection.close()
    if len(followers) == 0:
        return jsonify({'message': 'no followers'}), 200
    return jsonify({
        'message': 'successfully found all followers',
        'followers': followers
    }), 200

@connection_bp.route('/find_mutual', methods=['GET'])
def find_mutual():
    user_id = request.args.get('user_id')
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)
    sql = """
        SELECT u.id AS user_id, u.username, u.email, u.character_image AS avatar
        FROM connections c1
        JOIN connections c2 ON c1.following_id = c2.user_id AND c2.following_id = c1.user_id
        JOIN users u ON u.id = c1.following_id
        WHERE c1.user_id = %s
    """
    values = (user_id,)
    cursor.execute(sql, values)
    mutual = cursor.fetchall()
    cursor.close()
    connection.close()
    if len(mutual) == 0:
        return jsonify({
            'message': 'no mutual connections'
        }), 200
    return jsonify({
        'message': 'successfully found all mutual followers',
        'mutual': mutual
    }), 200

@connection_bp.route('/search', methods=['POST'])
def search():
    data = request.get_json()
    query = data.get('query', '')
    user_id = data.get('user_id')

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    sql = """
        SELECT id, username, email, character_image AS avatar FROM users
        WHERE (username LIKE %s OR email LIKE %s)
        AND id != %s
        LIMIT 20
    """
    like_query = f"%{query}%"
    values = (like_query, like_query, user_id)
    cursor.execute(sql, values)
    users = cursor.fetchall()

    results = []
    for user in users:
        check_sql = "SELECT 1 FROM connections WHERE user_id = %s AND following_id = %s"
        check_values = (user_id, user['id'])
        cursor.execute(check_sql, check_values)
        is_following = cursor.fetchone() is not None

        results.append({
            'user_id': user['id'],
            'username': user['username'],
            'email': user['email'],
            'avatar': user['avatar'],
            'is_following': is_following
        })

    cursor.close()
    connection.close()

    if not results:
        return jsonify({'message': 'no targets found', 'users': []}), 200

    return jsonify({'message': 'successfully found all targets', 'users': results}), 200

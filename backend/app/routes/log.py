from flask import Blueprint, jsonify, request
from app.db import get_connection

log_bp = Blueprint('log', __name__)

@log_bp.route('/coins', methods=['POST'])
def coins():
    data = request.get_json()
    user_id = data.get('user_id')
    coins_earned = data.get('coins_earned')

    connection = get_connection()
    cursor = connection.cursor()

    sql1 = "SELECT coins FROM users WHERE id = %s"
    values1 = (user_id,)
    cursor.execute(sql1, values1)
    coins = cursor.fetchone()
    if coins is None:
        cursor.close()
        connection.close()
        return jsonify({'message': 'User not found'}), 404
    coins = coins[0] + coins_earned

    sql2 = "UPDATE users SET coins = %s WHERE id = %s"
    values2 = (coins, user_id)
    cursor.execute(sql2, values2)
    connection.commit()
    cursor.close()
    connection.close()
    return jsonify({'message': 'coins updated successfully', 'coins': coins}), 200

@log_bp.route('/log_store', methods=['POST'])
def log_store():
    data = request.get_json()
    user_id = data.get('user_id')
    exercise = data.get('exercise')
    date = data.get('date')  # Should be ISO string, e.g., "2025-07-22T21:19:00.000Z"
    duration = data.get('duration')

    # Optional: You can check if fields exist, but not required if frontend always sends correctly
    if not all([user_id, exercise, date, duration]):
        return jsonify({'message': 'Missing fields'}), 400

    connection = get_connection()
    cursor = connection.cursor()
    sql = "INSERT INTO logs (user_id, exercise, date, duration) VALUES (%s, %s, %s, %s)"
    values = (user_id, exercise, date, duration)
    cursor.execute(sql, values)
    connection.commit()
    cursor.close()
    connection.close()
    return jsonify({'message': 'insert done'}), 200

@log_bp.route('/logs_post', methods=['GET'])
def logs_post():
    user_id = request.args.get('user_id')

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    sql = "SELECT exercise, date, duration FROM logs WHERE user_id = %s"
    values = (user_id,)
    cursor.execute(sql, values)
    logs = cursor.fetchall()
    cursor.close()
    connection.close()

    return jsonify({"logs": logs}), 200

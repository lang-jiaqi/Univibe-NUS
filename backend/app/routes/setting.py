from flask import Blueprint, request, jsonify
from app.db import get_connection

setting_bp = Blueprint('setting', __name__)

@setting_bp.route('/change_username', methods=['POST'])
def change_username():
    data = request.get_json()
    user_id = data.get('user_id')
    new_username = data.get('new_username')
    connection = get_connection()
    cursor = connection.cursor()
    sql = "UPDATE users SET username = %s WHERE id = %s"
    values = (new_username, user_id)
    cursor.execute(sql, values)
    connection.commit()
    cursor.close()
    connection.close()
    return jsonify({'message': 'successfully changed username'}), 200

@setting_bp.route('/change_password', methods=['POST'])
def change_password():
    data = request.get_json()
    user_id = data.get('user_id')
    old_password = data.get('old_password')
    new_password = data.get('new_password')
    connection = get_connection()
    cursor = connection.cursor()
    sql1 = "SELECT * FROM users WHERE id = %s AND password = %s"
    values1 = (user_id, old_password)
    cursor.execute(sql1, values1)
    safety_check = cursor.fetchone()
    if safety_check is None:
        cursor.close()
        connection.close()
        return jsonify({'message': 'wrong old password'}), 404
    sql2 = "UPDATE users SET password = %s WHERE id = %s"
    values2 = (new_password, user_id)
    cursor.execute(sql2, values2)
    connection.commit()
    cursor.close()
    connection.close()
    return jsonify({'message': 'successfully changed password'}), 200

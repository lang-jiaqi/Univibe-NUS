from flask import Blueprint, request, jsonify
from app.db import get_connection

login_bp = Blueprint('login', __name__)

@login_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    email = data.get('email')

    if username is None or password is None or email is None:
        return jsonify({'message': 'Missing username, password, or email'}), 400

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    sql = "SELECT id, character_image FROM users WHERE username = %s AND password = %s AND email = %s"
    values = (username, password, email)
    cursor.execute(sql, values)
    result = cursor.fetchone()

    cursor.close()
    connection.close()

    if result is None:
        return jsonify({'message': 'Invalid username, password, or email'}), 401
    else:
        return jsonify({
            'message': 'Login success',
            'user_id': result['id'],
            'character_image': result['character_image']
        }), 200

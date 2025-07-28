from flask import Blueprint, request, jsonify
from app.db import get_connection

register_bp = Blueprint('register', __name__)

@register_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    email = data.get('email')

    if username is None or password is None or email is None:
        return jsonify({'message': 'Missing username, email or password'}), 400

    try:
        connection = get_connection()
        cursor = connection.cursor()
        sql = 'INSERT INTO users (username, password, email) VALUES (%s, %s, %s)'
        values = (username, password, email)
        cursor.execute(sql, values)
        connection.commit()
        new_user_id = cursor.lastrowid
    except Exception as e:
        if "Duplicate entry" in str(e):
            return jsonify({'message': 'Username or email already exists'}), 409
        return jsonify({'message': 'Internal server error'}), 500
    finally:
        cursor.close()
        connection.close()

    return jsonify({'message': 'Registration success', 'user_id': new_user_id}), 201


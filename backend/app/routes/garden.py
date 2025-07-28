from flask import Blueprint, request, jsonify
from app.db import get_connection

garden_bp = Blueprint('garden', __name__)

@garden_bp.route('/garden_receive', methods=['POST'])
def garden_receive():
    data = request.get_json()
    user_id = data.get('user_id')
    image = data.get('image')
    x = data.get('x')
    y = data.get('y')

    connection = get_connection()
    cursor = connection.cursor()

    sql1 = "INSERT INTO garden_plants (user_id,image,x,y) VALUES (%s, %s, %s, %s)"
    values1 = (user_id, image, x, y)
    sql2 = "UPDATE users SET coins = coins - 60 WHERE id = %s"
    values2 = (user_id,)
    cursor.execute(sql1, values1)
    cursor.execute(sql2, values2)

    connection.commit()
    cursor.close()
    connection.close()
    return jsonify({'message': 'insert done successfully'}), 200

@garden_bp.route('/garden_send', methods=['GET'])
def garden_send():
    user_id = request.args.get('user_id')

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    sql = "SELECT image, x, y FROM garden_plants WHERE user_id = %s"
    values = (user_id,)
    cursor.execute(sql, values)
    plants = cursor.fetchall()
    cursor.close()
    connection.close()
    return jsonify({'message': 'load successfully', 'plants': plants}), 200

@garden_bp.route('/garden_get_coins', methods=['GET'])
def garden_get_coins():
    user_id = request.args.get('user_id')

    connection = get_connection()
    cursor = connection.cursor()
    sql = "SELECT coins FROM users WHERE id = %s"
    values = (user_id,)
    cursor.execute(sql, values)
    coins = cursor.fetchone()[0]
    cursor.close()
    connection.close()
    return jsonify({'message': "get coins successfully", 'coins': coins}), 200


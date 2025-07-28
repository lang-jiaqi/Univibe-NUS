from flask import Blueprint, request, jsonify
from app.db import get_connection

character_bp = Blueprint('character', __name__)
@character_bp.route('/character_store', methods=['POST'])
def character_store():
    data = request.get_json()
    user_id = data.get('user_id')
    image = data.get('image')

    connection = get_connection()
    cursor = connection.cursor()
    sql = "UPDATE users SET character_image = %s WHERE id = %s"
    values = (image, user_id)
    cursor.execute(sql, values)
    connection.commit()
    cursor.close()
    connection.close()
    return jsonify({'message': 'character set successfully updated'}), 200

@character_bp.route('/character_send', methods=['GET'])
def character_send():
    user_id = request.args.get('user_id')

    connection = get_connection()
    cursor = connection.cursor()
    sql = "SELECT character_image FROM users WHERE id = %s"
    values = (user_id,)
    cursor.execute(sql, values)
    character_image = cursor.fetchone()[0]
    if character_image is None:
        return jsonify({'message': 'character image not found'}), 404
    return jsonify({
        'message': 'character image sent successfully',
        'character_image': character_image
    }), 200
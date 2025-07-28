from flask import Blueprint, request, jsonify
from app.db import get_connection

my_post_bp = Blueprint('my_post', __name__)
@my_post_bp.route('/send_my_posts', methods=['GET'])
def send_my_posts():
    user_id = request.args.get('user_id')
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)
    sql = """
    SELECT posts.*, users.username, users.character_image
    FROM posts
    JOIN users ON posts.user_id = users.id
    WHERE posts.user_id = %s
    ORDER BY posts.timestamp DESC
    """

    cursor.execute(sql, (user_id,))
    posts = cursor.fetchall()

    for post in posts:
        post_id = post['id']

        cursor.execute("SELECT COUNT(*) AS like_count FROM likes WHERE post_id = %s", (post_id,))
        post['like_count'] = cursor.fetchone()['like_count']

        cursor.execute("SELECT COUNT(*) AS comment_count FROM comments WHERE post_id = %s", (post_id,))
        post['comment_count'] = cursor.fetchone()['comment_count']
    
    cursor.close()
    connection.close()

    return jsonify({
        'message': 'posts successfully sent',
        'posts': posts,
    }), 200
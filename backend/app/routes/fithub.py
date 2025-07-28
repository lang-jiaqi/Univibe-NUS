from flask import Blueprint, request, jsonify
from app.db import get_connection
import mysql.connector

fithub_bp = Blueprint('fithub', __name__)

@fithub_bp.route('/receive_post', methods=['POST'])
def receive_post():
    data = request.get_json()
    user_id = data.get('user_id')
    title = data.get('title')
    content = data.get('content')
    connection = get_connection()
    cursor = connection.cursor()
    sql = "INSERT INTO posts(user_id, title, content) VALUES(%s, %s, %s)"
    values = (user_id, title, content)
    cursor.execute(sql, values)
    connection.commit()
    cursor.close()
    connection.close()
    return jsonify({'message': 'post received'}), 200

@fithub_bp.route('/send_posts', methods=['GET'])
def send_posts():
    page = request.args.get('page', default=1, type=int)
    per_page = 10
    offset = (page - 1) * per_page

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    sql_posts = """
        SELECT posts.*, users.username, users.character_image
        FROM posts
        JOIN users ON posts.user_id = users.id
        ORDER BY posts.timestamp DESC
        LIMIT %s OFFSET %s
    """
    cursor.execute(sql_posts, (per_page, offset))
    posts = cursor.fetchall()

    # Add like_count and comment_count to each post
    for post in posts:
        post_id = post['id']

        cursor.execute("SELECT COUNT(*) AS like_count FROM likes WHERE post_id = %s", (post_id,))
        post['like_count'] = cursor.fetchone()['like_count']

        cursor.execute("SELECT COUNT(*) AS comment_count FROM comments WHERE post_id = %s", (post_id,))
        post['comment_count'] = cursor.fetchone()['comment_count']

    # Total number of posts
    cursor.execute("SELECT COUNT(*) AS total FROM posts")
    total = cursor.fetchone()['total']
    total_pages = (total + per_page - 1) // per_page  # ceiling division

    cursor.close()
    connection.close()

    return jsonify({
        'message': 'posts successfully sent',
        'posts': posts,
        'total_posts': total,
        'total_pages': total_pages,
        'current_page': page
    }), 200

@fithub_bp.route('/receive_comment', methods=['POST'])
def receive_comment():
    data = request.get_json()
    post_id = data.get('post_id')
    user_id = data.get('user_id')
    content = data.get('content')
    connection = get_connection()
    cursor = connection.cursor()
    sql = "INSERT INTO comments(post_id, user_id, content) VALUES(%s, %s, %s)"
    values = (post_id, user_id, content)
    cursor.execute(sql, values)
    connection.commit()
    cursor.close()
    connection.close()
    return jsonify({'message': 'comment received'}), 200

@fithub_bp.route('/send_comments', methods=['GET'])
def send_comments():
    post_id = request.args.get('post_id', type=int)
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    sql = """
        SELECT c.content, c.user_id, u.username, u.character_image
        FROM comments c
        JOIN users u ON c.user_id = u.id
        WHERE c.post_id = %s
        ORDER BY c.timestamp ASC
    """
    values = (post_id,)
    cursor.execute(sql, values)
    comments = cursor.fetchall()

    cursor.close()
    connection.close()

    return jsonify({'message': 'comments successfully sent', 'comments': comments}), 200


@fithub_bp.route('/delete_comment', methods=['POST'])
def delete_comment():
    data = request.get_json()
    post_id = data.get('post_id')
    comment_id = data.get('comment_id')
    connection = get_connection()
    cursor = connection.cursor()
    sql = "DELETE FROM comments WHERE post_id = %s AND id = %s"
    values = (post_id, comment_id)
    cursor.execute(sql, values)
    connection.commit()
    cursor.close()
    connection.close()
    return jsonify({'message': 'comment deleted'}), 200

@fithub_bp.route('/receive_like', methods=['POST'])
def receive_like():
    data = request.get_json()
    post_id = data.get('post_id')
    user_id = data.get('user_id')
    connection = get_connection()
    cursor = connection.cursor()
    sql = "INSERT INTO likes(post_id, user_id) VALUES(%s, %s)"
    values = (post_id, user_id)
    try:
        cursor.execute(sql, values)
        connection.commit()
    except mysql.connector.IntegrityError:
        cursor.close()
        connection.close()
        return jsonify({'message': 'Already liked'}), 409
    cursor.close()
    connection.close()
    return jsonify({'message': 'like received'}), 200

@fithub_bp.route('/send_likes', methods=['GET'])
def send_likes():
    post_id = request.args.get('post_id', type=int)
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)
    sql = "SELECT * FROM likes WHERE post_id = %s"
    values = (post_id,)
    cursor.execute(sql, values)
    likes = cursor.fetchall()
    cursor.close()
    connection.close()
    return jsonify({'message': 'likes successfully sent', 'likes': likes}), 200

@fithub_bp.route('/delete_like', methods=['POST'])
def delete_like():
    data = request.get_json()
    post_id = data.get('post_id')
    user_id = data.get('user_id')
    connection = get_connection()
    cursor = connection.cursor()
    sql = "DELETE FROM likes WHERE post_id = %s AND user_id = %s"
    values = (post_id, user_id)
    cursor.execute(sql, values)
    connection.commit()
    cursor.close()
    connection.close()
    return jsonify({'message': 'like deleted'}), 200

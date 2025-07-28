import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;

import 'global.dart' as global;

String getBaseUrl() {
  if (Platform.isIOS || Platform.isMacOS) {
    return 'http://127.0.0.1:5000';
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2:5000';
  } else {
    return 'http://127.0.0.1:5000';
  }
}

class PostDetailPage extends StatefulWidget {
  final int postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  Map post = {};
  List comments = [];
  int likeCount = 0;
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPostData();
  }

  Future<void> fetchPostData() async {
    final postRes = await http.get(
      Uri.parse('${getBaseUrl()}/send_posts?page=1'),
    );
    if (postRes.statusCode == 200) {
      final data = jsonDecode(postRes.body);
      final found = data['posts'].firstWhere(
        (p) => p['id'] == widget.postId,
        orElse: () => {},
      );
      if (found.isNotEmpty) {
        setState(() {
          post = found;
          likeCount = found['like_count'];
        });
      }
    }

    final commentRes = await http.get(
      Uri.parse('${getBaseUrl()}/send_comments?post_id=${widget.postId}'),
    );
    if (commentRes.statusCode == 200) {
      final data = jsonDecode(commentRes.body);
      setState(() {
        comments = data['comments'];
      });
    }
  }

  Future<void> sendComment() async {
    final content = commentController.text.trim();
    if (content.isEmpty) return;

    final res = await http.post(
      Uri.parse('${getBaseUrl()}/receive_comment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'post_id': widget.postId,
        'user_id': global.userId,
        'content': content,
      }),
    );

    if (res.statusCode == 200) {
      commentController.clear();
      fetchPostData();
    }
  }

  Future<void> likePost() async {
    final res = await http.post(
      Uri.parse('${getBaseUrl()}/receive_like'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'post_id': widget.postId, 'user_id': global.userId}),
    );

    if (res.statusCode == 200 || res.statusCode == 409) {
      fetchPostData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (post.isEmpty) {
      return Scaffold(
        backgroundColor: Color.fromARGB(255, 186, 245, 163),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 195, 240, 239),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 135, 216, 238),
        title: Text(
          'Post Detail',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                (post['character_image'] != null &&
                        post['character_image'].toString().isNotEmpty)
                    ? CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/virtual_characters/${post['character_image']}',
                        ),
                      )
                    : CircleAvatar(child: Icon(Icons.person)),
                SizedBox(width: 12),

                Text(
                  post['username'] ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
                Spacer(),

                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: likePost,
                ),
                Text('$likeCount'),
              ],
            ),
            SizedBox(height: 12),

            Text(
              post['title'] ?? '',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post['content'] ?? ''),
                    SizedBox(height: 24),

                    Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),

                    ...comments.map(
                      (c) => ListTile(
                        leading:
                            (c['character_image'] != null &&
                                c['character_image'].toString().isNotEmpty)
                            ? CircleAvatar(
                                backgroundImage: AssetImage(
                                  'assets/virtual_characters/${c['character_image']}',
                                ),
                              )
                            : CircleAvatar(child: Icon(Icons.person)),
                        title: Text(c['content'] ?? ''),
                        subtitle: Text(c['username'] ?? 'Unknown User'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),

                ElevatedButton(
                  onPressed: sendComment,
                  child: Text(
                    'Send',
                    style: TextStyle(fontFamily: 'PlayfairDisplay'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

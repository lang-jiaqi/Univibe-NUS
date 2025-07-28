import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'global.dart' as global;

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  List<dynamic> _posts = [];

  @override
  void initState() {
    super.initState();
    fetchMyPosts();
  }

  Future<void> fetchMyPosts() async {
    final url = Uri.parse(
      'http://127.0.0.1:5000/send_my_posts?user_id=${global.userId}',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          _posts = jsonData['posts'];
        });
      } else {
        print('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 194, 224, 238),
      appBar: AppBar(
        title: Text(
          'My Posts',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 123, 88, 168),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color.fromARGB(255, 123, 88, 168)),
      ),
      body: _posts.isEmpty
          ? Center(child: Text('You haven’t posted anything yet.'))
          : ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      post['content'],
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'PlayfairDisplay',
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.redAccent, size: 16),
                        SizedBox(width: 4),

                        Text(post['like_count'].toString()),
                        SizedBox(width: 16),

                        Icon(Icons.comment, size: 16, color: Colors.grey),
                        SizedBox(width: 4),

                        Text(post['comment_count'].toString()),
                      ],
                    ),
                    trailing: TextButton(
                      child: Text("View Details"),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/fit_hub_detail',
                          arguments: post['id'],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

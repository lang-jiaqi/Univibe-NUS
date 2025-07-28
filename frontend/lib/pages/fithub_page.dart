import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:univibe/pages/uni_vibe_bar.dart';
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

class FitHubPage extends StatefulWidget {
  const FitHubPage({super.key});

  @override
  State<FitHubPage> createState() => _FitHubPageState();
}

class _FitHubPageState extends State<FitHubPage> {
  int currentPage = 1;
  int totalPages = 1;
  List posts = [];

  @override
  void initState() {
    super.initState();
    fetchPosts(currentPage);
  }

  Future<void> fetchPosts(int page) async {
    final uri = Uri.parse('${getBaseUrl()}/send_posts?page=$page');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        posts = data['posts'];
        totalPages = data['total_pages'] ?? 1;
        currentPage = data['current_page'];
      });
    }
  }

  Widget buildPaginationBar() {
    final displayPages = totalPages == 0 ? 1 : totalPages;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(displayPages, (index) {
        final pageNum = index + 1;
        return TextButton(
          onPressed: () {
            fetchPosts(pageNum);
          },
          child: Text(
            '$pageNum',
            style: TextStyle(
              fontWeight: pageNum == currentPage
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 223, 240, 249),
      appBar: UniVibeBar(title: 'FitHub', coins: global.coins, showBack: true),
      body: Column(
        children: [
          Expanded(
            child: posts.isEmpty
                ? Center(child: Text('No posts yet'))
                : ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                const Color.fromARGB(255, 115, 184, 233),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            leading:
                                (post['character_image'] != null &&
                                    post['character_image']
                                        .toString()
                                        .isNotEmpty)
                                ? CircleAvatar(
                                    backgroundImage: AssetImage(
                                      'assets/virtual_characters/${post['character_image']}',
                                    ),
                                  )
                                : CircleAvatar(child: Icon(Icons.person)),
                            title: Text(post['title'] ?? ''),
                            subtitle: Text(post['username'] ?? ''),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/fit_hub_detail',
                                  arguments: post['id'],
                                );
                              },
                              child: Text('View Detail'),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          buildPaginationBar(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_post');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

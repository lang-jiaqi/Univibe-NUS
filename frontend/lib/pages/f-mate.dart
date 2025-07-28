import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'global.dart' as global;

String getBaseUrl() {
  const String macWifiIp = 'http://10.34.177.99:5000'; // CHANGE THIS if needed!
  if (Platform.isIOS || Platform.isMacOS) {
    return 'http://127.0.0.1:5000';
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2:5000';
  } else {
    return macWifiIp;
  }
}

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int currentTab = 0;

  final userId = global.userId;

  List<Map<String, dynamic>> mutuals = [];
  List<Map<String, dynamic>> followers = [];
  List<Map<String, dynamic>> following = [];
  List<Map<String, dynamic>> searchResults = [];

  int mutualPage = 1;
  int followerPage = 1;
  int followingPage = 1;
  String searchQuery = '';

  final int pageSize = 10;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        currentTab = _tabController.index;
      });
    });
    loadMutuals();
    loadFollowers();
    loadFollowing();
  }

  Future<void> loadMutuals() async {
    setState(() => isLoading = true);
    final url = Uri.parse('${getBaseUrl()}/find_mutual?user_id=$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      mutuals =
          (json['mutual'] as List?)?.map((row) {
            return {
              'user_id': row['user_id'],
              'username': row['username'],
              'email': row['email'],
              'avatar': row['avatar'] ?? '', // <-- avatar support!
            };
          }).toList() ??
          [];
      setState(() => isLoading = false);
    } else {
      setState(() {
        mutuals = [];
        isLoading = false;
      });
    }
  }

  Future<void> loadFollowers() async {
    setState(() => isLoading = true);
    final url = Uri.parse('${getBaseUrl()}/find_follower?user_id=$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      followers =
          (json['followers'] as List?)?.map((row) {
            return {
              'user_id': row['user_id'],
              'username': row['username'],
              'email': row['email'],
              'avatar': row['avatar'] ?? '',
            };
          }).toList() ??
          [];
      setState(() => isLoading = false);
    } else {
      setState(() {
        followers = [];
        isLoading = false;
      });
    }
  }

  Future<void> loadFollowing() async {
    setState(() => isLoading = true);
    final url = Uri.parse('${getBaseUrl()}/find_following?user_id=$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      following =
          (json['followings'] as List?)?.map((row) {
            return {
              'user_id': row['user_id'],
              'username': row['username'],
              'email': row['email'],
              'avatar': row['avatar'] ?? '',
            };
          }).toList() ??
          [];
      setState(() => isLoading = false);
    } else {
      setState(() {
        following = [];
        isLoading = false;
      });
    }
  }

  Future<void> doSearch(String query) async {
    setState(() {
      isLoading = true;
      searchQuery = query;
    });
    final url = Uri.parse('${getBaseUrl()}/search');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'query': query}),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      searchResults =
          (json['users'] as List?)?.map((row) {
            return {
              'user_id': row['user_id'],
              'username': row['username'],
              'email': row['email'],
              'avatar': row['avatar'] ?? '',
              'is_following': row['is_following'] ?? false,
            };
          }).toList() ??
          [];
      setState(() => isLoading = false);
    } else {
      setState(() {
        searchResults = [];
        isLoading = false;
      });
    }
  }

  Future<void> followUser(int targetId) async {
    final url = Uri.parse('${getBaseUrl()}/add_connections');
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'target_id': targetId}),
    );
    await loadFollowers();
    await loadFollowing();
    await loadMutuals();
    await doSearch(searchQuery);
  }

  Future<void> unfollowUser(int targetId) async {
    final url = Uri.parse('${getBaseUrl()}/remove_following');
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'target_id': targetId}),
    );
    await loadFollowing();
    await loadMutuals();
    await doSearch(searchQuery);
  }

  Widget buildUserTile(
    Map<String, dynamic> user, {
    String action = '',
    VoidCallback? onAction,
    bool isFollowing = false,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: ListTile(
        leading:
            (user['avatar'] != null && user['avatar'].toString().isNotEmpty)
            ? CircleAvatar(
                backgroundImage: AssetImage(
                  'assets/virtual_characters/${user['avatar']}',
                ),
              )
            : const CircleAvatar(child: Icon(Icons.person)),
        title: Text(
          user['username'] ?? 'Username',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: user['email'] != null ? Text(user['email']) : null,
        trailing: action.isNotEmpty
            ? (isFollowing
                  ? ElevatedButton.icon(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[200],
                        foregroundColor: Colors.green[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: Icon(Icons.check),
                      label: Text("Following"),
                    )
                  : ElevatedButton(
                      onPressed: onAction,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(action),
                    ))
            : null,
      ),
    );
  }

  Widget buildList(
    List<Map<String, dynamic>> users, {
    String action = '',
    void Function(int)? onAction,
    bool searchTab = false,
  }) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (users.isEmpty) {
      return Center(child: Text('No users found'));
    }
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, i) => buildUserTile(
        users[i],
        action: action,
        isFollowing: searchTab ? users[i]['is_following'] == true : false,
        onAction: onAction != null ? () => onAction(i) : null,
      ),
    );
  }

  Widget buildPagination(int page, VoidCallback onPrev, VoidCallback onNext) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: page > 1 ? onPrev : null,
          icon: Icon(Icons.chevron_left),
        ),
        Text('Page $page'),
        IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        title: Text(
          'My Connections',

          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 135, 216, 238),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.amber),
                SizedBox(width: 4),
                Text('123'),
              ],
            ),
          ),
        ],
        elevation: 1,
      ),
      body: Column(
        children: [
          Container(
            color: const Color.fromARGB(255, 218, 248, 245),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black54,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blue[50],
              ),
              tabs: [
                Tab(text: 'Friends'),
                Tab(text: 'Followers'),
                Tab(text: 'Following'),
                Tab(text: 'Search'),
              ],

              labelStyle: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // friends
                Column(
                  children: [
                    Expanded(
                      child: buildList(
                        mutuals,
                        action: 'Unfollow',
                        onAction: (i) {
                          unfollowUser(mutuals[i]['user_id']);
                        },
                      ),
                    ),
                  ],
                ),

                // followers
                Column(
                  children: [
                    Expanded(
                      child: buildList(
                        followers,
                        action: 'Follow Back',
                        onAction: (i) {
                          followUser(followers[i]['user_id']);
                        },
                      ),
                    ),
                  ],
                ),

                // following
                Column(
                  children: [
                    Expanded(
                      child: buildList(
                        following,
                        action: 'Unfollow',
                        onAction: (i) {
                          unfollowUser(following[i]['user_id']);
                        },
                      ),
                    ),
                  ],
                ),

                //search
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Search users',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          suffixIcon: const Icon(Icons.search),
                        ),
                        onSubmitted: (value) {
                          doSearch(value);
                        },
                      ),
                    ),
                    Expanded(
                      child: buildList(
                        searchResults,
                        action: 'Follow',
                        onAction: (i) {
                          if (searchResults[i]['is_following'] == true) return;
                          followUser(searchResults[i]['user_id']);
                        },
                        searchTab: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

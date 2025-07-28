import 'package:flutter/material.dart';
import 'package:univibe/pages/login_page.dart';
import 'package:univibe/pages/register_page.dart';
import 'package:univibe/pages/home_page.dart';
import 'package:univibe/pages/character_selectpage.dart';
import 'package:univibe/pages/fithub_page.dart';
import 'package:univibe/pages/garden_page.dart';
import 'package:univibe/pages/log_page.dart';
import 'package:univibe/pages/me_page.dart';
import 'package:univibe/pages/route_page.dart' as route;
import 'package:univibe/pages/settings.dart';
import 'package:univibe/pages/hotspot_page.dart';
import 'package:univibe/pages/f-mate.dart';
import 'package:univibe/pages/posts_page.dart';
import 'package:univibe/pages/my_posts.dart' as my;
import 'package:univibe/pages/post_detail_page.dart';
import 'package:univibe/pages/create_post.dart';
import 'package:univibe/pages/global.dart' as global;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniVibe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'PlayfairDisplay',
      ),
      initialRoute: '/login',
      routes: {
        '/home': (context) => const HomePage(),
        '/character_select': (context) => const CharacterSelectPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/fithub': (context) => const FitHubPage(),
        '/garden': (context) => GardenPage(),
        '/log': (context) => LogPage(),
        '/me': (context) => const MePage(),
        '/route_expolerer': (context) =>
            route.RoutePage(userId: global.userId!),
        '/hotspot': (context) => const HotspotPage(),
        '/f-mate': (context) => const ConnectionPage(),
        '/settings': (context) => SettingsPage(),
        '/myposts': (context) => const my.MyPostsPage(),
        '/create_post': (context) => const CreatePostPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/fit_hub_detail') {
          final postId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => PostDetailPage(postId: postId),
          );
        }
        return null;
      },
    );
  }
}

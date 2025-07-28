import 'package:flutter/material.dart';
import 'package:univibe/pages/uni_vibe_bar.dart';
import 'global.dart' as global;

class MePage extends StatelessWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 223, 240, 249),
      appBar: UniVibeBar(title: 'Me', coins: global.coins, showBack: true),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(
                    'assets/virtual_characters/peep-${global.characterindex + 1}.png',
                  ),
                ),
                SizedBox(width: 40),
                Text(
                  global.username,
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 251, 124, 13),
                  ),
                ),
              ],
            ),
            SizedBox(height: 28),
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
              title: const Text(
                'Settings',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 18,
                  color: Color.fromARGB(255, 28, 102, 230),
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: Icon(Icons.settings, color: Colors.blueAccent),
            ),
            Divider(),

            ListTile(
              onTap: () {
                Navigator.pushNamed(context, '/f-mate');
              },
              title: Text(
                'My Connections',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 18,
                  color: Color.fromARGB(255, 28, 102, 230),
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: const Icon(
                Icons.people_alt_sharp,
                color: Colors.blueAccent,
              ),
            ),
            Divider(),
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, '/myposts'); // 🔧 CHANGED HERE
              },
              title: const Text(
                'My Posts',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 18,
                  color: Color.fromARGB(255, 28, 102, 230),
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: const Icon(
                Icons.post_add_rounded,
                color: Colors.blueAccent,
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}

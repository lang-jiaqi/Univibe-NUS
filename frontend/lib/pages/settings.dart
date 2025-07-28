import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'global.dart' as global; // Import your global singleton

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

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _message;

  Future<void> changeUsernameDialog() async {
    String? newUsername;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Change Username',
          style: TextStyle(
            color: Colors.blueAccent,
            fontFamily: 'PlayfairDisplay',
          ),
        ),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'New Username',
            hintStyle: TextStyle(fontFamily: 'PlayfairDisplay'),
          ),
          onChanged: (val) => newUsername = val,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'PlayfairDisplay'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newUsername != null && newUsername!.isNotEmpty) {
                final url = Uri.parse('${getBaseUrl()}/change_username');
                final response = await http.post(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'user_id': global.userId,
                    'new_username': newUsername,
                  }),
                );
                setState(() {
                  _message = jsonDecode(response.body)['message'];
                });
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(fontFamily: 'PlayfairDisplay'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> changePasswordDialog() async {
    String? oldPassword, newPassword;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Change Password',
          style: TextStyle(fontFamily: 'PlayfairDisplay'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Old Password',
                hintStyle: TextStyle(fontFamily: 'PlayfairDisplay'),
              ),
              onChanged: (val) => oldPassword = val,
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                hintStyle: TextStyle(fontFamily: 'PlayfairDisplay'),
              ),
              onChanged: (val) => newPassword = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(fontFamily: 'PlayfairDisplay'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (oldPassword != null &&
                  newPassword != null &&
                  oldPassword!.isNotEmpty &&
                  newPassword!.isNotEmpty) {
                final url = Uri.parse('${getBaseUrl()}/change_password');
                final response = await http.post(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'user_id': global.userId,
                    'old_password': oldPassword,
                    'new_password': newPassword,
                  }),
                );
                setState(() {
                  _message = jsonDecode(response.body)['message'];
                });
                Navigator.pop(context);
              }
            },
            child: Text(
              'Save',
              style: TextStyle(fontFamily: 'PlayfairDisplay'),
            ),
          ),
        ],
      ),
    );
  }

  void showUserIdDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User ID', style: TextStyle(fontFamily: 'PlayfairDisplay')),
        content: SelectableText('${global.userId}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(fontFamily: 'PlayfairDisplay'),
            ),
          ),
        ],
      ),
    );
  }

  void logout() {
    global.userId = -1;
    global.coins = 0;
    global.username = '';
    global.characterindex = 0;
    global.characterImage = 'assets/virtual_characters/peep-61.png';
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 223, 240, 249),
      appBar: AppBar(
        title: Text('Settings'),
        titleTextStyle: TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
          fontFamily: 'PlayfairDisplay',
          fontSize: 24,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 16),
        children: [
          if (_message != null)
            Container(
              margin: EdgeInsets.only(bottom: 16),
              child: Material(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(_message!, style: TextStyle(color: Colors.green)),
                ),
              ),
            ),
          ListTile(
            leading: Icon(Icons.person_3_rounded, color: Colors.blueAccent),
            title: Text(
              'Change Username',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'PlayfairDisplay',
                fontSize: 18,
                color: Color.fromARGB(255, 28, 102, 230),
              ),
            ),

            onTap: changeUsernameDialog,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.password, color: Colors.blueAccent),
            title: Text(
              'Change Password',
              style: TextStyle(
                color: Color.fromARGB(255, 49, 101, 244),
                fontWeight: FontWeight.bold,
                fontFamily: 'PlayfairDisplay',
                fontSize: 18,
              ),
            ),

            onTap: changePasswordDialog,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.info, color: Colors.blueAccent),
            title: Text(
              'Show User ID',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color.fromARGB(255, 28, 102, 230),
                fontFamily: 'PlayfairDisplay',
              ),
            ),
            onTap: showUserIdDialog,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          Divider(),

          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text(
              'Log Out',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'PlayfairDisplay',
              ),
            ),
            onTap: logout,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ],
      ),
    );
  }
}

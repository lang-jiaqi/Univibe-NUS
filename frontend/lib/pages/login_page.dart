import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'global.dart' as global;
import 'package:univibe/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  String getBaseUrl() {
    if (Platform.isIOS || Platform.isMacOS) {
      return 'http://127.0.0.1:5000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000';
    } else {
      return 'http://127.0.0.1:5000';
    }
  }

  Future<void> _login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final url = Uri.parse('${getBaseUrl()}/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': usernameController.text,
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final respBody = jsonDecode(response.body);

      global.userId = respBody['user_id'];
      global.username = usernameController.text;

      String imageName = respBody['character_image'] ?? 'peep-61.png';
      final match = RegExp(r'peep-(\d+)\.png').firstMatch(imageName);
      if (match != null) {
        global.characterindex = int.parse(match.group(1)!) - 1;
      } else {
        global.characterindex = 60;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      final respBody = jsonDecode(response.body);
      setState(() {
        errorMessage = respBody['message'] ?? 'Login failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 223, 240, 249),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 169, 209, 241),
        title: Text(
          'Log in',
          style: TextStyle(
            color: Color.fromARGB(255, 1, 54, 95),
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintStyle: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PlayfairDisplay',
                ),
              ),
            ),
            SizedBox(height: 10),

            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintStyle: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PlayfairDisplay',
                ),
              ),
            ),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                hintStyle: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PlayfairDisplay',
                ),
              ),
            ),
            SizedBox(height: 20),

            if (isLoading) CircularProgressIndicator(),
            if (errorMessage != null) ...[
              Text(errorMessage!, style: TextStyle(color: Colors.red)),
              SizedBox(height: 10),
            ],

            ElevatedButton(
              onPressed: isLoading ? null : _login,
              child: Text(
                'Log in',
                style: TextStyle(fontFamily: 'PlayfairDisplay'),
              ),
            ),
            TextButton(
              onPressed: () {
                global.username = usernameController.text;
                Navigator.pushNamed(context, '/register');
              },
              child: Text(
                'Not yet registered? Sign up here!',
                style: TextStyle(
                  color: Color.fromARGB(255, 242, 104, 5),
                  fontFamily: 'PlayfairDisplay',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

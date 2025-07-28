import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'global.dart' as global; // Don't forget to import your global!

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
      return 'http://127.0.0.1:5000'; // Use Mac localhost by default (change to your Wi-Fi IP for real device)
    }
  }

  Future<void> _register() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final url = Uri.parse('${getBaseUrl()}/register');

    try {
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

      if (response.statusCode == 201) {
        final respBody = jsonDecode(response.body);
        global.userId =
            respBody['user_id']; // Save user id for future API calls
        global.username = usernameController.text;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        final respBody = jsonDecode(response.body);
        setState(() {
          errorMessage = respBody['message'] ?? 'Registration failed';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Network error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 176, 229, 241),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 196, 179, 243),
        title: Text(
          'Register',
          style: TextStyle(
            color: Color.fromARGB(255, 1, 41, 240),
            fontWeight: FontWeight.bold,
            fontFamily: 'PlayfairDisplay',
          ),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                hintStyle: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PlayfairDisplay',
                ),
              ),
            ),
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
              decoration: const InputDecoration(
                labelText: 'Password',
                hintStyle: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PlayfairDisplay',
                ),
              ),
            ),

            const SizedBox(height: 20),
            if (isLoading) CircularProgressIndicator(),
            if (errorMessage != null) ...[
              Text(
                errorMessage!,
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'PlayfairDisplay',
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: 10),
            ],

            ElevatedButton(
              onPressed: isLoading ? null : _register,
              child: Text(
                'Register',
                style: TextStyle(
                  color: Color.fromARGB(255, 29, 2, 79),
                  fontFamily: 'PlayfairDisplay',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Already have an account? Log in here!',
                style: TextStyle(
                  color: Color.fromARGB(255, 1, 7, 65),
                  fontFamily: 'PlayfairDisplay',
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MyPostsPage extends StatelessWidget {
  const MyPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Posts')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome to My Posts!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                // Navigate to the posts features
              },
              child: Text('Explore Posts'),
            ),
          ],
        ),
      ),
    );
  }
}

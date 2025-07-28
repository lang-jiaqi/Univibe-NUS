import 'package:flutter/material.dart';

class HotspotPage extends StatelessWidget {
  const HotspotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 232, 184),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 251, 215, 144),
        title: const Text(
          'Hotspot Map',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 1, 2),
          ),
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Welcome to the Hotspot Page! We are still polishing our last feature! coming out very soon.',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

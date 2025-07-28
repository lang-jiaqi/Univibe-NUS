import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'dart:io' show Platform;
import 'global.dart' as global;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int avatarCount = 61;

  List<String> words = [
    'Welcome to UniVibe!',
    'Your journey to fitness and wellness starts here.',
    'Believe in yourself and all that you are.',
    'Every step you take is a step towards a healthier you.',
    'Stay positive, work hard, and make it happen.',
    'Fitness is not about being better than someone else.',
    'Embrace the journey, not just the destination.',
    'Consistency is key to achieving your goals.',
    'You are stronger than you think.',
    'Every day is a new opportunity to improve yourself.',
    'Push yourself, because no one else is going to do it for you.',
    'Success is the sum of small efforts, repeated day in and day out.',
    'Your body can stand almost anything. It’s your mind that you have to convince.',
    'Motivation gets you started, habit keeps you going.',
    'Perfection is not attainable, but if we chase perfection we can catch excellence.',
  ];
  String currentPhrase = '';

  @override
  void initState() {
    super.initState();
    currentPhrase = (words..shuffle()).first;
  }

  String getBaseUrl() {
    const String macWifiIp = 'http://10.34.177.99:5000';
    if (Platform.isIOS || Platform.isMacOS) {
      return 'http://127.0.0.1:5000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000';
    } else {
      return macWifiIp;
    }
  }

  void _selectCharacter() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (context) =>
          AvatarPicker(selected: global.characterindex, count: avatarCount),
    );
    if (selected != null && selected != global.characterindex) {
      setState(() {
        global.characterindex = selected;
      });

      await _saveAvatarToBackend(selected);
    }
  }

  Future<void> _saveAvatarToBackend(int index) async {
    final url = Uri.parse('${getBaseUrl()}/character_store');
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': global.userId,
        'image': 'peep-${index + 1}.png',
      }),
    );
  }

  // bottom bar to jump
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 223, 240, 249),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/fithub');
              break;
            case 1:
              Navigator.pushNamed(context, '/garden');
              break;
            case 2:
              Navigator.pushNamed(context, '/log');
              break;
            case 3:
              Navigator.pushNamed(context, '/me');
              break;
          }
        },
        selectedItemColor: Color.fromARGB(255, 4, 122, 233),
        unselectedItemColor: Color.fromARGB(255, 4, 122, 233),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color.fromARGB(255, 248, 223, 181),
        elevation: 5,
        iconSize: 30,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'PlayfairDisplay',
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'PlayfairDisplay',
        ),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'FitHub'),
          BottomNavigationBarItem(icon: Icon(Icons.eco), label: 'Garden'),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_score_rounded),
            label: 'Log',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
        ],
      ),

      // select character
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _selectCharacter,
                    child: CircleAvatar(
                      radius: 36,
                      backgroundImage: AssetImage(
                        'assets/virtual_characters/peep-${global.characterindex + 1}.png',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 234, 131, 29),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 231, 202, 84),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        currentPhrase,
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'PlayfairDisplay',
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 2 bar: route explorer and hotspot map
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/route_expolerer');
                    },
                    icon: Icon(Icons.explore, color: Colors.white, size: 20),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 51, 126, 196),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    label: const Text(
                      'RouteExplorer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'PlayfairDisplay',
                      ),
                    ),
                  ),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/hotspot');
                    },
                    icon: Icon(Icons.map, color: Colors.white, size: 20),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 51, 126, 196),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    label: const Text(
                      'Hotspot Map',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'PlayfairDisplay',
                      ),
                    ),
                  ),
                ],
              ),

              Spacer(),
              Column(
                children: [
                  Lottie.asset(
                    'assets/Animations/Exercise.json',
                    width: 200,
                    height: 200,
                    repeat: true,
                  ),

                  Lottie.asset(
                    'assets/Animations/Connection.json',
                    width: 260,
                    height: 260,
                    repeat: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class AvatarPicker extends StatelessWidget {
  final int selected;
  final int count;
  const AvatarPicker({super.key, required this.selected, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Choose Your Virtual Character',
              style: TextStyle(
                color: Color.from(
                  alpha: 1,
                  red: 0.937,
                  green: 0.49,
                  blue: 0.008,
                ),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'PlayfairDisplay',
              ),
            ),
          ),

          Expanded(
            child: GridView.builder(
              itemCount: count,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              padding: EdgeInsets.all(16),
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => Navigator.pop(context, index),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: index == selected
                          ? Colors.blueAccent
                          : Colors.transparent,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/virtual_characters/peep-${index + 1}.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// finally finish!!!

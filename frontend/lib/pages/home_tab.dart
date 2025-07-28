import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  final String username;
  final String characterImage;
  final String defaultImage;
  final VoidCallback onAvatarTap;

  const HomeTab({
    Key? key,
    required this.username,
    required this.characterImage,
    required this.defaultImage,
    required this.onAvatarTap,
  }) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final List<String> words = [
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
  late String currentPhrase;

  @override
  void initState() {
    super.initState();
    currentPhrase = (words..shuffle()).first;
  }

  void _generateRandomPhrase() {
    setState(() {
      currentPhrase = (words..shuffle()).first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: widget.onAvatarTap,
                child: CircleAvatar(
                  radius: 36,
                  backgroundImage: AssetImage(
                    widget.characterImage.isNotEmpty
                        ? widget.characterImage
                        : widget.defaultImage,
                  ),
                ),
              ),
              SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi, ${widget.username}!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'PlayfairDisplay',
                      ),
                    ),
                    SizedBox(height: 4),

                    Container(
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
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              currentPhrase,
                              style: const TextStyle(
                                fontSize: 18,
                                fontFamily: 'PlayfairDisplay',
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            onPressed: _generateRandomPhrase,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 40),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/route_expolerer');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 51, 126, 196),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Route Explorer',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'PlayfairDisplay',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/hotspot');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 51, 126, 196),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Hotspot Map',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'PlayfairDisplay',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

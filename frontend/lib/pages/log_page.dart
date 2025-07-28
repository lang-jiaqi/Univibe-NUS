import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'global.dart' as global;
import 'package:univibe/pages/uni_vibe_bar.dart';

class LogPage extends StatefulWidget {
  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  String selectedExercise = 'Running';
  bool isTracking = false;
  int elapsedTime = 0;
  bool showToday = true;

  List<Map<String, dynamic>> logs = [];
  Timer? timer;

  String getBaseUrl() {
    if (Platform.isIOS || Platform.isMacOS) {
      return 'http://127.0.0.1:5000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000';
    } else {
      return 'http://127.0.0.1:5000';
    }
  }

  String formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  DateTime? parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      try {
        return DateTime.tryParse(dateStr.replaceAll(RegExp(r' GMT.*'), ''));
      } catch (_) {
        return null;
      }
    }
  }

  Future<void> fetchLogs() async {
    final response = await http.get(
      Uri.parse('${getBaseUrl()}/logs_post?user_id=${global.userId}'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        logs = List<Map<String, dynamic>>.from(data['logs']);
      });
    } else {
      print('Failed to fetch logs');
    }
  }

  Future<void> updateCoins(int coinsEarned) async {
    final coinsResponse = await http.post(
      Uri.parse('${getBaseUrl()}/coins'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "user_id": global.userId,
        "coins_earned": coinsEarned,
      }),
    );
    if (coinsResponse.statusCode == 200) {
      final coinsJson = json.decode(coinsResponse.body);
      setState(() {
        global.coins = coinsJson['coins'];
      });
    } else {
      print('Failed to update coins');
    }
  }

  Future<void> logActivity(String exercise, String duration) async {
    final logResponse = await http.post(
      Uri.parse('${getBaseUrl()}/log_store'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "user_id": global.userId,
        "exercise": exercise,
        "date": DateTime.now().toIso8601String(),
        "duration": duration,
      }),
    );
    if (logResponse.statusCode != 200) {
      print('Failed to store log');
    }
  }

  void startTracking() {
    setState(() {
      isTracking = true;
      elapsedTime = 0;
    });
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        elapsedTime++;
      });
    });
  }

  void stopTracking() async {
    timer?.cancel();
    int coinsEarned = (elapsedTime / 60).floor();
    if (coinsEarned == 0) coinsEarned = 1;

    final int durationToLog = elapsedTime;

    setState(() {
      isTracking = false;
      elapsedTime = 0;
    });

    await logActivity(selectedExercise, formatTime(durationToLog));
    await updateCoins(coinsEarned);
    await fetchLogs();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Visit your Garden and plant a tree?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'No Thanks!',
                style: TextStyle(
                  fontSize: 24,
                  color: Color.fromARGB(255, 3, 68, 181),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PlayfairDisplay',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/garden');
              },
              child: Text(
                'Yes!',
                style: TextStyle(
                  fontSize: 24,
                  color: Color.fromARGB(255, 3, 68, 181),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PlayfairDisplay',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  List<Map<String, dynamic>> getRecorders() {
    if (showToday) {
      final today = DateTime.now();
      return logs.where((log) {
        final logDate = parseDate(log['date']);
        if (logDate == null) return false;
        return logDate.year == today.year &&
            logDate.month == today.month &&
            logDate.day == today.day;
      }).toList();
    } else {
      return logs;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniVibeBar(
        title: 'Log Page',
        coins: global.coins,
        showBack: true,
      ),
      backgroundColor: const Color.fromARGB(255, 243, 226, 174),
      body: SafeArea(
        child: Column(
          children: [
            // choose type
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return ListView(
                        children:
                            [
                                  'Running',
                                  'Walking',
                                  'Cycling',
                                  'Swimming',
                                  'Yoga',
                                  'Jump Rope',
                                  'Badminton',
                                  'Ping Pong',
                                ]
                                .map(
                                  (exercise) => ListTile(
                                    title: Text(
                                      exercise,
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 4, 60, 156),
                                        fontSize: 20,
                                        fontFamily: 'PlayfairDisplay',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        selectedExercise = exercise;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                )
                                .toList(),
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  selectedExercise,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'PlayfairDisplay',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // tracking button
            GestureDetector(
              onTap: () {
                if (isTracking) {
                  stopTracking();
                } else {
                  startTracking();
                }
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isTracking
                      ? Color.fromARGB(255, 233, 172, 6)
                      : Colors.blue,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 193, 105, 32).withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    isTracking ? formatTime(elapsedTime) : 'Start Tracking',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'PlayfairDisplay',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            //existing logs
            //button
            ToggleButtons(
              isSelected: [showToday, !showToday],
              color: Color.fromARGB(255, 3, 68, 181),
              selectedColor: Colors.white,
              fillColor: Color.fromARGB(255, 3, 68, 181),
              borderRadius: BorderRadius.circular(12),
              borderColor: Color.fromARGB(255, 3, 68, 181),
              selectedBorderColor: Color.fromARGB(255, 3, 68, 181),
              borderWidth: 2,
              onPressed: (int index) {
                setState(() {
                  showToday = index == 0;
                });
              },
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'PlayfairDisplay',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'All',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'PlayfairDisplay',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            //list
            Expanded(
              child: ListView(
                children: getRecorders().map((record) {
                  return ListTile(
                    title: Text(
                      record['exercise'],
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'PlayfairDisplay',
                        color: Color.fromARGB(255, 3, 68, 181),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${record['duration']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'PlayfairDisplay',
                        color: Color.fromARGB(255, 3, 68, 181),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

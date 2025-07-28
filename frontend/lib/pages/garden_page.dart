import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'global.dart' as global;
import 'package:univibe/pages/uni_vibe_bar.dart'; // <<-- Import the bar

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

class GardenPage extends StatefulWidget {
  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {
  bool showPlantList = false;
  List<Map<String, dynamic>> plantedPlants = [];
  List<String> plantImages = List.generate(
    106,
    (index) => 'assets/gardenplants/plant${index + 1}.png',
  );

  @override
  void initState() {
    super.initState();
    _loadCoinsAndPlants();
  }

  Future<void> _loadCoinsAndPlants() async {
    // load coins
    final coinResp = await http.get(
      Uri.parse('${getBaseUrl()}/garden_get_coins?user_id=${global.userId}'),
    );
    if (coinResp.statusCode == 200) {
      global.coins = json.decode(coinResp.body)['coins'];
    } else {
      global.coins = 0;
    }

    // load plants
    final plantResp = await http.get(
      Uri.parse('${getBaseUrl()}/garden_send?user_id=${global.userId}'),
    );
    if (plantResp.statusCode == 200) {
      List<dynamic> plantsJson = json.decode(plantResp.body)['plants'];
      setState(() {
        plantedPlants = plantsJson.map<Map<String, dynamic>>((item) {
          return {
            'image': 'assets/gardenplants/' + item['image'],
            'offset': Offset(
              (item['x'] as num).toDouble(),
              (item['y'] as num).toDouble(),
            ),
          };
        }).toList();
      });
    } else {
      setState(() {
        plantedPlants = [];
      });
    }
    setState(() {});
  }

  Future<void> _plantNew(String imagePath, Offset offset) async {
    final resp = await http.post(
      Uri.parse('${getBaseUrl()}/garden_receive'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': global.userId,
        'image': imagePath.split('/').last,
        'x': offset.dx,
        'y': offset.dy,
      }),
    );
    if (resp.statusCode == 200) {
      setState(() {
        global.coins -= 60;
        plantedPlants.add({'offset': offset, 'image': imagePath});
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to plant!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 223, 240, 249),
      appBar: UniVibeBar(title: 'Garden', coins: global.coins, showBack: true),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: DragTarget<String>(
                  onAcceptWithDetails: (details) {
                    if (global.coins >= 60) {
                      _plantNew(details.data, details.offset);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Not enough coins!')),
                      );
                    }
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Stack(
                      children: [
                        Center(child: Image.asset('assets/nature.png')),
                        ...plantedPlants.map(
                          (item) => Positioned(
                            left: item['offset'].dx,
                            top: item['offset'].dy - 120,
                            child: Image.asset(item['image'], width: 50),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),

          // bottom for plant select
          Positioned(
            bottom: 30,
            left: 15,
            right: 15,
            child: showPlantList
                ? Container(
                    color: Colors.green,
                    height: 180,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.all(16),
                            children: plantImages
                                .map((imagePath) => buildPlantItem(imagePath))
                                .toList(),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showPlantList = false;
                            });
                          },
                          child: Text('Close'),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showPlantList = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                      ),
                      child: Text(
                        'Plant a Seed',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'PlayfairDisplay',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildPlantItem(String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Draggable<String>(
        data: imagePath,
        feedback: Image.asset(imagePath, width: 50),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: Image.asset(imagePath, width: 50),
        ),
        child: Image.asset(imagePath, width: 50),
      ),
    );
  }
}

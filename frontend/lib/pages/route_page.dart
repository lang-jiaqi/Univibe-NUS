import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

String getBaseUrl() {
  if (Platform.isIOS || Platform.isMacOS) {
    return 'http://127.0.0.1:5000';
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2:5000';
  } else {
    return 'http://127.0.0.1:5000';
  }
}

Future<void> uploadRoute({
  required String name,
  required int userId,
  required double length,
  required List<LatLng> points,
}) async {
  final url = Uri.parse('${getBaseUrl()}/record_route');

  final body = {
    'route_name': name,
    'user_id': userId,
    'length': length,
    'points': points
        .map(
          (point) => {'latitude': point.latitude, 'longitude': point.longitude},
        )
        .toList(),
  };

  await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode(body),
  );
}

Future<void> rateRoute(int routeId, String comment) async {
  final url = Uri.parse('${getBaseUrl()}/update_points');
  final body = {'route_id': routeId, 'comment': comment};

  await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode(body),
  );
}

Future<Map<String, dynamic>?> getBestRoute({
  List<int> rejectedIds = const [],
}) async {
  final url = Uri.parse('${getBaseUrl()}/get_best_routes');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'rejected_route_ids': rejectedIds}),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    return null;
  }
}

List<LatLng> extractPointsFromJson(Map<String, dynamic> data) {
  final path = data['route']['path'] as List;
  return path.map((pt) => LatLng(pt['latitude'], pt['longitude'])).toList();
}

class RoutePage extends StatefulWidget {
  final int userId;

  const RoutePage({super.key, required this.userId});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  bool _isRecording = false;
  List<LatLng> _routePoints = [];
  StreamSubscription<LocationData>? _locationSub;
  GoogleMapController? _mapController;
  int _routeId = -1;
  List<int> _rejectedIds = [];

  void _moveCameraTo(LatLng target) {
    _mapController?.animateCamera(CameraUpdate.newLatLng(target));
  }

  void _toggleRecording() async {
    if (_isRecording) {
      await _locationSub?.cancel();
      setState(() {
        _isRecording = false;
      });
    } else {
      Location location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      _locationSub = location.onLocationChanged.listen((
        LocationData currentLocation,
      ) {
        final newPoint = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
        setState(() {
          _routePoints.add(newPoint);
        });
        _moveCameraTo(newPoint);
      });

      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _previewBestRoute() async {
    final response = await getBestRoute(rejectedIds: _rejectedIds);
    if (response != null) {
      final points = extractPointsFromJson(response);
      setState(() {
        _routePoints = points;
        _routeId = response['route']['id'];
      });
      if (points.isNotEmpty) {
        _moveCameraTo(points.first);
      }
    }
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  double _calculateRouteLength(List<LatLng> points) {
    const earthRadius = 6371000.0;
    double total = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      final dLat = _deg2rad(b.latitude - a.latitude);
      final dLon = _deg2rad(b.longitude - a.longitude);
      final lat1 = _deg2rad(a.latitude);
      final lat2 = _deg2rad(b.latitude);

      final aVal =
          sin(dLat / 2) * sin(dLat / 2) +
          sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
      final c = 2 * atan2(sqrt(aVal), sqrt(1 - aVal));
      total += earthRadius * c;
    }
    return total;
  }

  Future<void> _showUploadDialog() async {
    final TextEditingController nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Name your route'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: 'e.g. NUS Shortcut'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                await uploadRoute(
                  name: nameController.text.trim().isEmpty
                      ? 'Unnamed Route'
                      : nameController.text.trim(),
                  userId: widget.userId,
                  length: _calculateRouteLength(_routePoints),
                  points: _routePoints,
                );
              },
              child: Text('Upload'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 223, 240, 249),
      appBar: AppBar(
        title: Text(
          'Route Explorer',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 233, 119, 33),
          ),
        ),
      ),

      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194),
          zoom: 15,
        ),
        myLocationEnabled: true,
        polylines: {
          Polyline(
            polylineId: PolylineId('route'),
            color: Colors.deepPurple,
            width: 5,
            points: _routePoints,
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'preview',
            onPressed: _previewBestRoute,
            child: Icon(Icons.remove_red_eye),
            tooltip: 'Preview Suggested Route',
          ),
          SizedBox(height: 10),

          FloatingActionButton(
            heroTag: 'record',
            onPressed: _toggleRecording,
            child: Icon(_isRecording ? Icons.pause : Icons.play_arrow),
            tooltip: 'Start/Stop Recording',
          ),
          SizedBox(height: 10),

          FloatingActionButton(
            heroTag: 'upload',
            onPressed: _showUploadDialog,
            child: const Icon(Icons.upload),
            tooltip: 'Upload Route',
          ),
          SizedBox(height: 10),

          FloatingActionButton(
            heroTag: 'like',
            onPressed: () {
              if (_routeId != -1) {
                rateRoute(_routeId, 'good');
              }
            },
            child: Icon(Icons.thumb_up),
            tooltip: 'Rate Good',
          ),
          SizedBox(height: 10),

          FloatingActionButton(
            heroTag: 'meh',
            onPressed: () {
              if (_routeId != -1) {
                rateRoute(_routeId, 'moderate');
              }
            },
            child: Icon(Icons.thumbs_up_down),
            tooltip: 'Rate Moderate',
          ),
          SizedBox(height: 10),

          FloatingActionButton(
            heroTag: 'dislike',
            onPressed: () async {
              if (_routeId != -1) {
                await rateRoute(_routeId, 'bad');
                _rejectedIds.add(_routeId);
                await _previewBestRoute();
              }
            },
            child: Icon(Icons.thumb_down),
            tooltip: 'Dislike and Skip',
          ),
        ],
      ),
    );
  }
}

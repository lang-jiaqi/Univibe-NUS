import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NUSMapPage extends StatefulWidget {
  const NUSMapPage({Key? key}) : super(key: key);

  @override
  State<NUSMapPage> createState() => _NUSMapPageState();
}

class _NUSMapPageState extends State<NUSMapPage> {
  GoogleMapController? _controller;

  final _center = const LatLng(1.2966, 103.7764);
  final _bounds = LatLngBounds(
    southwest: LatLng(1.2900, 103.7700),
    northeast: LatLng(1.3040, 103.7830),
  );

  void _onCreated(GoogleMapController c) {
    _controller = c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 240, 194, 116),
        title: const Text(
          'NUS Map',
          style: TextStyle(
            color: Color.fromARGB(255, 20, 18, 16),
            fontWeight: FontWeight.bold,
            fontFamily: 'PlayfairDisplay',
            fontSize: 24,
          ),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _center, zoom: 16),
        onMapCreated: _onCreated,
        onCameraMove: (pos) {
          if (!_bounds.contains(pos.target)) {
            final fix = LatLng(
              pos.target.latitude.clamp(
                _bounds.southwest.latitude,
                _bounds.northeast.latitude,
              ),
              pos.target.longitude.clamp(
                _bounds.southwest.longitude,
                _bounds.northeast.longitude,
              ),
            );
            _controller?.moveCamera(CameraUpdate.newLatLng(fix));
          }
        },
        minMaxZoomPreference: const MinMaxZoomPreference(15, 20),
        zoomControlsEnabled: false,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
      ),
    );
  }
}

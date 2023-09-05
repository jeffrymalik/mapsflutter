import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late LatLng _newPosition;
  late String _address = '';

  @override
  void initState() {
    super.initState();
    _newPosition = LatLng(-6.402905, 106.778419);
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final address = await _getAddress(position.latitude, position.longitude);

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
      );

      setState(() {
        _newPosition = LatLng(position.latitude, position.longitude);
        _address = address;
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<String> _getAddress(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];
        return placemark.toString(); // Anda bisa mengatur format alamat sesuai kebutuhan
      } else {
        return 'No address found';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<void> _updateAddress(LatLng newPosition) async {
    final address = await _getAddress(newPosition.latitude, newPosition.longitude);
    setState(() {
      _address = address;
    });
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-6.402905, 106.778419),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            markers: Set<Marker>.of([
              Marker(
                markerId: MarkerId("1"),
                position: _newPosition,
                draggable: true,
                onDragEnd: (LatLng newPosition) {
                  setState(() {
                    _newPosition = newPosition;
                  });
                  _updateAddress(newPosition); // Perbarui alamat ketika marker di-drag
                },
              ),
            ]),
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Positioned(
            top: 30,
            left: 20,
            child: Container(
              child: Text('Address: $_address'),
              color: Colors.white,
              width: 300,
              height: 50,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _determinePosition();
        },
        child: Icon(Icons.gps_fixed),
      ),
    );
  }
}

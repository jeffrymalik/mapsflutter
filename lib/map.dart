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
      body:  Stack(
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.maxFinite,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Column(
                    children: [
                      GestureDetector(
                        onDoubleTap: _determinePosition,
                        child: Padding(
                          padding: EdgeInsets.only(top: 30, left: 20, right: 20),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              color: Colors.white,
                              boxShadow: [BoxShadow(
                                color: Colors.grey,
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: Offset(0, 1,),
                              )]
                            ),
                            width: double.maxFinite,
                            height: 50,
                            child: Text('$_address',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                            ),
                            ),
                          ),
                        ),
                      )
                    ],
                    
                  ))
                ],
              ),
            ),
          )
          
          
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _determinePosition();
      //   },
      //   child: Icon(Icons.gps_fixed),
      // ),
    );
  }
}

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
  late List<Placemark> _adress = [];

  @override
  void initState() {
    super.initState();
    _newPosition = LatLng(-6.402905, 106.778419);
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      final permision = await _getLocationPermissionAndPosition();
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> adress =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
      );

      setState(() {
        _newPosition = LatLng(position.latitude, position.longitude);
        _adress = adress;
      });

      print(_adress);
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<Position> _getLocationPermissionAndPosition() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled, request user to enable them.
        throw 'Location services are disabled.';
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, request permissions again.
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        throw 'Location permissions are permanently denied, we cannot request permissions.';
      }

      // When we reach here, permissions are granted, and we can
      // continue accessing the position of the device.
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      throw e;
    }
  }

  Future<String> _getAddress(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];
        return placemark
            .toString(); // Anda bisa mengatur format alamat sesuai kebutuhan
      } else {
        return 'No address found';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<void> _updateAddress(LatLng newPosition) async {
    List<Placemark> adress = await placemarkFromCoordinates(
        newPosition.latitude, newPosition.longitude);
    setState(() {
      _adress = adress;
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
                  _updateAddress(
                      newPosition); // Perbarui alamat ketika marker di-drag
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
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      GestureDetector(
                        onDoubleTap: _determinePosition,
                        child: Padding(
                          padding:
                              EdgeInsets.only(top: 30, left: 20, right: 20),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: Offset(
                                      0,
                                      1,
                                    ),
                                  )
                                ]),
                            width: double.maxFinite,
                            height: 50,
                            child: Text(
                              '${_adress.isNotEmpty ? _adress[0].name : "N/A"}, ${_adress.isNotEmpty ? _adress[0].subLocality : "N/A"} ,${_adress.isNotEmpty ? _adress[0].locality : "N/A"}, ${_adress.isNotEmpty ? _adress[0].subAdministrativeArea : "N/A"}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final GoogleMapController controller =
                              await _controller.future;
                          controller.animateCamera(
                              CameraUpdate.newLatLng(_newPosition));
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 20),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    ],
                  )),
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

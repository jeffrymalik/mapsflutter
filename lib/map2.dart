import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late LatLng _newPosition;

  @override
  void initState() {
    super.initState();
    _newPosition = LatLng(-6.402905, 106.778419);
  }

  void getlocation() async {
    await Geolocator.checkPermission();
    await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    print(position);
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
              child: Text(
                  'New Latitude: ${_newPosition.latitude}, ${_newPosition.longitude}'),
              color: Colors.white,
              width: 300,
              height: 50,
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: GestureDetector(
              onTap: getlocation,
              child: Container(
                width: 50,
                height: 50,
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final GoogleMapController controller = await _controller.future;
          controller.animateCamera(CameraUpdate.newLatLng(_newPosition));
        },
        label: const Text('Go to New Position'),
        icon: const Icon(Icons.location_pin),
      ),
    );
  }
}

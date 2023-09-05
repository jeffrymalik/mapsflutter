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

  late String _displaytext = "Double tap here";

  void getlocation() async {
    await Geolocator.checkPermission();
    await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));

    setState(() {
      _newPosition = LatLng(position.latitude, position.longitude);
       _displaytext = "Lat: ${position.latitude}, Lng: ${position.longitude}";
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
                        onDoubleTap: getlocation,
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
                            child: Text(_displaytext,
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
     
    );
  }
}

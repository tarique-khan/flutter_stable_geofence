import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_stable_geo_fence/flutter_stable_geo_fence.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final geoFenceService = GeoFenceService();
  final latitude = 19.072109;
  final longitude = 72.891182;
  final double radius = 100;

  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    initGeoFenceService();
  }

  void initGeoFenceService() async{
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.denied) {
        startService();
      } else {
        print("Location Permission should be granted to use GeoFenceSerive");
      }

    } else {
      startService();
    }
  }

  void startService() async {
    await geoFenceService.startService(
      fenceCenterLatitude: latitude,
      fenceCenterLongitude: longitude,
      radius: radius,
    );
    _subscription = geoFenceService.geoFenceStatusListener.listen((event) {
      print("Status : ${event.status.toString()}");
      Fluttertoast.showToast(msg: "You have : ${event.status} "
          "and distance: ${event.distance}", toastLength: Toast.LENGTH_LONG);
    });
  }

  @override
  void dispose() {
    geoFenceService.stopFenceService();
    _subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Demo App'),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: onFloatingButtonClick,
        ),
      ),
    );
  }

  void onFloatingButtonClick() {
    print("inside onFloatingButtonClick");
    ///Check whether the user inside or outside the fence
    Fluttertoast.showToast(msg: "Status : ${geoFenceService.getStatus()}");
  }
}

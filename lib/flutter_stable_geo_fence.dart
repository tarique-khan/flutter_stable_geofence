
import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'dart:io' show Platform;
import 'geo_fence_status.dart';

class GeoFenceService {

  final StreamController<GeoFenceStatus> _geoFenceController =
  StreamController();

  Stream<GeoFenceStatus> get geoFenceStatusListener =>
      _geoFenceController.stream;

  StreamSubscription<Position>? _positionStream;

  var _status = Status.INITIALIZE;
  late double _fenceLatitude;
  late double _fenceLongitude;
  late double _radius;
  Position? currentLocation;

  static const MethodChannel _channel = MethodChannel('flutter_stable_geo_fence');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<void> startService({
    required fenceCenterLatitude,

    ///Latitude of the fence center
    required fenceCenterLongitude,

    ///Longitude of the fence center
    required radius,

    ///Radius in meter which indicates how much area will be covered by Fence
  }) async {
    _geoFenceController.add(GeoFenceStatus(status: Status.INITIALIZE));
    _fenceLatitude = fenceCenterLatitude;
    _fenceLongitude = fenceCenterLongitude;
    _radius = radius;

    //Check for location service;
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Exception Occurred : Location Service is not enabled");
      _geoFenceController.add(GeoFenceStatus(status: Status.ERROR));
      return;
    }

    //Check for location permission
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      print("Exception Occurred : Location Permission is Required");
      _geoFenceController.add(GeoFenceStatus(status: Status.ERROR));
      return;
    }

    LocationSettings locationSettings;
    if (Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 2),
      );
    } else if (Platform.isIOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        pauseLocationUpdatesAutomatically: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
      );
    }

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
              (Position? position) {
            if (position != null) {
              currentLocation = position;
              final distance = geDistance(position.latitude, position.longitude, _fenceLatitude, _fenceLongitude);
              Status status = distance <= _radius ? Status.ENTER : Status.EXIT;
              if (_status != status) {
                _status = status;
                final geoFenceStatus = GeoFenceStatus(status: _status);
                geoFenceStatus.latitude = position.latitude;
                geoFenceStatus.longitude = position.longitude;
                geoFenceStatus.distance = distance;
                _geoFenceController.add(geoFenceStatus);
              }
            }
          },
        );
  }

  ///It will return the status of the user i.e whether it is inside or outside the Fence area
  Status getStatus() {
    return _status;
  }

  ///It will return the current location of the user
  Position? getCurrentLocation() {
    return currentLocation;
  }

  void stopFenceService() {
    try {
      _positionStream?.cancel();
    } catch (error) {
      print("Error while stopping the FenceService : ${error.toString()}");
    }
  }

  ///Calculate distance between two latitudes and longitudes
  double geDistance(double lat1, double lon1, double lat2, double lon2) {
    double theta = lon1 - lon2;
    double dist = sin(toRadians(lat1)) * sin(toRadians(lat2)) +
        cos(toRadians(lat1)) * cos(toRadians(lat2)) * cos(toRadians(theta));
    dist = acos(dist);
    dist = toDegrees(dist);
    dist = dist * 60 * 1.1515;
    dist = dist * 1000 * 1.609344;

    ///dist in meter
    return dist;
  }

  double toRadians(double degree) {
    return degree * pi / 180;
  }

  double toDegrees(double radian) {
    return radian * 180 / pi;
  }
}

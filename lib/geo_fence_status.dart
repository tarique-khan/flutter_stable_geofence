class GeoFenceStatus {
  final Status status;

  GeoFenceStatus({required this.status});

  double latitude = 0;
  double longitude = 0;
  double distance = 0; /// in meters
}

enum Status {
  INITIALIZE, ///when service will start
  ENTER, ///when the user enters inside fence area
  EXIT, ///when the user exits from fence area
  STOP, ///when service will stop
  ERROR,
}

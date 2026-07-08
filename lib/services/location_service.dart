import 'package:latlong2/latlong.dart';

import 'debug_session_service.dart';

class LocationException implements Exception {
  const LocationException(this.message);
  final String message;
}

class SimulatedLocation {
  const SimulatedLocation({
    required this.distanceMeters,
    required this.userPosition,
  });

  final double distanceMeters;
  final LatLng userPosition;
}

class LocationService {
  LocationService._();

  static final instance = LocationService._();

  static const officeLatitude = 13.727597540447206;
  static const officeLongitude = 100.59462870464905;

  static const office = LatLng(officeLatitude, officeLongitude);

  /// Users within this distance of the office may check in on-site.
  static const nearOfficeRadiusMeters = 40.0;

  /// Bearing (degrees) used to place the mock user relative to the office.
  static const simulatedUserBearing = 135.0;

  bool _mockNear = true;

  /// Mock distance + user coordinates for the current debug session.
  ///
  /// Respects [DebugSessionService] location overrides when set.
  // TODO: restore geolocator (permission + getCurrentPosition).
  Future<SimulatedLocation> getSimulatedLocation() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final distanceMeters = _resolveDistanceMeters();
    final userPosition = const Distance().offset(
      office,
      distanceMeters,
      simulatedUserBearing,
    );

    return SimulatedLocation(
      distanceMeters: distanceMeters,
      userPosition: userPosition,
    );
  }

  /// Distance from the current position to the office, in meters.
  Future<double> distanceToOfficeMeters() async =>
      (await getSimulatedLocation()).distanceMeters;

  double _resolveDistanceMeters() {
    final debug = DebugSessionService.instance;
    return switch (debug.locationMode) {
      DebugLocationMode.near => 25.0,
      DebugLocationMode.far => 3400.0,
      DebugLocationMode.defaultMock => () {
          final distance = _mockNear ? 25.0 : 3400.0;
          _mockNear = !_mockNear;
          return distance;
        }(),
    };
  }
}

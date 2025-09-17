import 'dart:math';

import 'package:ar_location_viewer/ar_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

enum AnnotationType { pharmacy, hotel, library }

class Annotation extends ArAnnotation {
  final AnnotationType type;

  Annotation({required super.uid, required super.position, required this.type});
}

AnnotationType getRandomAnnotation() {
  final types = AnnotationType.values.toList();
  final index = Random.secure().nextInt(types.length);
  return types[index];
}

List<Annotation> farAnnotation({
  required Position position,
  int distance = 1500,
  int numberMaxPoi = 10,
}) {
  return List<Annotation>.generate(
    numberMaxPoi,
    (index) {
      return Annotation(
        uid: const Uuid().v1(),
        position: getRandomLocation(
          0.0,
          0.0,
          distance / 100000,
          distance / 100000,
        ),
        type: getRandomAnnotation(),
      );
    },
  );
}

List<Annotation> fakeAnnotation(
    {required Position position, int distance = 1500, int numberMaxPoi = 100}) {
  return List<Annotation>.generate(
    numberMaxPoi,
    (index) {
      return Annotation(
        uid: const Uuid().v1(),
        position: getRandomLocation(
          position.latitude,
          position.longitude,
          distance / 100000,
          distance / 100000,
        ),
        type: getRandomAnnotation(),
      );
    },
  );
}

Position getRandomLocation(double centerLatitude, double centerLongitude,
    double deltaLat, double deltaLon) {
  var lat = centerLatitude;
  var lon = centerLongitude;

  final latDelta = -(deltaLat / 2) + Random.secure().nextDouble() * deltaLat;
  final lonDelta = -(deltaLon / 2) + Random.secure().nextDouble() * deltaLon;
  lat = lat + latDelta;
  lon = lon + lonDelta;

  return Position(
    longitude: lon,
    latitude: lat,
    timestamp: DateTime.now(),
    accuracy: 1,
    altitude: 1,
    heading: 1,
    speed: 1,
    speedAccuracy: 1,
    altitudeAccuracy: 0.0,
    headingAccuracy: 0.0,
  );
}

List<Annotation> realAnnotation(
    {required double centerLatitude, required centerLongitude}) {
  return List<Annotation>.generate(
    1,
    (index) {
      return Annotation(
        uid: const Uuid().v1(),
        position: getRealDistance(centerLatitude, centerLongitude),
        type: getRandomAnnotation(),
      );
    },
  );
}

Position getRealDistance(double centerLatitude, double centerLongitude) {
  return Position(
    longitude: centerLongitude,
    latitude: centerLatitude,
    timestamp: DateTime.now(),
    accuracy: 1,
    altitude: 1,
    heading: 1,
    speed: 1,
    speedAccuracy: 1,
    altitudeAccuracy: 0.0,
    headingAccuracy: 0.0,
  );
}

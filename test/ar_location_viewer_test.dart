import 'package:ar_location_viewer/ar_location_viewer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArMath angle helpers', () {
    test('normalizes degrees to the 0-360 range', () {
      expect(ArMath.normalizeDegree(450), 90);
      expect(ArMath.normalizeDegree(-90), 270);
    });

    test('returns the shortest signed angle delta', () {
      expect(ArMath.deltaAngle(350, 10), -20);
      expect(ArMath.deltaAngle(10, 350), 20);
    });
  });
}

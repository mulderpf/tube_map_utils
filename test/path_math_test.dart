import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tube_map_utils/tube_map_utils.dart';

void main() {
  late TransportMap map;
  late PathMath pathMath;

  setUp(() {
    map = const TransportMap(
      lines: {
        'victoria': TransportLine(
          id: 'victoria',
          name: 'Victoria',
          color: Color(0xFF00A0E2),
          type: TransportType.underground,
          segments: [
            PathSegment(
              points: [
                Offset(0, 0),
                Offset(100, 0),
                Offset(100, 100),
              ],
            ),
          ],
        ),
        'single-point': TransportLine(
          id: 'single-point',
          name: 'Single Point',
          color: Color(0xFF000000),
          type: TransportType.underground,
          segments: [
            PathSegment(points: [Offset(50, 50)]),
          ],
        ),
      },
      stations: {},
      bounds: SvgBounds(x: 0, y: 0, width: 200, height: 200),
    );

    pathMath = PathMath(map);
  });

  group('getPathLength', () {
    test('computes correct path length', () {
      final length = pathMath.getPathLength('victoria');
      // Path: (0,0) -> (100,0) -> (100,100) = 100 + 100 = 200
      expect(length, closeTo(200.0, 0.001));
    });

    test('returns null for unknown line', () {
      expect(pathMath.getPathLength('nonexistent'), isNull);
    });
  });

  group('getPositionAtProgress', () {
    test('returns start at progress 0.0', () {
      final pos = pathMath.getPositionAtProgress('victoria', 0.0);
      expect(pos, isNotNull);
      expect(pos!.dx, closeTo(0, 0.001));
      expect(pos.dy, closeTo(0, 0.001));
    });

    test('returns end at progress 1.0', () {
      final pos = pathMath.getPositionAtProgress('victoria', 1.0);
      expect(pos, isNotNull);
      expect(pos!.dx, closeTo(100, 0.001));
      expect(pos.dy, closeTo(100, 0.001));
    });

    test('returns midpoint at progress 0.5', () {
      final pos = pathMath.getPositionAtProgress('victoria', 0.5);
      expect(pos, isNotNull);
      // 50% of 200 = 100 units along path
      // First segment is 100 units, so we're at end of first segment
      expect(pos!.dx, closeTo(100, 0.001));
      expect(pos.dy, closeTo(0, 0.001));
    });

    test('returns quarter-point at progress 0.25', () {
      final pos = pathMath.getPositionAtProgress('victoria', 0.25);
      expect(pos, isNotNull);
      // 25% of 200 = 50 units along path, on first segment
      expect(pos!.dx, closeTo(50, 0.001));
      expect(pos.dy, closeTo(0, 0.001));
    });

    test('returns three-quarter-point at progress 0.75', () {
      final pos = pathMath.getPositionAtProgress('victoria', 0.75);
      expect(pos, isNotNull);
      // 75% of 200 = 150 units, 50 into second segment
      expect(pos!.dx, closeTo(100, 0.001));
      expect(pos.dy, closeTo(50, 0.001));
    });

    test('clamps progress below 0 to 0', () {
      final pos = pathMath.getPositionAtProgress('victoria', -0.5);
      expect(pos, isNotNull);
      expect(pos!.dx, closeTo(0, 0.001));
      expect(pos.dy, closeTo(0, 0.001));
    });

    test('clamps progress above 1 to 1', () {
      final pos = pathMath.getPositionAtProgress('victoria', 1.5);
      expect(pos, isNotNull);
      expect(pos!.dx, closeTo(100, 0.001));
      expect(pos.dy, closeTo(100, 0.001));
    });

    test('returns null for unknown line', () {
      expect(pathMath.getPositionAtProgress('nonexistent', 0.5), isNull);
    });

    test('handles single-point line', () {
      final pos = pathMath.getPositionAtProgress('single-point', 0.5);
      expect(pos, isNotNull);
      expect(pos!.dx, closeTo(50, 0.001));
      expect(pos.dy, closeTo(50, 0.001));
    });
  });

  group('getPointAtDistance', () {
    test('returns point at specific distance', () {
      final pos = pathMath.getPointAtDistance('victoria', 50);
      expect(pos, isNotNull);
      expect(pos!.dx, closeTo(50, 0.001));
      expect(pos.dy, closeTo(0, 0.001));
    });

    test('returns last point when distance exceeds path length', () {
      final pos = pathMath.getPointAtDistance('victoria', 999);
      expect(pos, isNotNull);
      expect(pos!.dx, closeTo(100, 0.001));
      expect(pos.dy, closeTo(100, 0.001));
    });

    test('returns null for unknown line', () {
      expect(pathMath.getPointAtDistance('nonexistent', 50), isNull);
    });
  });

  group('getBearingAtProgress', () {
    test('returns east (90°) bearing on horizontal segment', () {
      final bearing = pathMath.getBearingAtProgress('victoria', 0.25);
      expect(bearing, isNotNull);
      // Moving right (east) along x-axis: bearing should be ~90°
      expect(bearing, closeTo(90, 0.001));
    });

    test('returns south (180°) bearing on downward segment', () {
      final bearing = pathMath.getBearingAtProgress('victoria', 0.75);
      expect(bearing, isNotNull);
      // Moving down along y-axis: bearing should be ~180°
      expect(bearing, closeTo(180, 0.001));
    });

    test('returns null for unknown line', () {
      expect(pathMath.getBearingAtProgress('nonexistent', 0.5), isNull);
    });

    test('returns null for line with fewer than 2 points', () {
      expect(pathMath.getBearingAtProgress('single-point', 0.5), isNull);
    });
  });

  group('getNearestPoint', () {
    test('finds nearest point on path', () {
      final result = pathMath.getNearestPoint(
        'victoria',
        const Offset(105, 5),
      );
      expect(result, isNotNull);
      // Nearest discrete point is (100, 0) — the corner point
      expect(result!.point.dx, closeTo(100, 0.001));
      expect(result.point.dy, closeTo(0, 0.001));
      expect(result.distance, closeTo(7.07, 0.1));
    });

    test('returns progress value for nearest point', () {
      final result = pathMath.getNearestPoint(
        'victoria',
        const Offset(100, 100),
      );
      expect(result, isNotNull);
      // Nearest is (100, 100) which is the last point at progress 1.0
      expect(result!.progress, closeTo(1.0, 0.001));
    });

    test('returns null for unknown line', () {
      expect(
        pathMath.getNearestPoint('nonexistent', const Offset(0, 0)),
        isNull,
      );
    });
  });
}

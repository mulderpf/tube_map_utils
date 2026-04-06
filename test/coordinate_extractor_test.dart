import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tube_map_utils/tube_map_utils.dart';

void main() {
  late TransportMap map;
  late CoordinateExtractor extractor;

  // Simple control points for testing: identity-like transform
  final testControlPoints = [
    const GeoControlPoint(svgX: 0, svgY: 0, lat: 51.5, lng: -0.1),
    const GeoControlPoint(svgX: 1000, svgY: 0, lat: 51.5, lng: 0.1),
    const GeoControlPoint(svgX: 0, svgY: 1000, lat: 51.3, lng: -0.1),
  ];

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
              points: [Offset(100, 100), Offset(200, 200), Offset(300, 150)],
              rawSvgPath: 'M 100 100 L 200 200 L 300 150',
            ),
          ],
        ),
        'bakerloo': TransportLine(
          id: 'bakerloo',
          name: 'Bakerloo',
          color: Color(0xFF894E24),
          type: TransportType.underground,
          segments: [
            PathSegment(
              points: [Offset(400, 400)],
              rawSvgPath: 'M 400 400',
            ),
            PathSegment(
              points: [Offset(500, 500)],
              rawSvgPath: 'M 500 500',
            ),
          ],
        ),
      },
      stations: {
        'test-station': Station(
          id: 'test-station',
          name: 'Test Station',
          position: Offset(500, 500),
          lineIds: ['victoria'],
        ),
      },
      bounds: SvgBounds(x: 0, y: 0, width: 1000, height: 1000),
    );

    extractor = CoordinateExtractor(map, controlPoints: testControlPoints);
  });

  group('getGeoCoordinates', () {
    test('returns geo coordinates for a line', () {
      final coords = extractor.getGeoCoordinates('victoria');
      expect(coords, hasLength(3));
      // Verify coordinates are in reasonable lat/lng range
      for (final coord in coords) {
        expect(coord.dx, closeTo(51.4, 0.2)); // latitude
        expect(coord.dy, closeTo(0.0, 0.2)); // longitude
      }
    });

    test('returns empty list for unknown line', () {
      expect(extractor.getGeoCoordinates('nonexistent'), isEmpty);
    });

    test('concatenates points from multiple segments', () {
      final coords = extractor.getGeoCoordinates('bakerloo');
      expect(coords, hasLength(2));
    });
  });

  group('getStationGeoCoordinate', () {
    test('returns geo coordinate for a station', () {
      final coord = extractor.getStationGeoCoordinate('test-station');
      expect(coord, isNotNull);
      expect(coord!.dx, closeTo(51.4, 0.2));
    });

    test('returns null for unknown station', () {
      expect(extractor.getStationGeoCoordinate('nonexistent'), isNull);
    });
  });

  group('getLogicalPath', () {
    test('returns SVG-space coordinates', () {
      final path = extractor.getLogicalPath('victoria');
      expect(path, hasLength(3));
      expect(path[0], equals(const Offset(100, 100)));
      expect(path[1], equals(const Offset(200, 200)));
      expect(path[2], equals(const Offset(300, 150)));
    });

    test('returns empty list for unknown line', () {
      expect(extractor.getLogicalPath('nonexistent'), isEmpty);
    });
  });

  group('getRawSvgPaths', () {
    test('returns raw SVG path strings', () {
      final paths = extractor.getRawSvgPaths('victoria');
      expect(paths, hasLength(1));
      expect(paths.first, equals('M 100 100 L 200 200 L 300 150'));
    });

    test('returns multiple paths for multi-segment lines', () {
      final paths = extractor.getRawSvgPaths('bakerloo');
      expect(paths, hasLength(2));
    });

    test('returns empty list for unknown line', () {
      expect(extractor.getRawSvgPaths('nonexistent'), isEmpty);
    });
  });

  group('AffineGeoTransform', () {
    test('throws with fewer than 3 control points', () {
      expect(
        () => AffineGeoTransform.fromControlPoints([
          const GeoControlPoint(svgX: 0, svgY: 0, lat: 51.5, lng: -0.1),
          const GeoControlPoint(
            svgX: 100,
            svgY: 0,
            lat: 51.5,
            lng: 0.0,
          ),
        ]),
        throwsArgumentError,
      );
    });

    test('transforms control points back to their geo coordinates', () {
      final transform =
          AffineGeoTransform.fromControlPoints(testControlPoints);

      for (final cp in testControlPoints) {
        final result = transform.svgToGeo(Offset(cp.svgX, cp.svgY));
        expect(result.dx, closeTo(cp.lat, 0.001));
        expect(result.dy, closeTo(cp.lng, 0.001));
      }
    });

    test('geo map control points produce reasonable London coordinates', () {
      final transform =
          AffineGeoTransform.fromControlPoints(geoMapControlPoints);

      // Test a point roughly in central London (SVG center-ish)
      final central = transform.svgToGeo(const Offset(3500, 2000));
      expect(central.dx, closeTo(51.5, 0.1)); // London latitude
      expect(central.dy, closeTo(-0.1, 0.2)); // London longitude
    });
  });
}

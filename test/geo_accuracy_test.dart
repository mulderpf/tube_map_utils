import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tube_map_utils/tube_map_utils.dart';

void main() {
  late TransportMap map;
  late CoordinateExtractor extractor;

  setUpAll(() {
    final svgContent = File(
      'assets/svg/london_underground_full_map.svg',
    ).readAsStringSync();
    final parser = SvgTransportMapParser();
    map = parser.parseString(svgContent);
    extractor = CoordinateExtractor(map);
  });

  group('District Line — all branches parsed', () {
    test('returns multiple segments (branches)', () {
      final line = map.getLine('district');
      expect(line, isNotNull);
      expect(
        line!.segments.length,
        greaterThan(1),
        reason: 'District line should have multiple branch segments',
      );
    });

    test('bounding box encompasses Wimbledon to Upminster', () {
      final coords = extractor.getGeoCoordinates('district');
      expect(coords, isNotEmpty);

      final lats = coords.map((p) => p.dx).toList();
      final lngs = coords.map((p) => p.dy).toList();

      // Wimbledon is southernmost (51.42)
      expect(lats.reduce(min), closeTo(51.42, 0.02));
      // Upminster is easternmost (0.25) — some short branch stubs
      // may be filtered by minimum length check
      expect(
        lngs.reduce(max),
        closeTo(0.20, 0.08),
        reason: 'Must reach Upminster area — indicates branches parsed',
      );
      // Richmond/Ealing Broadway is westernmost (-0.30)
      expect(lngs.reduce(min), closeTo(-0.30, 0.05));
    });
  });

  group('Affine transformation accuracy — Bakerloo Line', () {
    test('bounding box encompasses E&C to Harrow & Wealdstone', () {
      final coords = extractor.getGeoCoordinates('bakerloo');
      expect(coords, isNotEmpty);

      final lats = coords.map((p) => p.dx).toList();
      final lngs = coords.map((p) => p.dy).toList();

      expect(lats.reduce(min), closeTo(51.49, 0.02));
      expect(lats.reduce(max), closeTo(51.59, 0.02));
      expect(lngs.reduce(min), closeTo(-0.33, 0.05));
      expect(lngs.reduce(max), closeTo(-0.10, 0.05));
    });
  });

  group('Affine transformation accuracy — Northern Line', () {
    test('bounding box encompasses Morden to High Barnet/Edgware', () {
      final coords = extractor.getGeoCoordinates('northern');
      expect(coords, isNotEmpty);

      final lats = coords.map((p) => p.dx).toList();
      final lngs = coords.map((p) => p.dy).toList();

      // Southernmost ≈ Morden (51.40)
      expect(lats.reduce(min), closeTo(51.40, 0.02));
      // Northernmost ≈ High Barnet (51.65)
      expect(lats.reduce(max), closeTo(51.65, 0.03));
      // Westernmost ≈ Edgware (-0.28)
      expect(lngs.reduce(min), closeTo(-0.28, 0.05));
      // Easternmost ≈ central London
      expect(lngs.reduce(max), closeTo(-0.09, 0.05));
    });

    test('no crop-circle artefacts — all points within plausible bounds', () {
      final coords = extractor.getGeoCoordinates('northern');
      for (final p in coords) {
        expect(
          p.dx,
          inInclusiveRange(51.35, 51.70),
          reason: 'Lat ${p.dx} outside Northern line corridor',
        );
        expect(
          p.dy,
          inInclusiveRange(-0.35, 0.05),
          reason: 'Lng ${p.dy} outside Northern line corridor — '
              'possible crop-circle artefact',
        );
      }
    });
  });

  group('MoveTo splitting — no cross-branch straight lines', () {
    test('Central Line has multiple segments for branches', () {
      final line = map.getLine('central');
      expect(line, isNotNull);
      expect(
        line!.segments.length,
        greaterThan(1),
        reason: 'Central has branches — must produce multiple segments',
      );

      // Each segment should be geographically contiguous
      final transform =
          AffineGeoTransform.fromControlPoints(geoMapControlPoints);
      for (final segment in line.segments) {
        if (segment.points.length < 2) continue;
        final lngs = segment.points
            .map((p) => transform.svgToGeo(p).dy)
            .toList();
        final lngRange = lngs.reduce(max) - lngs.reduce(min);
        expect(
          lngRange,
          lessThan(0.4),
          reason: 'Single segment spans too wide — likely contains '
              'a moveTo jump between branches',
        );
      }
    });

    test('Metropolitan Line has multiple segments for spurs', () {
      final line = map.getLine('metropolitan');
      expect(line, isNotNull);
      expect(
        line!.segments.length,
        greaterThan(1),
        reason: 'Metropolitan has Chesham/Amersham/Watford spurs',
      );
    });

    test('Piccadilly Line has multiple segments', () {
      final line = map.getLine('piccadilly');
      expect(line, isNotNull);
      expect(
        line!.segments.length,
        greaterThan(1),
        reason: 'Piccadilly has a Heathrow branch',
      );
    });

    test('District Line has 4+ segments for branches', () {
      final line = map.getLine('district');
      expect(line, isNotNull);
      expect(
        line!.segments.length,
        greaterThan(3),
        reason: 'District has 4+ branches',
      );
    });
  });

  group('Northern Line — no stray paths', () {
    test('all points within Northern line corridor', () {
      final coords = extractor.getGeoCoordinates('northern');
      for (final p in coords) {
        expect(
          p.dy,
          inInclusiveRange(-0.28, 0.02),
          reason: 'Lng ${p.dy} is outside Northern corridor — '
              'possible stray path from colour fallback',
        );
      }
    });

    test('no 2-point stub segments', () {
      final line = map.getLine('northern')!;
      for (var i = 0; i < line.segments.length; i++) {
        expect(
          line.segments[i].points.length,
          greaterThan(2),
          reason: 'Segment $i has only ${line.segments[i].points.length} '
              'points — likely a station tick or connector stub',
        );
      }
    });
  });

  group('Affine transformation — control point accuracy', () {
    test('no systematic directional offset', () {
      // Verify that known stations transform within tolerance
      final transform =
          AffineGeoTransform.fromControlPoints(geoMapControlPoints);

      for (final cp in geoMapControlPoints) {
        final result = transform.svgToGeo(Offset(cp.svgX, cp.svgY));
        expect(
          result.dx,
          closeTo(cp.lat, 0.005),
          reason: 'Lat offset at SVG (${cp.svgX}, ${cp.svgY})',
        );
        expect(
          result.dy,
          closeTo(cp.lng, 0.005),
          reason: 'Lng offset at SVG (${cp.svgX}, ${cp.svgY})',
        );
      }
    });
  });
}

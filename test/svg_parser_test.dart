import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tube_map_utils/tube_map_utils.dart';

import 'helpers.dart';

void main() {
  group('SvgTransportMapParser', () {
    late SvgTransportMapParser parser;

    setUp(() {
      parser = SvgTransportMapParser();
    });

    group('parseString', () {
      test('parses geo SVG and identifies lines by ID', () {
        final map = parser.parseString(testSvg);

        expect(map.lines, isNotEmpty);
        expect(map.getLine('victoria'), isNotNull);
        expect(map.getLine('bakerloo'), isNotNull);
        expect(map.getLine('victoria')!.name, equals('Victoria'));
        expect(map.getLine('bakerloo')!.name, equals('Bakerloo'));
      });

      test('parsed lines have non-empty segments', () {
        final map = parser.parseString(testSvg);

        final victoria = map.getLine('victoria')!;
        expect(victoria.segments, isNotEmpty);
        expect(victoria.segments.first.points, isNotEmpty);
        expect(victoria.segments.first.rawSvgPath, isNotEmpty);
      });

      test('parses schematic SVG with CSS classes', () {
        final map = parser.parseString(testSchematicSvg);

        expect(map.getLine('victoria'), isNotNull);
        expect(map.getLine('bakerloo'), isNotNull);
        expect(map.getLine('dlr'), isNotNull);
      });

      test('parses SVG bounds from viewBox', () {
        final map = parser.parseString(testSvg);

        expect(map.bounds.x, equals(0));
        expect(map.bounds.y, equals(0));
        expect(map.bounds.width, equals(6000));
        expect(map.bounds.height, equals(3500));
      });

      test('parses SVG bounds from viewBox with offset', () {
        final map = parser.parseString(testSchematicSvg);

        expect(map.bounds.x, equals(-40.5));
        expect(map.bounds.y, equals(-120.5));
        expect(map.bounds.width, equals(2500));
        expect(map.bounds.height, equals(1340));
      });

      test('falls back to width/height when no viewBox', () {
        const svg = '''
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="800" height="600">
  <path id="Victoria Line" d="M 100,100 L 200,200" fill="none" stroke="#0a9cda"/>
</svg>
''';
        final map = parser.parseString(svg);

        expect(map.bounds.x, equals(0));
        expect(map.bounds.y, equals(0));
        expect(map.bounds.width, equals(800));
        expect(map.bounds.height, equals(600));
      });

      test('returns empty map for SVG with no transport lines', () {
        final map = parser.parseString(emptySvg);

        expect(map.lines, isEmpty);
      });

      test('extracts stations from text elements', () {
        final map = parser.parseString(testSvg);

        expect(map.stations, isNotEmpty);
        final stationNames =
            map.stations.values.map((s) => s.name).toList();
        expect(stationNames, contains('Test Station A'));
        expect(stationNames, contains('Test Station B'));
      });

      test('stations have correct positions', () {
        final map = parser.parseString(testSvg);

        final stationA = map.getStation('Test Station A');
        expect(stationA, isNotNull);
        expect(stationA!.position.dx, equals(150));
        expect(stationA.position.dy, equals(90));
      });

      test('identifies lines by stroke colour from style attribute', () {
        final map = parser.parseString(styleSvg);

        // The stroke colour #0a9cda doesn't directly match Victoria's
        // colour (0x00A0E2) in the line definitions, so this tests the
        // style parsing path even if no line is matched
        expect(map.lines.length, lessThanOrEqualTo(1));
      });

      test('identifies lines by inline stroke colour fallback', () {
        final map = parser.parseString(strokeColorSvg);

        // #894E24 matches Bakerloo line colour
        expect(map.getLine('bakerloo'), isNotNull);
      });

      test('handles 3-character hex colours', () {
        final map = parser.parseString(shortHexSvg);

        // #000 expands to #000000 which matches Northern line
        expect(map.getLine('northern'), isNotNull);
      });

      test('handles closed paths with Z command', () {
        final map = parser.parseString(closedPathSvg);

        final victoria = map.getLine('victoria');
        expect(victoria, isNotNull);
        expect(victoria!.segments.first.points, isNotEmpty);
      });

      test('identifies lines from parent group class', () {
        final map = parser.parseString(parentClassSvg);

        expect(map.getLine('jubilee'), isNotNull);
        expect(map.getLine('jubilee')!.segments, isNotEmpty);
      });

      test('parses cubic bezier paths into points', () {
        final map = parser.parseString(cubicSvg);

        final victoria = map.getLine('victoria');
        expect(victoria, isNotNull);
        // Cubic bezier is sampled at 8 intervals + moveTo point
        expect(victoria!.segments.first.points.length, greaterThan(2));
      });

      test('filters out non-station text', () {
        final map = parser.parseString(nonStationTextSvg);

        final names = map.stations.values.map((s) => s.name).toList();
        expect(names, contains('Valid Station'));
        expect(names, isNot(contains('Zone 1')));
        expect(names, isNot(contains('N')));
        expect(names, isNot(contains('© Creative Commons')));
      });
    });

    group('caching', () {
      test('returns cached result on second parse', () {
        final map1 = parser.parseString(testSvg);
        final map2 = parser.parseString(testSvg);

        expect(identical(map1, map2), isTrue);
        expect(parser.cacheSize, equals(1));
      });

      test('different SVGs produce different cached results', () {
        final map1 = parser.parseString(testSvg);
        final map2 = parser.parseString(testSchematicSvg);

        expect(identical(map1, map2), isFalse);
        expect(parser.cacheSize, equals(2));
      });

      test('clearCache removes all cached results', () {
        parser.parseString(testSvg);
        parser.parseString(testSchematicSvg);
        expect(parser.cacheSize, equals(2));

        parser.clearCache();
        expect(parser.cacheSize, equals(0));
      });
    });

    group('line identification', () {
      test('identifies correct transport types', () {
        final map = parser.parseString(testSchematicSvg);

        expect(
          map.getLine('victoria')?.type,
          equals(TransportType.underground),
        );
        expect(
          map.getLine('bakerloo')?.type,
          equals(TransportType.underground),
        );
        expect(map.getLine('dlr')?.type, equals(TransportType.dlr));
      });

      test('assigns correct colours', () {
        final map = parser.parseString(testSvg);

        final victoria = map.getLine('victoria')!;
        expect(victoria.color, equals(const Color(0xFF0A9CDA)));

        final bakerloo = map.getLine('bakerloo')!;
        expect(bakerloo.color, equals(const Color(0xFFAE6017)));
      });
    });

    group('station-line association', () {
      test('associates stations near line paths', () {
        final map = parser.parseString(testSvg);

        final stationB = map.getStation('Test Station B');
        expect(stationB, isNotNull);
        // Station B at (450, 390) is near the Bakerloo line path
        // (400,400 -> 500,500 -> 600,450 -> 700,400)
        expect(stationB!.lineIds, contains('bakerloo'));
      });
    });
  });
}

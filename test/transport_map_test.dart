import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tube_map_utils/tube_map_utils.dart';

void main() {
  late TransportMap map;

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
              points: [Offset(100, 100), Offset(200, 200)],
              rawSvgPath: 'M 100 100 L 200 200',
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
              points: [Offset(300, 300), Offset(400, 400)],
              rawSvgPath: 'M 300 300 L 400 400',
            ),
          ],
        ),
        'dlr': TransportLine(
          id: 'dlr',
          name: 'DLR',
          color: Color(0xFF00A4A7),
          type: TransportType.dlr,
          segments: [
            PathSegment(
              points: [Offset(500, 100), Offset(600, 200)],
              rawSvgPath: 'M 500 100 L 600 200',
            ),
          ],
        ),
      },
      stations: {
        'oxford-circus': Station(
          id: 'oxford-circus',
          name: 'Oxford Circus',
          position: Offset(150, 150),
          lineIds: ['victoria', 'bakerloo'],
        ),
        'brixton': Station(
          id: 'brixton',
          name: 'Brixton',
          position: Offset(200, 200),
          lineIds: ['victoria'],
        ),
        'bank': Station(
          id: 'bank',
          name: 'Bank',
          position: Offset(550, 150),
          lineIds: ['dlr'],
        ),
      },
      bounds: SvgBounds(x: 0, y: 0, width: 1000, height: 500),
    );
  });

  group('getAllLines', () {
    test('returns all lines', () {
      final lines = map.getAllLines();
      expect(lines, hasLength(3));
    });
  });

  group('getLine', () {
    test('returns line by id', () {
      expect(map.getLine('victoria')?.name, equals('Victoria'));
    });

    test('returns null for unknown id', () {
      expect(map.getLine('nonexistent'), isNull);
    });
  });

  group('getLinesByType', () {
    test('filters underground lines', () {
      final underground = map.getLinesByType(TransportType.underground);
      expect(underground, hasLength(2));
      expect(underground.map((l) => l.id), containsAll(['victoria', 'bakerloo']));
    });

    test('filters DLR lines', () {
      final dlr = map.getLinesByType(TransportType.dlr);
      expect(dlr, hasLength(1));
      expect(dlr.first.id, equals('dlr'));
    });

    test('returns empty list for type with no lines', () {
      final tram = map.getLinesByType(TransportType.tram);
      expect(tram, isEmpty);
    });
  });

  group('getStationsForLine', () {
    test('returns stations for a line', () {
      final stations = map.getStationsForLine('victoria');
      expect(stations, hasLength(2));
      expect(
        stations.map((s) => s.id),
        containsAll(['oxford-circus', 'brixton']),
      );
    });

    test('returns empty list for unknown line', () {
      expect(map.getStationsForLine('nonexistent'), isEmpty);
    });
  });

  group('getStation', () {
    test('finds station by name (case-insensitive)', () {
      expect(map.getStation('Oxford Circus')?.id, equals('oxford-circus'));
      expect(map.getStation('oxford circus')?.id, equals('oxford-circus'));
      expect(map.getStation('OXFORD CIRCUS')?.id, equals('oxford-circus'));
    });

    test('returns null for unknown station', () {
      expect(map.getStation('Nonexistent Station'), isNull);
    });
  });

  group('getLinesForStation', () {
    test('returns lines at interchange', () {
      final lines = map.getLinesForStation('oxford-circus');
      expect(lines, hasLength(2));
      expect(lines.map((l) => l.id), containsAll(['victoria', 'bakerloo']));
    });

    test('returns empty list for unknown station', () {
      expect(map.getLinesForStation('nonexistent'), isEmpty);
    });
  });

  group('getMapBounds', () {
    test('returns SVG bounds', () {
      final bounds = map.getMapBounds();
      expect(bounds.width, equals(1000));
      expect(bounds.height, equals(500));
    });
  });
}

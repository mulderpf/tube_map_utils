import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tube_map_utils/tube_map_utils.dart';

void main() {
  group('TransportType', () {
    test('has all expected values', () {
      expect(TransportType.values, hasLength(5));
      expect(TransportType.values, contains(TransportType.underground));
      expect(TransportType.values, contains(TransportType.overground));
      expect(TransportType.values, contains(TransportType.dlr));
      expect(TransportType.values, contains(TransportType.elizabeth));
      expect(TransportType.values, contains(TransportType.tram));
    });
  });

  group('PathSegment', () {
    test('equality by points and rawSvgPath', () {
      const a = PathSegment(
        points: [Offset(1, 2), Offset(3, 4)],
        rawSvgPath: 'M 1 2 L 3 4',
      );
      const b = PathSegment(
        points: [Offset(1, 2), Offset(3, 4)],
        rawSvgPath: 'M 1 2 L 3 4',
      );
      const c = PathSegment(
        points: [Offset(5, 6)],
        rawSvgPath: 'M 5 6',
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equality with different length lists', () {
      const a = PathSegment(
        points: [Offset(1, 2)],
        rawSvgPath: 'M 1 2',
      );
      const b = PathSegment(
        points: [Offset(1, 2), Offset(3, 4)],
        rawSvgPath: 'M 1 2',
      );
      expect(a, isNot(equals(b)));
    });

    test('default rawSvgPath is empty', () {
      const segment = PathSegment(points: [Offset(0, 0)]);
      expect(segment.rawSvgPath, isEmpty);
    });

    test('toString truncates long rawSvgPath', () {
      const segment = PathSegment(
        points: [Offset(0, 0)],
        rawSvgPath: 'M 0 0 L 1 1 L 2 2 L 3 3 L 4 4',
      );
      expect(segment.toString(), contains('...'));
    });

    test('toString shows short rawSvgPath', () {
      const segment = PathSegment(
        points: [Offset(0, 0)],
        rawSvgPath: 'M 0 0',
      );
      expect(segment.toString(), contains('M 0 0'));
    });

    test('not equal when same length but different points', () {
      const a = PathSegment(
        points: [Offset(1, 2), Offset(3, 4)],
        rawSvgPath: 'M 1 2 L 3 4',
      );
      const b = PathSegment(
        points: [Offset(1, 2), Offset(5, 6)],
        rawSvgPath: 'M 1 2 L 3 4',
      );
      expect(a, isNot(equals(b)));
    });

    test('is not equal to non-PathSegment', () {
      const segment = PathSegment(points: [Offset(0, 0)]);
      expect(segment == Object(), isFalse);
    });
  });

  group('TransportLine', () {
    test('equality by id', () {
      const a = TransportLine(
        id: 'victoria',
        name: 'Victoria',
        color: Color(0xFF00A0E2),
        type: TransportType.underground,
        segments: [],
      );
      const b = TransportLine(
        id: 'victoria',
        name: 'Victoria Modified',
        color: Color(0xFFFF0000),
        type: TransportType.underground,
        segments: [],
      );
      const c = TransportLine(
        id: 'central',
        name: 'Central',
        color: Color(0xFFDC241F),
        type: TransportType.underground,
        segments: [],
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString includes id and name', () {
      const line = TransportLine(
        id: 'victoria',
        name: 'Victoria',
        color: Color(0xFF00A0E2),
        type: TransportType.underground,
        segments: [],
      );
      expect(line.toString(), contains('victoria'));
      expect(line.toString(), contains('Victoria'));
    });

    test('is not equal to non-TransportLine', () {
      const line = TransportLine(
        id: 'victoria',
        name: 'Victoria',
        color: Color(0xFF00A0E2),
        type: TransportType.underground,
        segments: [],
      );
      expect(line == Object(), isFalse);
    });
  });

  group('Station', () {
    test('equality by id', () {
      const a = Station(
        id: 'oxford-circus',
        name: 'Oxford Circus',
        position: Offset(100, 200),
        lineIds: ['victoria', 'central'],
      );
      const b = Station(
        id: 'oxford-circus',
        name: 'Different Name',
        position: Offset(999, 999),
        lineIds: [],
      );
      const c = Station(
        id: 'kings-cross',
        name: "King's Cross",
        position: Offset(300, 400),
        lineIds: ['victoria'],
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString includes id and name', () {
      const station = Station(
        id: 'oxford-circus',
        name: 'Oxford Circus',
        position: Offset(100, 200),
        lineIds: [],
      );
      expect(station.toString(), contains('oxford-circus'));
      expect(station.toString(), contains('Oxford Circus'));
    });

    test('is not equal to non-Station', () {
      const station = Station(
        id: 'test',
        name: 'Test',
        position: Offset(0, 0),
        lineIds: [],
      );
      expect(station == Object(), isFalse);
    });
  });

  group('SvgBounds', () {
    test('equality by all fields', () {
      const a = SvgBounds(x: 0, y: 0, width: 100, height: 200);
      const b = SvgBounds(x: 0, y: 0, width: 100, height: 200);
      const c = SvgBounds(x: 10, y: 0, width: 100, height: 200);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString includes dimensions', () {
      const bounds = SvgBounds(x: 0, y: 0, width: 6000, height: 3500);
      expect(bounds.toString(), contains('6000'));
      expect(bounds.toString(), contains('3500'));
    });

    test('not equal when y differs', () {
      const a = SvgBounds(x: 0, y: 0, width: 100, height: 200);
      const b = SvgBounds(x: 0, y: 1, width: 100, height: 200);
      expect(a, isNot(equals(b)));
    });

    test('not equal when width differs', () {
      const a = SvgBounds(x: 0, y: 0, width: 100, height: 200);
      const b = SvgBounds(x: 0, y: 0, width: 101, height: 200);
      expect(a, isNot(equals(b)));
    });

    test('not equal when height differs', () {
      const a = SvgBounds(x: 0, y: 0, width: 100, height: 200);
      const b = SvgBounds(x: 0, y: 0, width: 100, height: 201);
      expect(a, isNot(equals(b)));
    });

    test('is not equal to non-SvgBounds', () {
      const bounds = SvgBounds(x: 0, y: 0, width: 100, height: 100);
      expect(bounds == Object(), isFalse);
    });
  });
}

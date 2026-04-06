import 'dart:math' as math;
import 'dart:ui';

import 'package:tube_map_utils/src/models/transport_map.dart';

/// Pure computation utilities for working with transport line paths.
///
/// Provides methods for calculating positions along paths, bearings,
/// distances, and nearest-point queries. All methods operate on the
/// parsed path data and return coordinates in the same space as the
/// source map (SVG coordinates for schematic, or can be combined with
/// [CoordinateExtractor] for geographical coordinates).
///
/// ```dart
/// final pathMath = PathMath(map);
///
/// // Get position at 45% along the Victoria line
/// final pos = pathMath.getPositionAtProgress('victoria', 0.45);
///
/// // Get bearing for vehicle rotation
/// final bearing = pathMath.getBearingAtProgress('victoria', 0.45);
/// ```
class PathMath {
  /// Creates a [PathMath] for the given [map].
  PathMath(this.map);

  /// The parsed transport map to perform calculations on.
  final TransportMap map;

  /// Returns the total path length for the given [lineId].
  ///
  /// The length is in SVG coordinate units. For geographical maps, this
  /// is proportional to real-world distance but not in metres.
  ///
  /// Returns `null` if the line is not found.
  ///
  /// ```dart
  /// final length = pathMath.getPathLength('central');
  /// ```
  double? getPathLength(String lineId) {
    final points = _getPoints(lineId);
    if (points == null) return null;
    return _computeLength(points);
  }

  /// Returns the coordinate at [progress] (0.0–1.0) along the given
  /// [lineId]'s path.
  ///
  /// Returns `null` if the line is not found or has no points.
  ///
  /// ```dart
  /// final midpoint = pathMath.getPositionAtProgress('victoria', 0.5);
  /// ```
  Offset? getPositionAtProgress(String lineId, double progress) {
    final points = _getPoints(lineId);
    if (points == null || points.isEmpty) return null;
    final clamped = progress.clamp(0.0, 1.0);
    final totalLength = _computeLength(points);
    return _getPointAtDistance(points, clamped * totalLength);
  }

  /// Returns the coordinate at [distance] along the given [lineId]'s path.
  ///
  /// Distance is in SVG coordinate units.
  /// Returns `null` if the line is not found.
  ///
  /// ```dart
  /// final point = pathMath.getPointAtDistance('northern', 500.0);
  /// ```
  Offset? getPointAtDistance(String lineId, double distance) {
    final points = _getPoints(lineId);
    if (points == null || points.isEmpty) return null;
    return _getPointAtDistance(points, distance);
  }

  /// Returns the bearing (heading in degrees, 0 = north, clockwise) at
  /// [progress] (0.0–1.0) along the given [lineId]'s path.
  ///
  /// Returns `null` if the line is not found or has fewer than 2 points.
  ///
  /// ```dart
  /// final bearing = pathMath.getBearingAtProgress('district', 0.5);
  /// ```
  double? getBearingAtProgress(String lineId, double progress) {
    final points = _getPoints(lineId);
    if (points == null || points.length < 2) return null;

    final clamped = progress.clamp(0.0, 1.0);
    final totalLength = _computeLength(points);
    final targetDist = clamped * totalLength;

    // Find the segment containing the target distance
    var accumulated = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      final segLen = _distance(points[i], points[i + 1]);
      if (accumulated + segLen >= targetDist || i == points.length - 2) {
        final dx = points[i + 1].dx - points[i].dx;
        final dy = points[i + 1].dy - points[i].dy;
        // Convert to compass bearing (0=north, clockwise)
        final radians = math.atan2(dx, -dy);
        return (radians * 180 / math.pi) % 360;
      }
      accumulated += segLen;
    }
    return null;
  }

  /// Finds the nearest point on the given [lineId]'s path to [coordinate].
  ///
  /// Returns a [NearestPointResult] with the closest point, its progress
  /// value, and the distance from the input coordinate.
  ///
  /// Returns `null` if the line is not found.
  ///
  /// ```dart
  /// final result = pathMath.getNearestPoint(
  ///   'victoria',
  ///   Offset(3500, 2000),
  /// );
  /// if (result != null) {
  ///   print('Nearest at progress ${result.progress}');
  ///   print('Distance: ${result.distance}');
  /// }
  /// ```
  NearestPointResult? getNearestPoint(String lineId, Offset coordinate) {
    final points = _getPoints(lineId);
    if (points == null || points.isEmpty) return null;

    var bestDist = double.infinity;
    var bestPoint = points.first;
    var bestDistAlong = 0.0;
    var totalLength = 0.0;
    var currentDist = 0.0;

    // First pass: compute total length
    totalLength = _computeLength(points);

    // Second pass: find nearest point
    currentDist = 0.0;
    for (var i = 0; i < points.length; i++) {
      final d = _distance(points[i], coordinate);
      if (d < bestDist) {
        bestDist = d;
        bestPoint = points[i];
        bestDistAlong = currentDist;
      }
      if (i < points.length - 1) {
        currentDist += _distance(points[i], points[i + 1]);
      }
    }

    final progress = totalLength > 0 ? bestDistAlong / totalLength : 0.0;

    return NearestPointResult(
      point: bestPoint,
      progress: progress,
      distance: bestDist,
    );
  }

  List<Offset>? _getPoints(String lineId) {
    final line = map.getLine(lineId);
    if (line == null) return null;
    return line.segments.expand((s) => s.points).toList();
  }

  static double _computeLength(List<Offset> points) {
    var length = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      length += _distance(points[i], points[i + 1]);
    }
    return length;
  }

  static Offset _getPointAtDistance(List<Offset> points, double distance) {
    if (points.length == 1) return points.first;

    var accumulated = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      final segLen = _distance(points[i], points[i + 1]);
      if (accumulated + segLen >= distance) {
        final t = segLen > 0 ? (distance - accumulated) / segLen : 0.0;
        return Offset(
          points[i].dx + t * (points[i + 1].dx - points[i].dx),
          points[i].dy + t * (points[i + 1].dy - points[i].dy),
        );
      }
      accumulated += segLen;
    }
    return points.last;
  }

  static double _distance(Offset a, Offset b) {
    final dx = a.dx - b.dx;
    final dy = a.dy - b.dy;
    return math.sqrt(dx * dx + dy * dy);
  }
}

/// The result of a nearest-point query on a transport line path.
///
/// ```dart
/// final result = pathMath.getNearestPoint('victoria', somePoint);
/// if (result != null) {
///   print('Closest point: ${result.point}');
///   print('Progress: ${result.progress}');
///   print('Distance: ${result.distance}');
/// }
/// ```
class NearestPointResult {
  /// Creates a [NearestPointResult].
  const NearestPointResult({
    required this.point,
    required this.progress,
    required this.distance,
  });

  /// The closest point on the path to the query coordinate.
  final Offset point;

  /// The normalised progress (0.0–1.0) of this point along the path.
  final double progress;

  /// The distance from the query coordinate to the nearest point.
  final double distance;
}

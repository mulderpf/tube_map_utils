import 'dart:ui';

/// A segment of a transport line's path, representing a continuous section
/// of the route as a series of points.
///
/// Each [PathSegment] corresponds to one SVG `<path>` element. A line may
/// consist of multiple segments (e.g., branches).
///
/// ```dart
/// for (final segment in line.segments) {
///   print('Segment has ${segment.points.length} points');
///   print('Raw SVG: ${segment.rawSvgPath}');
/// }
/// ```
class PathSegment {
  /// Creates a [PathSegment] with the given [points] and optional
  /// [rawSvgPath] data.
  const PathSegment({
    required this.points,
    this.rawSvgPath = '',
  });

  /// The ordered list of points forming this path segment.
  ///
  /// For geographical maps, these are in SVG coordinate space and can be
  /// transformed to lat/lng using the coordinate extraction APIs.
  /// For schematic maps, these are logical positions in SVG space.
  final List<Offset> points;

  /// The raw SVG path `d` attribute string for this segment.
  ///
  /// Useful for consumers who want to render or further process the
  /// original SVG path data themselves.
  final String rawSvgPath;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PathSegment &&
          runtimeType == other.runtimeType &&
          rawSvgPath == other.rawSvgPath &&
          _pointsEqual(points, other.points);

  @override
  int get hashCode => Object.hash(rawSvgPath, Object.hashAll(points));

  static bool _pointsEqual(List<Offset> a, List<Offset> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'PathSegment(points: ${points.length}, rawSvgPath: ${rawSvgPath.length > 20 ? '${rawSvgPath.substring(0, 20)}...' : rawSvgPath})';
}

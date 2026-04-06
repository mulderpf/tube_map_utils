/// The bounding box of an SVG document, parsed from its `viewBox` attribute
/// or `width`/`height` attributes.
///
/// ```dart
/// final bounds = map.bounds;
/// print('Map size: ${bounds.width} x ${bounds.height}');
/// ```
class SvgBounds {
  /// Creates [SvgBounds] with the given origin and dimensions.
  const SvgBounds({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// The x-coordinate of the top-left corner of the viewBox.
  final double x;

  /// The y-coordinate of the top-left corner of the viewBox.
  final double y;

  /// The width of the SVG viewBox.
  final double width;

  /// The height of the SVG viewBox.
  final double height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SvgBounds &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => Object.hash(x, y, width, height);

  @override
  String toString() => 'SvgBounds($x, $y, $width, $height)';
}

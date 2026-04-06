import 'dart:ui';

/// A station parsed from an SVG transport map.
///
/// Contains the station's identity, position in SVG coordinate space, and
/// which lines it is associated with.
///
/// ```dart
/// final station = map.getStation('Oxford Circus');
/// if (station != null) {
///   print('${station.name} at ${station.position}');
///   print('Lines: ${station.lineIds}');
/// }
/// ```
class Station {
  /// Creates a [Station] with the given properties.
  const Station({
    required this.id,
    required this.name,
    required this.position,
    required this.lineIds,
  });

  /// Unique identifier for this station, typically a normalised kebab-case
  /// form of the name (e.g., `'oxford-circus'`, `'kings-cross-st-pancras'`).
  final String id;

  /// Human-readable display name (e.g., `'Oxford Circus'`).
  final String name;

  /// Position of this station in SVG coordinate space.
  ///
  /// For geographical maps, this can be transformed to lat/lng using the
  /// coordinate extraction APIs.
  final Offset position;

  /// IDs of the transport lines that serve this station.
  final List<String> lineIds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Station &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Station($id, $name)';
}

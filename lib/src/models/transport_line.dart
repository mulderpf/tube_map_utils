import 'dart:ui';

import 'package:tube_map_utils/src/models/path_segment.dart';
import 'package:tube_map_utils/src/models/transport_type.dart';

/// A single transport line (e.g., Bakerloo, Central, DLR) parsed from an
/// SVG map.
///
/// Contains the line's identity, visual properties, and route geometry.
///
/// ```dart
/// final bakerloo = map.getLine('bakerloo');
/// if (bakerloo != null) {
///   print('${bakerloo.name}: ${bakerloo.segments.length} segments');
///   print('Colour: #${bakerloo.color.value.toRadixString(16)}');
/// }
/// ```
class TransportLine {
  /// Creates a [TransportLine] with the given properties.
  const TransportLine({
    required this.id,
    required this.name,
    required this.color,
    required this.type,
    required this.segments,
  });

  /// Unique kebab-case identifier for this line (e.g., `'bakerloo'`,
  /// `'hammersmith-city'`, `'dlr'`).
  final String id;

  /// Human-readable display name (e.g., `'Bakerloo'`,
  /// `'Hammersmith & City'`).
  final String name;

  /// The official colour of this line, as parsed from the SVG stroke colour.
  final Color color;

  /// The transport type this line belongs to.
  final TransportType type;

  /// The route geometry as a list of [PathSegment] objects.
  ///
  /// A line may have multiple segments for branches or discontinuous
  /// sections.
  final List<PathSegment> segments;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransportLine &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TransportLine($id, $name, ${segments.length} segments)';
}

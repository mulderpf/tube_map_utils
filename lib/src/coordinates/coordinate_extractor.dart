import 'dart:ui';

import 'package:tube_map_utils/src/coordinates/affine_transform.dart';
import 'package:tube_map_utils/src/coordinates/control_points.dart';
import 'package:tube_map_utils/src/models/transport_map.dart';

/// Provides geographical and logical coordinate extraction from parsed
/// transport maps.
///
/// For the geographical Underground map, converts SVG coordinates to
/// lat/lng using an affine transformation. For schematic maps, returns
/// coordinates in SVG space.
///
/// ```dart
/// final extractor = CoordinateExtractor(map);
///
/// // Geographical coordinates
/// final path = extractor.getGeoCoordinates('victoria');
///
/// // Schematic/logical coordinates
/// final logical = extractor.getLogicalPath('dlr');
/// ```
class CoordinateExtractor {
  /// Creates a [CoordinateExtractor] for the given [map].
  ///
  /// Optionally provide custom [controlPoints] for the affine transform.
  /// If not provided, the built-in control points for the geographical
  /// Underground map are used.
  CoordinateExtractor(
    this.map, {
    List<GeoControlPoint>? controlPoints,
  }) : _transform = AffineGeoTransform.fromControlPoints(
          controlPoints ?? geoMapControlPoints,
        );

  /// The parsed transport map to extract coordinates from.
  final TransportMap map;

  final AffineGeoTransform _transform;

  /// Returns geographical coordinates (lat/lng) for the given [lineId].
  ///
  /// Each [Offset] has `dx` = latitude, `dy` = longitude.
  ///
  /// Returns an empty list if the line is not found.
  ///
  /// ```dart
  /// final coords = extractor.getGeoCoordinates('victoria');
  /// for (final point in coords) {
  ///   print('Lat: ${point.dx}, Lng: ${point.dy}');
  /// }
  /// ```
  List<Offset> getGeoCoordinates(String lineId) {
    final line = map.getLine(lineId);
    if (line == null) return [];

    return line.segments
        .expand((s) => s.points)
        .map(_transform.svgToGeo)
        .toList();
  }

  /// Returns the geographical coordinate (lat/lng) for the station with
  /// the given [stationId].
  ///
  /// Returns `null` if the station is not found.
  ///
  /// ```dart
  /// final coord = extractor.getStationGeoCoordinate('oxford-circus');
  /// if (coord != null) {
  ///   print('Lat: ${coord.dx}, Lng: ${coord.dy}');
  /// }
  /// ```
  Offset? getStationGeoCoordinate(String stationId) {
    final station = map.stations[stationId];
    if (station == null) return null;
    return _transform.svgToGeo(station.position);
  }

  /// Returns the logical (SVG-space) path coordinates for the given
  /// [lineId].
  ///
  /// Returns an empty list if the line is not found.
  ///
  /// ```dart
  /// final path = extractor.getLogicalPath('dlr');
  /// ```
  List<Offset> getLogicalPath(String lineId) {
    final line = map.getLine(lineId);
    if (line == null) return [];
    return line.segments.expand((s) => s.points).toList();
  }

  /// Returns the raw SVG path `d` attribute strings for the given [lineId].
  ///
  /// Returns an empty list if the line is not found.
  ///
  /// ```dart
  /// final paths = extractor.getRawSvgPaths('central');
  /// for (final d in paths) {
  ///   print(d);
  /// }
  /// ```
  List<String> getRawSvgPaths(String lineId) {
    final line = map.getLine(lineId);
    if (line == null) return [];
    return line.segments.map((s) => s.rawSvgPath).toList();
  }
}

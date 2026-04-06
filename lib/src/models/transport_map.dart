import 'package:tube_map_utils/src/models/station.dart';
import 'package:tube_map_utils/src/models/svg_bounds.dart';
import 'package:tube_map_utils/src/models/transport_line.dart';
import 'package:tube_map_utils/src/models/transport_type.dart';

/// A parsed transport map containing lines, stations, and metadata.
///
/// This is the main data structure returned by parsing an SVG transport map.
/// It provides methods to query and filter the parsed data.
///
/// ```dart
/// final parser = SvgTransportMapParser();
/// final map = parser.parseString(svgContent);
///
/// // Get all lines
/// final lines = map.getAllLines();
///
/// // Filter by type
/// final underground = map.getLinesByType(TransportType.underground);
///
/// // Get a specific line
/// final victoria = map.getLine('victoria');
/// ```
class TransportMap {
  /// Creates a [TransportMap] with the given data.
  const TransportMap({
    required this.lines,
    required this.stations,
    required this.bounds,
  });

  /// All transport lines in this map, keyed by line ID.
  final Map<String, TransportLine> lines;

  /// All stations in this map, keyed by station ID.
  final Map<String, Station> stations;

  /// The SVG viewBox bounds of the source map.
  final SvgBounds bounds;

  /// Returns all transport lines in this map.
  ///
  /// ```dart
  /// final allLines = map.getAllLines();
  /// for (final line in allLines) {
  ///   print('${line.name}: ${line.segments.length} segments');
  /// }
  /// ```
  List<TransportLine> getAllLines() => lines.values.toList();

  /// Returns the transport line with the given [lineId], or `null` if not
  /// found.
  ///
  /// ```dart
  /// final bakerloo = map.getLine('bakerloo');
  /// ```
  TransportLine? getLine(String lineId) => lines[lineId];

  /// Returns all lines of the given [type].
  ///
  /// ```dart
  /// final dlrLines = map.getLinesByType(TransportType.dlr);
  /// ```
  List<TransportLine> getLinesByType(TransportType type) =>
      lines.values.where((line) => line.type == type).toList();

  /// Returns all stations associated with the given [lineId].
  ///
  /// ```dart
  /// final victoriaStations = map.getStationsForLine('victoria');
  /// ```
  List<Station> getStationsForLine(String lineId) =>
      stations.values
          .where((station) => station.lineIds.contains(lineId))
          .toList();

  /// Returns the station with the given [name], or `null` if not found.
  ///
  /// Performs a case-insensitive match against station names.
  ///
  /// ```dart
  /// final station = map.getStation('Oxford Circus');
  /// ```
  Station? getStation(String name) {
    final normalised = name.toLowerCase();
    for (final station in stations.values) {
      if (station.name.toLowerCase() == normalised) {
        return station;
      }
    }
    return null;
  }

  /// Returns all lines that serve the station with the given [stationId].
  ///
  /// ```dart
  /// final linesAtKingsCross = map.getLinesForStation('kings-cross-st-pancras');
  /// ```
  List<TransportLine> getLinesForStation(String stationId) {
    final station = stations[stationId];
    if (station == null) return [];
    return station.lineIds
        .map((id) => lines[id])
        .whereType<TransportLine>()
        .toList();
  }

  /// Returns the SVG viewBox bounds of the source map.
  ///
  /// ```dart
  /// final bounds = map.getMapBounds();
  /// print('${bounds.width} x ${bounds.height}');
  /// ```
  SvgBounds getMapBounds() => bounds;
}

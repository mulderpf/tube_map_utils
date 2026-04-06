import 'dart:ui';

import 'package:tube_map_utils/src/models/transport_type.dart';

/// Definition of a known transport line for identification during parsing.
class LineDefinition {
  /// Creates a [LineDefinition].
  const LineDefinition({
    required this.id,
    required this.name,
    required this.color,
    required this.type,
    this.geoSvgIds = const [],
    this.schematicCssClasses = const [],
  });

  /// Unique kebab-case identifier.
  final String id;

  /// Human-readable name.
  final String name;

  /// Official line colour.
  final Color color;

  /// Transport type classification.
  final TransportType type;

  /// SVG element IDs used in the geographical map (e.g., `'Victoria Line'`).
  final List<String> geoSvgIds;

  /// CSS class prefixes used in the schematic map (e.g., `'victoria'`
  /// matches `.svictoria` stroke class).
  final List<String> schematicCssClasses;
}

/// All known London transport lines with their SVG identifiers and colours.
///
/// Colours are sourced from official TfL brand guidelines and the SVG files.
const List<LineDefinition> knownLines = [
  // Underground lines
  LineDefinition(
    id: 'bakerloo',
    name: 'Bakerloo',
    color: Color(0xFFAE6017),
    type: TransportType.underground,
    geoSvgIds: ['Bakerloo Line'],
    schematicCssClasses: ['bakerloo'],
  ),
  LineDefinition(
    id: 'central',
    name: 'Central',
    color: Color(0xFFF15B2E),
    type: TransportType.underground,
    geoSvgIds: ['Central Line'],
    schematicCssClasses: ['central'],
  ),
  LineDefinition(
    id: 'circle',
    name: 'Circle',
    color: Color(0xFFFFCE00),
    type: TransportType.underground,
    geoSvgIds: ['Circle Line'],
    schematicCssClasses: ['circle'],
  ),
  LineDefinition(
    id: 'district',
    name: 'District',
    color: Color(0xFF00A166),
    type: TransportType.underground,
    geoSvgIds: ['District Line'],
    schematicCssClasses: ['district'],
  ),
  LineDefinition(
    id: 'hammersmith-city',
    name: 'Hammersmith & City',
    color: Color(0xFFF491A8),
    type: TransportType.underground,
    geoSvgIds: ['H&C Line 1'],
    schematicCssClasses: ['hnc'],
  ),
  LineDefinition(
    id: 'jubilee',
    name: 'Jubilee',
    color: Color(0xFF949699),
    type: TransportType.underground,
    geoSvgIds: ['Jubilee Line'],
    schematicCssClasses: ['jubilee'],
  ),
  LineDefinition(
    id: 'metropolitan',
    name: 'Metropolitan',
    color: Color(0xFF91005A),
    type: TransportType.underground,
    geoSvgIds: ['Metropolitan Line'],
    schematicCssClasses: ['metropolitan'],
  ),
  LineDefinition(
    id: 'northern',
    name: 'Northern',
    color: Color(0xFF000000),
    type: TransportType.underground,
    geoSvgIds: ['Northern Line'],
    schematicCssClasses: ['northern'],
  ),
  LineDefinition(
    id: 'piccadilly',
    name: 'Piccadilly',
    color: Color(0xFF094FA3),
    type: TransportType.underground,
    geoSvgIds: ['Piccadilly Line'],
    schematicCssClasses: ['piccadilly'],
  ),
  LineDefinition(
    id: 'victoria',
    name: 'Victoria',
    color: Color(0xFF0A9CDA),
    type: TransportType.underground,
    geoSvgIds: ['Victoria Line'],
    schematicCssClasses: ['victoria'],
  ),
  LineDefinition(
    id: 'waterloo-city',
    name: 'Waterloo & City',
    color: Color(0xFF88D0C4),
    type: TransportType.underground,
    geoSvgIds: ['Waterloo & City Line'],
    schematicCssClasses: ['wnc'],
  ),

  // DLR
  LineDefinition(
    id: 'dlr',
    name: 'DLR',
    color: Color(0xFF00A4A7),
    type: TransportType.dlr,
    geoSvgIds: [],
    schematicCssClasses: ['dlr'],
  ),

  // Elizabeth line
  LineDefinition(
    id: 'elizabeth',
    name: 'Elizabeth',
    color: Color(0xFF7156A5),
    type: TransportType.elizabeth,
    geoSvgIds: [],
    schematicCssClasses: ['elizabeth'],
  ),

  // Overground lines
  LineDefinition(
    id: 'liberty',
    name: 'Liberty',
    color: Color(0xFF5E6867),
    type: TransportType.overground,
    geoSvgIds: [],
    schematicCssClasses: ['liberty'],
  ),
  LineDefinition(
    id: 'lioness',
    name: 'Lioness',
    color: Color(0xFFFEB231),
    type: TransportType.overground,
    geoSvgIds: [],
    schematicCssClasses: ['lioness'],
  ),
  LineDefinition(
    id: 'mildmay',
    name: 'Mildmay',
    color: Color(0xFF3784C7),
    type: TransportType.overground,
    geoSvgIds: [],
    schematicCssClasses: ['mildmay'],
  ),
  LineDefinition(
    id: 'suffragette',
    name: 'Suffragette',
    color: Color(0xFF49C07D),
    type: TransportType.overground,
    geoSvgIds: [],
    schematicCssClasses: ['suffragette'],
  ),
  LineDefinition(
    id: 'weaver',
    name: 'Weaver',
    color: Color(0xFF9A2C62),
    type: TransportType.overground,
    geoSvgIds: [],
    schematicCssClasses: ['weaver'],
  ),
  LineDefinition(
    id: 'windrush',
    name: 'Windrush',
    color: Color(0xFFFF4E5A),
    type: TransportType.overground,
    geoSvgIds: [],
    schematicCssClasses: ['windrush'],
  ),

  // Tram
  LineDefinition(
    id: 'tram',
    name: 'London Trams',
    color: Color(0xFF5BB000),
    type: TransportType.tram,
    geoSvgIds: [],
    schematicCssClasses: ['tl'],
  ),
];

/// Map of stroke colour hex (lowercase, without #) to line definition.
///
/// Used as a fallback when SVG elements lack identifiable IDs or classes.
final Map<String, LineDefinition> colorToLine = {
  for (final line in knownLines)
    line.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2): line,
};

/// Map of geo SVG element ID to line definition.
final Map<String, LineDefinition> geoIdToLine = {
  for (final line in knownLines)
    for (final id in line.geoSvgIds) id: line,
};

/// Map of schematic CSS class suffix to line definition.
///
/// E.g., `'bakerloo'` maps to the Bakerloo line definition, matching
/// classes like `.sbakerloo` (stroke) and `.fbakerloo` (fill).
final Map<String, LineDefinition> schematicClassToLine = {
  for (final line in knownLines)
    for (final cls in line.schematicCssClasses) cls: line,
};

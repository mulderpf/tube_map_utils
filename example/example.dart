// ignore_for_file: avoid_print

import 'package:tube_map_utils/tube_map_utils.dart';

/// Example demonstrating the main features of tube_map_utils.
///
/// This example uses a minimal SVG for demonstration. In practice,
/// you would load the bundled SVG assets from the package.
void main() {
  // 1. Parse an SVG string into a TransportMap
  final parser = SvgTransportMapParser();
  final map = parser.parseString(_exampleSvg);

  // 2. List all parsed lines
  print('=== All Lines ===');
  for (final line in map.getAllLines()) {
    print('${line.name} (${line.type.name}): '
        '${line.segments.length} segment(s)');
  }

  // 3. Filter lines by transport type
  print('\n=== Underground Lines ===');
  final underground = map.getLinesByType(TransportType.underground);
  for (final line in underground) {
    print('  ${line.name}');
  }

  // 4. Get a specific line
  print('\n=== Victoria Line Details ===');
  final victoria = map.getLine('victoria');
  if (victoria != null) {
    print('  Name: ${victoria.name}');
    print('  Segments: ${victoria.segments.length}');
    print('  Points in first segment: '
        '${victoria.segments.first.points.length}');
  }

  // 5. Query stations
  print('\n=== Stations ===');
  for (final station in map.stations.values) {
    print('  ${station.name} at ${station.position} '
        '(lines: ${station.lineIds.join(", ")})');
  }

  // 6. Coordinate extraction
  print('\n=== Coordinate Extraction ===');
  final extractor = CoordinateExtractor(map);

  final logicalPath = extractor.getLogicalPath('victoria');
  print('  Victoria logical path: ${logicalPath.length} points');

  final rawPaths = extractor.getRawSvgPaths('victoria');
  print('  Victoria raw SVG paths: ${rawPaths.length}');

  // 7. Path math
  print('\n=== Path Math ===');
  final pathMath = PathMath(map);

  final length = pathMath.getPathLength('victoria');
  print('  Victoria path length: ${length?.toStringAsFixed(1)} units');

  final start = pathMath.getPositionAtProgress('victoria', 0.0);
  final mid = pathMath.getPositionAtProgress('victoria', 0.5);
  final end = pathMath.getPositionAtProgress('victoria', 1.0);
  print('  Start: $start');
  print('  Midpoint: $mid');
  print('  End: $end');

  final bearing = pathMath.getBearingAtProgress('victoria', 0.25);
  print('  Bearing at 25%: ${bearing?.toStringAsFixed(1)}°');

  // 8. Map bounds
  print('\n=== Map Bounds ===');
  final bounds = map.getMapBounds();
  print('  ViewBox: ${bounds.x}, ${bounds.y}, '
      '${bounds.width}, ${bounds.height}');

  // 9. Caching
  print('\n=== Caching ===');
  final map2 = parser.parseString(_exampleSvg);
  print('  Same instance (cached): ${identical(map, map2)}');
  print('  Cache size: ${parser.cacheSize}');
  parser.clearCache();
  print('  Cache cleared. Size: ${parser.cacheSize}');
}

/// Minimal SVG for demonstration purposes.
const _exampleSvg = '''
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg"
     width="6000" height="3500" viewBox="0 0 6000 3500">
  <path id="Victoria Line"
        d="M 3500,1400 L 3500,1800 L 3500,2200 L 3540,2700"
        fill="none" stroke="#0a9cda" stroke-width="4.5"/>
  <path id="Bakerloo Line"
        d="M 3200,1600 L 3400,1900 L 3500,2200"
        fill="none" stroke="#894e24" stroke-width="4.5"/>
  <text x="3500" y="1390" font-size="11">
    <tspan x="3500" y="1390">Warren Street</tspan>
  </text>
  <text x="3500" y="2190" font-size="11">
    <tspan x="3500" y="2190">Oxford Circus</tspan>
  </text>
</svg>
''';

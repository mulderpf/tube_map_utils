# tube_map_utils

A Flutter package for extracting structured data from London transport SVG maps (Underground, Overground, DLR, Elizabeth line).

Parse maps into queryable Dart models with coordinate extraction and path math utilities. **This is a data-only package** — rendering is your app's responsibility.

## Features

- **SVG Parsing** — Parse Wikimedia Commons London transport SVGs into structured Dart models (lines, stations, paths)
- **Line Filtering** — Query specific lines by ID, filter by transport type (Underground, Overground, DLR, Elizabeth, Tram)
- **Coordinate Extraction** — Get geographical (lat/lng) or logical (SVG-space) coordinates for lines and stations
- **Path Math** — Point-at-progress, bearing, distance, and nearest-point utilities for vehicle/marker positioning
- **Caching** — Parsed results cached in memory for repeated access

## Getting Started

This package is not published to pub.dev. Add it directly from GitHub in your `pubspec.yaml`:

```yaml
dependencies:
  tube_map_utils:
    git:
      url: https://github.com/mulderpf/tube_map_utils.git
```

Or pin a specific ref:

```yaml
dependencies:
  tube_map_utils:
    git:
      url: https://github.com/mulderpf/tube_map_utils.git
      ref: main
```

## Usage

### Parse an SVG map

```dart
import 'package:tube_map_utils/tube_map_utils.dart';

final parser = SvgTransportMapParser();
final map = parser.parseString(svgContent);
```

### Query and filter lines

```dart
// Get all lines
final allLines = map.getAllLines();

// Get a specific line
final victoria = map.getLine('victoria');

// Filter by transport type
final underground = map.getLinesByType(TransportType.underground);

// Get stations for a line
final stations = map.getStationsForLine('victoria');
```

### Extract coordinates

```dart
final extractor = CoordinateExtractor(map);

// Geographical coordinates (lat/lng) from the geo map
final geoPath = extractor.getGeoCoordinates('victoria');
final stationCoord = extractor.getStationGeoCoordinate('oxford-circus');

// Logical coordinates (SVG space) from schematic map
final logicalPath = extractor.getLogicalPath('dlr');

// Raw SVG path data for custom rendering
final rawPaths = extractor.getRawSvgPaths('central');
```

### Path math for vehicle/marker positioning

```dart
final pathMath = PathMath(map);

// Position at 45% along the line (0.0 = start, 1.0 = end)
final position = pathMath.getPositionAtProgress('bakerloo', 0.45);

// Bearing for marker rotation
final bearing = pathMath.getBearingAtProgress('bakerloo', 0.45);

// Path length and distance-based positioning
final length = pathMath.getPathLength('victoria');
final point = pathMath.getPointAtDistance('victoria', 500.0);

// Find nearest point on a line to a coordinate
final nearest = pathMath.getNearestPoint('victoria', someCoordinate);
```

See the [example](example/example.dart) for a full demonstration.

## SVG Map Sources

The bundled SVG maps are sourced from Wikimedia Commons and licensed under
[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/):

- [London Underground full map](https://commons.wikimedia.org/wiki/File:London_Underground_full_map.svg) (geographical)
- [London Underground, Overground, DLR, Elizabeth line map](https://commons.wikimedia.org/wiki/File:London_Underground_Overground_DLR_Crossrail_map_alt.svg) (schematic)

See [ATTRIBUTION.md](ATTRIBUTION.md) for full attribution details.

## License

The SVG map assets are licensed under CC BY-SA 4.0. See [LICENSE](LICENSE) for the full text.

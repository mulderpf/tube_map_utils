/// Extract structured data from London transport SVG maps.
///
/// Parse Underground, Overground, DLR, and Elizabeth line maps into
/// queryable models with coordinate extraction and path math utilities.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:tube_map_utils/tube_map_utils.dart';
///
/// final parser = SvgTransportMapParser();
/// final map = parser.parseString(svgContent);
///
/// // Query lines
/// final victoria = map.getLine('victoria');
/// final underground = map.getLinesByType(TransportType.underground);
///
/// // Extract coordinates
/// final extractor = CoordinateExtractor(map);
/// final geoPath = extractor.getGeoCoordinates('victoria');
///
/// // Path math
/// final pathMath = PathMath(map);
/// final midpoint = pathMath.getPositionAtProgress('victoria', 0.5);
/// ```
library;

// Models
export 'src/coordinates/affine_transform.dart'
    show AffineGeoTransform, GeoControlPoint;
export 'src/coordinates/control_points.dart' show geoMapControlPoints;
export 'src/coordinates/coordinate_extractor.dart' show CoordinateExtractor;
export 'src/models/path_segment.dart' show PathSegment;
export 'src/models/station.dart' show Station;
export 'src/models/svg_bounds.dart' show SvgBounds;
export 'src/models/transport_line.dart' show TransportLine;
export 'src/models/transport_map.dart' show TransportMap;
export 'src/models/transport_type.dart' show TransportType;
// Parsing
export 'src/parsing/svg_parser.dart' show SvgTransportMapParser;
// Path Math
export 'src/path_math/path_math.dart' show NearestPointResult, PathMath;

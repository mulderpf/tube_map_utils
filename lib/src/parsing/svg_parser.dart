import 'dart:ui';

import 'package:path_parsing/path_parsing.dart';
import 'package:xml/xml.dart';

import 'package:tube_map_utils/src/models/path_segment.dart';
import 'package:tube_map_utils/src/models/station.dart';
import 'package:tube_map_utils/src/models/svg_bounds.dart';
import 'package:tube_map_utils/src/models/transport_line.dart';
import 'package:tube_map_utils/src/models/transport_map.dart';
import 'package:tube_map_utils/src/parsing/line_definitions.dart';

/// Parses London transport SVG maps into structured [TransportMap] data.
///
/// Supports both the geographical Underground map and the schematic
/// Overground/DLR/Elizabeth line map from Wikimedia Commons.
///
/// ```dart
/// final parser = SvgTransportMapParser();
/// final map = parser.parseString(svgContent);
///
/// final lines = map.getAllLines();
/// final victoria = map.getLine('victoria');
/// ```
class SvgTransportMapParser {
  /// Creates an [SvgTransportMapParser].
  ///
  /// Parsed results are cached in memory. Use [clearCache] to free memory.
  SvgTransportMapParser();

  final Map<int, TransportMap> _cache = {};

  /// Parses an SVG string into a [TransportMap].
  ///
  /// The parser identifies transport lines by matching SVG element IDs,
  /// CSS classes, and stroke colours against a built-in mapping table of
  /// known London transport lines.
  ///
  /// Results are cached by content hash. Calling this method with the same
  /// SVG string will return the cached result.
  ///
  /// ```dart
  /// final map = parser.parseString(svgContent);
  /// ```
  TransportMap parseString(String svgContent) {
    final cacheKey = svgContent.hashCode;
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final document = XmlDocument.parse(svgContent);
    final svg = document.rootElement;
    final bounds = _parseBounds(svg);
    final lines = <String, TransportLine>{};
    final stations = <String, Station>{};

    // Collect path data per line definition
    final lineSegments = <String, List<PathSegment>>{};

    // Parse all path elements in the document, skipping those inside
    // <defs> (markers, symbols, etc.) or decorative groups (zone masks)
    for (final path in svg.descendants.whereType<XmlElement>()) {
      if (path.name.local != 'path') continue;
      if (_isInsideDefs(path)) continue;
      if (_isDecorativePath(path)) continue;

      final d = path.getAttribute('d');
      if (d == null || d.isEmpty) continue;

      final lineDef = _identifyLine(path);
      if (lineDef == null) continue;

      final subPaths = _parseSvgPath(d);
      if (subPaths.isEmpty) continue;

      lineSegments.putIfAbsent(lineDef.id, () => []);

      // Each subpath (delimited by M commands) becomes its own segment
      for (final points in subPaths) {
        if (points.isEmpty) continue;

        // Filter out segments whose points fall entirely outside the
        // SVG viewport — these are transformed decorative elements
        // (e.g., zone masks in a translated group)
        if (!_hasPointsInBounds(points, bounds)) continue;

        lineSegments[lineDef.id]!.add(
          PathSegment(points: points, rawSvgPath: d),
        );
      }
    }

    // Build TransportLine objects
    for (final def in knownLines) {
      final segments = lineSegments[def.id];
      if (segments == null || segments.isEmpty) continue;

      lines[def.id] = TransportLine(
        id: def.id,
        name: def.name,
        color: def.color,
        type: def.type,
        segments: segments,
      );
    }

    // Parse stations from text elements
    for (final text in svg.descendants.whereType<XmlElement>()) {
      if (text.name.local != 'text') continue;

      final station = _parseStation(text, lines);
      if (station != null) {
        stations[station.id] = station;
      }
    }

    final result = TransportMap(
      lines: lines,
      stations: stations,
      bounds: bounds,
    );

    _cache[cacheKey] = result;
    return result;
  }

  /// Clears all cached parse results, freeing memory.
  void clearCache() => _cache.clear();

  /// Returns the number of cached parse results.
  int get cacheSize => _cache.length;

  SvgBounds _parseBounds(XmlElement svg) {
    final viewBox = svg.getAttribute('viewBox');
    if (viewBox != null) {
      final parts = viewBox.split(RegExp(r'[\s,]+'));
      if (parts.length == 4) {
        return SvgBounds(
          x: double.tryParse(parts[0]) ?? 0,
          y: double.tryParse(parts[1]) ?? 0,
          width: double.tryParse(parts[2]) ?? 0,
          height: double.tryParse(parts[3]) ?? 0,
        );
      }
    }

    final width =
        double.tryParse(svg.getAttribute('width') ?? '') ?? 0;
    final height =
        double.tryParse(svg.getAttribute('height') ?? '') ?? 0;
    return SvgBounds(x: 0, y: 0, width: width, height: height);
  }

  LineDefinition? _identifyLine(XmlElement path) {
    // 1. Check element ID against geo SVG IDs
    final id = path.getAttribute('id') ?? '';
    if (id.isNotEmpty) {
      final byGeoId = geoIdToLine[id];
      if (byGeoId != null) return byGeoId;
    }

    // 2. Check CSS class against schematic classes
    final cssClass = path.getAttribute('class') ?? '';
    if (cssClass.isNotEmpty) {
      for (final cls in cssClass.split(RegExp(r'\s+'))) {
        // Match stroke classes like "sbakerloo", "scentral"
        if (cls.startsWith('s') && cls.length > 1) {
          final suffix = cls.substring(1);
          final byClass = schematicClassToLine[suffix];
          if (byClass != null) return byClass;
        }
      }
    }

    // 3. Check parent group's class/id
    final parent = path.parentElement;
    if (parent != null) {
      final parentClass = parent.getAttribute('class') ?? '';
      for (final cls in parentClass.split(RegExp(r'\s+'))) {
        if (cls.startsWith('s') && cls.length > 1) {
          final suffix = cls.substring(1);
          final byClass = schematicClassToLine[suffix];
          if (byClass != null) return byClass;
        }
      }
    }

    // 4. Fallback: match stroke colour
    final stroke = _getStrokeColor(path);
    if (stroke != null) {
      final byColor = colorToLine[stroke];
      if (byColor != null) return byColor;
    }

    return null;
  }

  String? _getStrokeColor(XmlElement element) {
    // Check inline stroke attribute
    final stroke = element.getAttribute('stroke');
    if (stroke != null && stroke.startsWith('#')) {
      return _normalizeHexColor(stroke);
    }

    // Check style attribute
    final style = element.getAttribute('style') ?? '';
    final match = RegExp(r'stroke:\s*#([0-9a-fA-F]{3,6})').firstMatch(style);
    if (match != null) {
      return _normalizeHexColor('#${match.group(1)!}');
    }

    return null;
  }

  static bool _isDecorativePath(XmlElement path) {
    // Skip paths with fill-opacity (zone masks, decorative overlays)
    final fillOpacity = path.getAttribute('fill-opacity');
    if (fillOpacity != null) return true;

    // Skip paths with a fill colour — transport lines use fill="none".
    // Decorative paths (station markers, graphics) often have a fill.
    final fill = path.getAttribute('fill');
    if (fill != null && fill != 'none') return true;

    // Also check style attribute for fill
    final style = path.getAttribute('style') ?? '';
    if (style.contains('fill-opacity')) return true;

    // Skip paths whose id suggests non-transport geometry
    final id = path.getAttribute('id') ?? '';
    if (id.contains('mask') || id.contains('Zone') ||
        id.contains('Thames')) {
      return true;
    }

    return false;
  }

  static bool _hasPointsInBounds(List<Offset> points, SvgBounds bounds) {
    final minX = bounds.x - bounds.width * 0.1;
    final maxX = bounds.x + bounds.width * 1.1;
    final minY = bounds.y - bounds.height * 0.1;
    final maxY = bounds.y + bounds.height * 1.1;

    for (final p in points) {
      if (p.dx >= minX && p.dx <= maxX && p.dy >= minY && p.dy <= maxY) {
        return true;
      }
    }
    return false;
  }

  static bool _isInsideDefs(XmlElement element) {
    XmlNode? current = element.parentElement;
    while (current is XmlElement) {
      if (current.name.local == 'defs') return true;
      current = current.parentElement;
    }
    return false;
  }

  static String _normalizeHexColor(String hex) {
    var h = hex.replaceFirst('#', '').toLowerCase();
    if (h.length == 3) {
      h = '${h[0]}${h[0]}${h[1]}${h[1]}${h[2]}${h[2]}';
    }
    return h;
  }

  Station? _parseStation(
    XmlElement text,
    Map<String, TransportLine> lines,
  ) {
    // Extract station name from text/tspan content
    final name = _extractTextContent(text).trim();
    if (name.isEmpty) return null;

    // Skip non-station text (zone labels, legends, etc.)
    if (_isNonStationText(name, text)) return null;

    // Get position from x/y attributes
    final x = double.tryParse(text.getAttribute('x') ?? '');
    final y = double.tryParse(text.getAttribute('y') ?? '');
    if (x == null || y == null) return null;

    final stationId = _normalizeId(name);

    // Determine which lines serve this station by proximity
    // (simplified: associate with all lines for now)
    final lineIds = <String>[];
    for (final line in lines.values) {
      for (final segment in line.segments) {
        if (_isNearPath(Offset(x, y), segment.points, threshold: 60)) {
          lineIds.add(line.id);
          break;
        }
      }
    }

    return Station(
      id: stationId,
      name: name,
      position: Offset(x, y),
      lineIds: lineIds,
    );
  }

  String _extractTextContent(XmlElement text) {
    final buffer = StringBuffer();
    for (final node in text.descendants) {
      if (node is XmlText) {
        final content = node.value.trim();
        if (content.isNotEmpty) {
          if (buffer.isNotEmpty) buffer.write(' ');
          buffer.write(content);
        }
      }
    }
    return buffer.toString();
  }

  bool _isNonStationText(String text, XmlElement element) {
    // Skip zone labels
    final cssClass = element.getAttribute('class') ?? '';
    if (cssClass.contains('zone')) return true;

    // Skip very short text (likely labels like "N", "S")
    if (text.length < 3) return true;

    // Skip text containing "Zone" or copyright
    final lower = text.toLowerCase();
    if (lower.contains('zone') ||
        lower.contains('©') ||
        lower.contains('license') ||
        lower.contains('creative commons') ||
        lower.contains('alternative route map')) {
      return true;
    }

    return false;
  }

  static bool _isNearPath(
    Offset point,
    List<Offset> path, {
    required double threshold,
  }) {
    for (final p in path) {
      final dx = point.dx - p.dx;
      final dy = point.dy - p.dy;
      if (dx * dx + dy * dy < threshold * threshold) {
        return true;
      }
    }
    return false;
  }

  /// Normalises a station name to a kebab-case ID.
  static String _normalizeId(String name) {
    return name
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r"[''']"), '')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}

/// Parses an SVG path `d` attribute string into a list of subpaths.
///
/// Each subpath (delimited by `M` commands) is a separate `List<Offset>`.
/// Uses the `path_parsing` package to handle all SVG path commands
/// (M, L, C, S, Q, T, A, Z, and relative variants).
List<List<Offset>> _parseSvgPath(String d) {
  final proxy = _PointCollectingProxy();
  writeSvgPathDataToPath(d, proxy);
  return proxy.getSubPaths();
}

class _PointCollectingProxy extends PathProxy {
  _PointCollectingProxy();

  final List<List<Offset>> _subPaths = [];
  List<Offset> _currentPoints = [];
  double _currentX = 0;
  double _currentY = 0;

  /// Returns all collected subpaths, finalising the current one.
  List<List<Offset>> getSubPaths() {
    if (_currentPoints.isNotEmpty) {
      _subPaths.add(_currentPoints);
    }
    return _subPaths;
  }

  @override
  void close() {
    // No-op for point collection
  }

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    // Sample cubic bezier at intervals for reasonable point density
    const steps = 8;
    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      final mt = 1 - t;
      final x = mt * mt * mt * _currentX +
          3 * mt * mt * t * x1 +
          3 * mt * t * t * x2 +
          t * t * t * x3;
      final y = mt * mt * mt * _currentY +
          3 * mt * mt * t * y1 +
          3 * mt * t * t * y2 +
          t * t * t * y3;
      _currentPoints.add(Offset(x, y));
    }
    _currentX = x3;
    _currentY = y3;
  }

  @override
  void lineTo(double x, double y) {
    _currentPoints.add(Offset(x, y));
    _currentX = x;
    _currentY = y;
  }

  @override
  void moveTo(double x, double y) {
    // Start a new subpath — finalise current points if non-empty
    if (_currentPoints.isNotEmpty) {
      _subPaths.add(_currentPoints);
      _currentPoints = [];
    }
    _currentPoints.add(Offset(x, y));
    _currentX = x;
    _currentY = y;
  }
}

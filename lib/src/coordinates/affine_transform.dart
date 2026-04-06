import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

/// A control point mapping an SVG coordinate to a geographical coordinate.
///
/// Used to compute the affine transformation between SVG space and
/// geographical (lat/lng) space.
class GeoControlPoint {
  /// Creates a [GeoControlPoint].
  const GeoControlPoint({
    required this.svgX,
    required this.svgY,
    required this.lat,
    required this.lng,
  });

  /// X coordinate in SVG space.
  final double svgX;

  /// Y coordinate in SVG space.
  final double svgY;

  /// Latitude (WGS84).
  final double lat;

  /// Longitude (WGS84).
  final double lng;
}

/// Computes and applies an affine transformation from SVG coordinates to
/// geographical coordinates (lat/lng).
///
/// Uses a least-squares fit from 3 or more control points to compute the
/// transformation matrix.
///
/// ```dart
/// final transform = AffineGeoTransform.fromControlPoints(controlPoints);
/// final latLng = transform.svgToGeo(Offset(3000, 1750));
/// print('Lat: ${latLng.dx}, Lng: ${latLng.dy}');
/// ```
class AffineGeoTransform {
  /// Creates an [AffineGeoTransform] from a precomputed matrix.
  AffineGeoTransform._(this._latTransform, this._lngTransform);

  /// Computes the affine transform from the given [controlPoints].
  ///
  /// Requires at least 3 control points for a valid affine transform.
  /// More points produce a least-squares best fit.
  ///
  /// Throws [ArgumentError] if fewer than 3 points are provided.
  factory AffineGeoTransform.fromControlPoints(
    List<GeoControlPoint> controlPoints,
  ) {
    if (controlPoints.length < 3) {
      throw ArgumentError(
        'At least 3 control points required, got ${controlPoints.length}',
      );
    }

    // Solve for lat = a*x + b*y + c and lng = d*x + e*y + f
    // Using least-squares: A^T * A * params = A^T * b
    final n = controlPoints.length;
    final a = Matrix3.zero();
    final bLat = Vector3.zero();
    final bLng = Vector3.zero();

    for (var i = 0; i < n; i++) {
      final cp = controlPoints[i];
      final x = cp.svgX;
      final y = cp.svgY;

      // Accumulate A^T * A
      a.setEntry(0, 0, a.entry(0, 0) + x * x);
      a.setEntry(0, 1, a.entry(0, 1) + x * y);
      a.setEntry(0, 2, a.entry(0, 2) + x);
      a.setEntry(1, 0, a.entry(1, 0) + x * y);
      a.setEntry(1, 1, a.entry(1, 1) + y * y);
      a.setEntry(1, 2, a.entry(1, 2) + y);
      a.setEntry(2, 0, a.entry(2, 0) + x);
      a.setEntry(2, 1, a.entry(2, 1) + y);
      a.setEntry(2, 2, a.entry(2, 2) + 1);

      // Accumulate A^T * b
      bLat.setValues(
        bLat.x + x * cp.lat,
        bLat.y + y * cp.lat,
        bLat.z + cp.lat,
      );
      bLng.setValues(
        bLng.x + x * cp.lng,
        bLng.y + y * cp.lng,
        bLng.z + cp.lng,
      );
    }

    // Solve A * params = b
    final aInv = Matrix3.copy(a)..invert();
    final latParams = aInv.transformed(bLat);
    final lngParams = aInv.transformed(bLng);

    return AffineGeoTransform._(latParams, lngParams);
  }

  final Vector3 _latTransform;
  final Vector3 _lngTransform;

  /// Transforms an SVG coordinate [point] to geographical coordinates.
  ///
  /// Returns an [Offset] where `dx` is latitude and `dy` is longitude.
  ///
  /// ```dart
  /// final geo = transform.svgToGeo(Offset(3500, 2000));
  /// print('Lat: ${geo.dx}, Lng: ${geo.dy}');
  /// ```
  Offset svgToGeo(Offset point) {
    final lat = _latTransform.x * point.dx +
        _latTransform.y * point.dy +
        _latTransform.z;
    final lng = _lngTransform.x * point.dx +
        _lngTransform.y * point.dy +
        _lngTransform.z;
    return Offset(lat, lng);
  }
}

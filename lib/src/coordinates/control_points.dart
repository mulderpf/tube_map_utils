import 'package:tube_map_utils/src/coordinates/affine_transform.dart';

/// Known control points for the geographical Underground map SVG.
///
/// These map SVG pixel coordinates to real-world lat/lng positions for
/// well-known stations whose positions can be verified. Used to compute
/// the affine transformation from SVG space to geographical coordinates.
///
/// SVG coordinates are approximate, taken from the geographical map at
/// 6000x3500 pixel resolution.
const List<GeoControlPoint> geoMapControlPoints = [
  // King's Cross St Pancras
  GeoControlPoint(
    svgX: 3498,
    svgY: 1836,
    lat: 51.5303,
    lng: -0.1238,
  ),
  // Heathrow Terminal 5
  GeoControlPoint(
    svgX: 1280,
    svgY: 2480,
    lat: 51.4723,
    lng: -0.4901,
  ),
  // Epping
  GeoControlPoint(
    svgX: 5100,
    svgY: 640,
    lat: 51.6937,
    lng: 0.1139,
  ),
  // Brixton
  GeoControlPoint(
    svgX: 3538,
    svgY: 2712,
    lat: 51.4627,
    lng: -0.1145,
  ),
  // Stanmore
  GeoControlPoint(
    svgX: 2712,
    svgY: 876,
    lat: 51.6194,
    lng: -0.3028,
  ),
];

import 'package:tube_map_utils/src/coordinates/affine_transform.dart';

/// Known control points for the geographical Underground map SVG.
///
/// These map SVG pixel coordinates to real-world lat/lng positions for
/// well-known stations whose positions can be verified. Used to compute
/// the affine transformation from SVG space to geographical coordinates.
///
/// SVG coordinates measured from station markers/path endpoints in the
/// bundled `london_underground_full_map.svg` (6000x3500 pixels).
const List<GeoControlPoint> geoMapControlPoints = [
  // King's Cross St Pancras — <use> element at translate(2789.12,1905.37)
  // plus x=571.05, y=64.27
  GeoControlPoint(
    svgX: 3360,
    svgY: 1970,
    lat: 51.5303,
    lng: -0.1238,
  ),
  // Heathrow Terminal 5 — station marker at line endpoints near
  // x=1011, y=2575
  GeoControlPoint(
    svgX: 1011,
    svgY: 2575,
    lat: 51.4723,
    lng: -0.4901,
  ),
  // Epping — Central Line path starts at M 4874.525,309.31
  GeoControlPoint(
    svgX: 4875,
    svgY: 309,
    lat: 51.6937,
    lng: 0.1139,
  ),
  // Brixton — <use> element at translate(2788.87,1905.81)
  // plus x=630.31, y=758.56
  GeoControlPoint(
    svgX: 3419,
    svgY: 2664,
    lat: 51.4627,
    lng: -0.1145,
  ),
  // Stanmore — Jubilee Line path starts at m 2219.34,1066.79
  GeoControlPoint(
    svgX: 2219,
    svgY: 1067,
    lat: 51.6194,
    lng: -0.3028,
  ),
];

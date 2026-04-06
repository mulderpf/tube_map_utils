/// The type of transport service a line operates.
///
/// Used to filter and categorise lines from parsed transport maps.
///
/// ```dart
/// final undergroundLines = map.getLinesByType(TransportType.underground);
/// ```
enum TransportType {
  /// London Underground lines (e.g., Bakerloo, Central, Victoria).
  underground,

  /// London Overground lines (e.g., Liberty, Lioness, Mildmay).
  overground,

  /// Docklands Light Railway.
  dlr,

  /// Elizabeth line (formerly Crossrail).
  elizabeth,

  /// London Trams (Croydon Tramlink).
  tram,
}

/// A minimal SVG for testing the parser.
///
/// Contains:
/// - A viewBox
/// - Two named line paths (matching geo SVG IDs)
/// - A path with a schematic CSS class
/// - Text elements for stations
const String testSvg = '''
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="6000" height="3500" viewBox="0 0 6000 3500">
  <path id="Victoria Line" d="M 100,100 L 200,200 L 300,150" fill="none" stroke="#0a9cda" stroke-width="4.5"/>
  <path id="Bakerloo Line" d="M 400,400 L 500,500 L 600,450 L 700,400" fill="none" stroke="#894e24" stroke-width="4.5"/>
  <text x="150" y="90" font-size="11"><tspan x="150" y="90">Test Station A</tspan></text>
  <text x="450" y="390" font-size="11"><tspan x="450" y="390">Test Station B</tspan></text>
  <text x="3000" y="1750" font-size="11"><tspan x="3000" y="1750">Midpoint Station</tspan></text>
</svg>
''';

/// A minimal schematic SVG for testing CSS class-based line identification.
const String testSchematicSvg = '''
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="2500" height="1340" viewBox="-40.5 -120.5 2500 1340">
  <path class="me svictoria" d="M 50,50 L 150,150 L 250,100"/>
  <path class="me sbakerloo" d="M 300,300 L 400,400"/>
  <path class="me sdlr" d="M 500,100 L 600,200 L 700,150"/>
  <text x="100" y="40" font-size="14" class="st"><tspan x="100" y="40">Schematic Station</tspan></text>
</svg>
''';

/// An SVG with no recognisable transport lines.
const String emptySvg = '''
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <rect x="0" y="0" width="100" height="100" fill="red"/>
</svg>
''';

/// An SVG with a path using style attribute for stroke.
const String styleSvg = '''
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="6000" height="3500" viewBox="0 0 6000 3500">
  <path id="some-path" d="M 100,100 L 200,200" fill="none" style="stroke:#0a9cda;stroke-width:4.5"/>
</svg>
''';

/// An SVG where a path inherits class from parent group.
const String parentClassSvg = '''
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="2500" height="1340" viewBox="-40.5 -120.5 2500 1340">
  <g class="me sjubilee">
    <path d="M 100,100 L 200,200 L 300,150"/>
  </g>
</svg>
''';

/// An SVG with inline stroke matching a known line colour for colour fallback.
const String strokeColorSvg = '''
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="6000" height="3500" viewBox="0 0 6000 3500">
  <path d="M 100,100 L 200,200" fill="none" stroke="#894E24" stroke-width="4.5"/>
</svg>
''';

/// An SVG with a 3-character hex colour.
const String shortHexSvg = '''
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="6000" height="3500" viewBox="0 0 6000 3500">
  <path d="M 100,100 L 200,200" fill="none" stroke="#000" stroke-width="4.5"/>
</svg>
''';

/// An SVG with a closed path (Z command).
const String closedPathSvg = '''
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="6000" height="3500" viewBox="0 0 6000 3500">
  <path id="Victoria Line" d="M 100,100 L 200,200 L 300,100 Z" fill="none" stroke="#0a9cda" stroke-width="4.5"/>
</svg>
''';

/// An SVG with cubic bezier paths.
const String cubicSvg = '''
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="6000" height="3500" viewBox="0 0 6000 3500">
  <path id="Victoria Line" d="M 100,100 C 150,50 250,50 300,100" fill="none" stroke="#0a9cda" stroke-width="4.5"/>
</svg>
''';

/// An SVG with zone/non-station text that should be filtered out.
const String nonStationTextSvg = '''
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="6000" height="3500" viewBox="0 0 6000 3500">
  <path id="Victoria Line" d="M 100,100 L 200,200" fill="none" stroke="#0a9cda" stroke-width="4.5"/>
  <text x="100" y="100" class="zone" font-size="35"><tspan>Zone 1</tspan></text>
  <text x="200" y="200" font-size="11"><tspan>N</tspan></text>
  <text x="300" y="300" font-size="11"><tspan>© Creative Commons</tspan></text>
  <text x="150" y="90" font-size="11"><tspan x="150" y="90">Valid Station</tspan></text>
</svg>
''';

// Run: dart run tools/generate_icon.dart
// Requires: image package (already in pubspec via flutter_launcher_icons)
// Generates assets/icons/app_icon.png (1024x1024)
import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

void main() {
  const size = 1024;
  final image = img.Image(width: size, height: size);

  // Transparent background
  img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));

  // Green circle background
  const bgR = 0x2E, bgG = 0x7D, bgB = 0x32;
  img.fillCircle(
    image,
    x: size ~/ 2,
    y: size ~/ 2,
    radius: (size * 0.48).round(),
    color: img.ColorRgba8(bgR, bgG, bgB, 255),
  );

  // White outer ring (plate)
  img.fillCircle(
    image,
    x: size ~/ 2,
    y: (size * 0.38).round(),
    radius: (size * 0.20).round(),
    color: img.ColorRgba8(255, 255, 255, 255),
  );

  // Green inner circle (donut effect)
  img.fillCircle(
    image,
    x: size ~/ 2,
    y: (size * 0.38).round(),
    radius: (size * 0.13).round(),
    color: img.ColorRgba8(bgR, bgG, bgB, 255),
  );

  // Fork/spoon handle
  final hx = size ~/ 2 - (size * 0.04).round();
  final hy = (size * 0.55).round();
  final hw = (size * 0.08).round();
  final hh = (size * 0.33).round();
  img.fillRect(
    image,
    x1: hx,
    y1: hy,
    x2: hx + hw,
    y2: hy + hh,
    color: img.ColorRgba8(255, 255, 255, 255),
    radius: (hw * 0.4).round(),
  );

  // SN letters hint: two small squares (simplified branding)
  final lx = (size * 0.30).round();
  final rx = (size * 0.58).round();
  final ly = (size * 0.57).round();
  final ls = (size * 0.09).round();
  img.fillRect(
    image,
    x1: lx, y1: ly, x2: lx + ls, y2: ly + ls,
    color: img.ColorRgba8(255, 255, 255, 180),
    radius: (ls * 0.3).round(),
  );
  img.fillRect(
    image,
    x1: rx, y1: ly, x2: rx + ls, y2: ly + ls,
    color: img.ColorRgba8(255, 255, 255, 180),
    radius: (ls * 0.3).round(),
  );

  final outFile = File('assets/icons/app_icon.png');
  outFile.writeAsBytesSync(img.encodePng(image));
  print('Icon generated: ${outFile.path} (${size}x$size)');
  // Suppress unused import
  math.sqrt(0);
}

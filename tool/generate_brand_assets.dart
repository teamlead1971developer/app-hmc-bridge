// Generates the BRIDGE brand assets (dark logo + 1024px app icons) from the
// design tokens in lib/core/branding.dart.
//
// Run from the project root:
//   flutter test tool/generate_brand_assets.dart
// then regenerate the launcher icons:
//   dart run flutter_launcher_icons
//
// Spec: design_handoff_glass_redesign/README.md, "New logo & app icon".
// Mark geometry (from the 1k canvas, unit = bar-stack width 26):
//   top bar    14 high, 88% wide;  bottom bar 18 high, 100% wide;  gap 4;
//   left corners radius 2, right corners fully rounded.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _spaceGrotesk = 'SpaceGrotesk';

Future<void> _loadSpaceGrotesk() async {
  final bytes = File('assets/fonts/SpaceGrotesk.ttf').readAsBytesSync();
  final loader = FontLoader(_spaceGrotesk)
    ..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}

/// Draws the segmented-B mark with the bar-stack width [w]; returns its height.
double _drawMark(Canvas canvas, Offset origin, double w, Paint Function(Rect) paintFor) {
  final unit = w / 26;
  final topH = 14 * unit, bottomH = 18 * unit, gap = 4 * unit;
  final leftR = Radius.circular(2 * unit);

  RRect bar(double y, double width, double height) => RRect.fromRectAndCorners(
        Rect.fromLTWH(origin.dx, y, width, height),
        topLeft: leftR,
        bottomLeft: leftR,
        topRight: Radius.circular(height / 2),
        bottomRight: Radius.circular(height / 2),
      );

  final top = bar(origin.dy, w * 0.88, topH);
  final bottom = bar(origin.dy + topH + gap, w, bottomH);
  canvas.drawRRect(top, paintFor(top.outerRect));
  canvas.drawRRect(bottom, paintFor(bottom.outerRect));
  return topH + gap + bottomH;
}

Paint _gradientPaint(LinearGradient gradient, Rect rect) =>
    Paint()..shader = gradient.createShader(rect);

Future<void> _savePng(ui.Picture picture, int width, int height, String path) async {
  final image = await picture.toImage(width, height);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
  debugPrint('wrote $path (${width}x$height)');
}

/// Mark (red gradient) + white BRIDGE wordmark on transparent background.
Future<void> _logoDark() async {
  // 8x the 1k-canvas construction: mark 26 wide / 36 tall, wordmark 26px,
  // 12px gap, Space Grotesk 700 with 0.08em tracking.
  const scale = 8.0;
  const markW = 26 * scale;
  const gap = 12 * scale;
  const fontSize = 26 * scale;

  final wordmark = TextPainter(
    text: TextSpan(
      text: 'BRIDGE',
      style: TextStyle(
        fontFamily: _spaceGrotesk,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        fontVariations: const [ui.FontVariation('wght', 700)],
        letterSpacing: fontSize * 0.08,
        color: const Color(0xFFF5F5F6),
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  const markH = 36 * scale;
  final width = (markW + gap + wordmark.width).ceil();
  final height = markH.ceil();

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  // Mark: red gradient #C1201D -> #AC0F0D top to bottom across the stack.
  const gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFC1201D), Color(0xFFAC0F0D)],
  );
  final stackRect = Rect.fromLTWH(0, 0, markW, markH);
  _drawMark(canvas, Offset.zero, markW, (_) => _gradientPaint(gradient, stackRect));
  wordmark.paint(
    canvas,
    Offset(markW + gap, (height - wordmark.height) / 2),
  );
  await _savePng(recorder.endRecording(), width, height, 'assets/images/bridge_logo_dark.png');
}

void _drawIconBackground(Canvas canvas, double size) {
  final rect = Rect.fromLTWH(0, 0, size, size);
  // 150deg #C1201D -> #7A0B09.
  const gradient = LinearGradient(
    begin: Alignment(-0.5, -0.87),
    end: Alignment(0.5, 0.87),
    colors: [Color(0xFFC1201D), Color(0xFF7A0B09)],
  );
  canvas.drawRect(rect, _gradientPaint(gradient, rect));
  // Subtle inset top highlight.
  canvas.drawRect(
    Rect.fromLTWH(0, 0, size, size * 0.30),
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size, size * 0.30)),
  );
  // 1px inner border at canvas scale (1px on the 68px canvas comp ~ 12px here).
  final inset = size * 0.006;
  canvas.drawRect(
    rect.deflate(inset / 2 + 4),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = inset
      ..color = Colors.white.withValues(alpha: 0.22),
  );
}

void _drawIconMark(Canvas canvas, double size, double markW) {
  final markH = markW * 36 / 26;
  final origin = Offset((size - markW) / 2, (size - markH) / 2);
  final white = Paint()..color = Colors.white;
  _drawMark(canvas, origin, markW, (_) => white);
}

/// Full-bleed 1024 icon (platforms mask their own squircle) — white mark ~40%.
Future<void> _appIcon() async {
  const size = 1024.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  _drawIconBackground(canvas, size);
  _drawIconMark(canvas, size, size * 0.40);
  await _savePng(recorder.endRecording(), 1024, 1024, 'assets/icons/app_icon.png');
}

/// Android adaptive icon layers: gradient background + white mark foreground
/// (scaled down so it survives the adaptive-icon safe zone crop).
Future<void> _adaptiveLayers() async {
  const size = 1024.0;

  final bg = ui.PictureRecorder();
  _drawIconBackground(Canvas(bg), size);
  await _savePng(bg.endRecording(), 1024, 1024, 'assets/icons/app_icon_adaptive_bg.png');

  final fg = ui.PictureRecorder();
  _drawIconMark(Canvas(fg), size, size * 0.28);
  await _savePng(fg.endRecording(), 1024, 1024, 'assets/icons/app_icon_adaptive_fg.png');
}

void main() {
  testWidgets('generate brand assets', (tester) async {
    await tester.runAsync(() async {
      await _loadSpaceGrotesk();
      await _logoDark();
      await _appIcon();
      await _adaptiveLayers();
    });
  });
}

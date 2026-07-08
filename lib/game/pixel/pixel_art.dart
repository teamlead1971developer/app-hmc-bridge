import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart' show Color;

/// ตารางพิกเซลหนึ่งผืน — หน่วยพื้นฐานของงาน pixel art ทั้งเกม
/// วาดด้วย primitive แบบ snap พิกเซล แล้วแปลงเป็น [ui.Image] ครั้งเดียวตอนโหลด
class PixelGrid {
  PixelGrid(this.width, this.height)
    : _argb = List<int>.filled(width * height, 0);

  /// สร้างจากแถว string: ตัวอักษร = คีย์สีใน [palette], '.' = โปร่งใส
  factory PixelGrid.fromRows(List<String> rows, Map<String, Color> palette) {
    final h = rows.length;
    final w = rows.first.length;
    final grid = PixelGrid(w, h);
    for (var y = 0; y < h; y++) {
      assert(rows[y].length == w, 'แถว $y ยาว ${rows[y].length} ≠ $w');
      for (var x = 0; x < w; x++) {
        final key = rows[y][x];
        if (key == '.') continue;
        final color = palette[key];
        assert(color != null, 'ไม่รู้จักคีย์สี "$key"');
        grid.set(x, y, color!);
      }
    }
    return grid;
  }

  final int width;
  final int height;
  final List<int> _argb;

  void set(int x, int y, Color c) {
    if (x < 0 || y < 0 || x >= width || y >= height) return;
    _argb[y * width + x] = c.toARGB32();
  }

  int getArgb(int x, int y) => _argb[y * width + x];

  void fillRect(int x, int y, int w, int h, Color c) {
    for (var dy = 0; dy < h; dy++) {
      for (var dx = 0; dx < w; dx++) {
        set(x + dx, y + dy, c);
      }
    }
  }

  void outlineRect(int x, int y, int w, int h, Color c) {
    hline(x, y, w, c);
    hline(x, y + h - 1, w, c);
    vline(x, y, h, c);
    vline(x + w - 1, y, h, c);
  }

  void hline(int x, int y, int w, Color c) {
    for (var dx = 0; dx < w; dx++) {
      set(x + dx, y, c);
    }
  }

  void vline(int x, int y, int h, Color c) {
    for (var dy = 0; dy < h; dy++) {
      set(x, y + dy, c);
    }
  }

  /// ลาย dither หมากรุก (ใช้ทำเฉด/เงาแบบ pixel art)
  void dither(int x, int y, int w, int h, Color c, {int phase = 0}) {
    for (var dy = 0; dy < h; dy++) {
      for (var dx = 0; dx < w; dx++) {
        if ((dx + dy + phase).isEven) set(x + dx, y + dy, c);
      }
    }
  }

  /// วางกริดอื่นทับ (ข้ามพิกเซลโปร่งใส)
  void stamp(PixelGrid other, int x, int y) {
    for (var dy = 0; dy < other.height; dy++) {
      for (var dx = 0; dx < other.width; dx++) {
        final argb = other._argb[dy * other.width + dx];
        if (argb == 0) continue;
        if (x + dx < 0 || y + dy < 0 || x + dx >= width || y + dy >= height) {
          continue;
        }
        _argb[(y + dy) * width + (x + dx)] = argb;
      }
    }
  }

  /// สำเนาเลื่อนตำแหน่ง (ใช้ทำเฟรมเด้งขึ้นลง)
  PixelGrid shifted(int dx, int dy) {
    final out = PixelGrid(width, height);
    out.stamp(this, dx, dy);
    return out;
  }

  Uint8List _toRgbaBytes() {
    final bytes = Uint8List(width * height * 4);
    for (var i = 0; i < _argb.length; i++) {
      final v = _argb[i];
      bytes[i * 4] = (v >> 16) & 0xFF;
      bytes[i * 4 + 1] = (v >> 8) & 0xFF;
      bytes[i * 4 + 2] = v & 0xFF;
      bytes[i * 4 + 3] = (v >> 24) & 0xFF;
    }
    return bytes;
  }

  Future<ui.Image> toImage() {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      _toRgbaBytes(),
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }
}

/// sprite sheet ในหน่วยความจำ: เฟรมเรียงแนวนอนในภาพเดียว
class PixelSheet {
  PixelSheet(this.image, this.frameWidth, this.frameHeight, this.frameCount);

  /// ประกอบหลายกริด (ขนาดเท่ากัน) เป็นชีตเดียว
  static Future<PixelSheet> fromGrids(List<PixelGrid> frames) async {
    final fw = frames.first.width;
    final fh = frames.first.height;
    final sheet = PixelGrid(fw * frames.length, fh);
    for (var i = 0; i < frames.length; i++) {
      sheet.stamp(frames[i], i * fw, 0);
    }
    return PixelSheet(await sheet.toImage(), fw, fh, frames.length);
  }

  final ui.Image image;
  final int frameWidth;
  final int frameHeight;
  final int frameCount;

  /// วาดเฟรม [index] ลงกรอบ [dest] แบบพิกเซลคม (nearest-neighbor)
  /// [flipH] = หันซ้าย
  void drawFrame(
    ui.Canvas canvas,
    int index,
    ui.Rect dest, {
    bool flipH = false,
  }) {
    final src = ui.Rect.fromLTWH(
      (index % frameCount) * frameWidth.toDouble(),
      0,
      frameWidth.toDouble(),
      frameHeight.toDouble(),
    );
    canvas.save();
    if (flipH) {
      canvas.translate(dest.center.dx, 0);
      canvas.scale(-1, 1);
      canvas.translate(-dest.center.dx, 0);
    }
    canvas.drawImageRect(image, src, dest, pixelPaint());
    canvas.restore();
  }
}

/// Paint มาตรฐานของงานพิกเซล — ปิด anti-alias/filter ให้ขอบคม
ui.Paint pixelPaint() => ui.Paint()
  ..filterQuality = ui.FilterQuality.none
  ..isAntiAlias = false;

/// วาดภาพพิกเซลเต็มกรอบ [dest] แบบคม
void drawPixelImage(ui.Canvas canvas, ui.Image image, ui.Rect dest) {
  canvas.drawImageRect(
    image,
    ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    dest,
    pixelPaint(),
  );
}

Color lighten(Color c, double t) => Color.lerp(c, const Color(0xFFFFFFFF), t)!;

Color darken(Color c, double t) => Color.lerp(c, const Color(0xFF2A2019), t)!;

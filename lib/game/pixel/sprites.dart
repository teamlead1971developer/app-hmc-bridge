import 'dart:ui' as ui;

import 'package:flutter/painting.dart' show Color;

import '../../models/decor_item.dart';
import '../../models/product.dart';
import '../../models/scent_blend.dart';
import '../../theme/palette.dart';
import 'pixel_art.dart';

/// ดัชนีเฟรมในชีตตัวละคร (7 เฟรม): ยืน 3 อารมณ์ + เดิน 4 เฟรม
abstract final class CharFrame {
  static const idleNeutral = 0;
  static const idleHappy = 1;
  static const idleAngry = 2;
  static const walkStart = 3; // walk 4 เฟรม: 3,4,5,6
  static const walkCount = 4;
}

/// คลัง sprite ทั้งเกม — สร้างครั้งเดียวตอนเปิดแอป (in-memory sprite sheets)
class PixelSprites {
  PixelSprites._();

  static PixelSprites? _instance;

  static PixelSprites get I {
    assert(_instance != null, 'ต้อง PixelSprites.ensureLoaded() ก่อนใช้');
    return _instance!;
  }

  static bool get loaded => _instance != null;

  /// ชีตลูกค้าตามสีใน Palette.customerColors (คีย์ = ค่า ARGB ของสี)
  late final Map<int, PixelSheet> customerSheets;
  late final PixelSheet playerSheet;

  late final ui.Image blendBar;
  late final ui.Image shelf;
  late final ui.Image bin;
  late final ui.Image crates;
  late final ui.Image window;
  late final ui.Image menuBoard;
  late final ui.Image ingredientShelf;
  late final ui.Image door;
  late final ui.Image displayStand;

  /// ขวด diffuser เปล่า / มีก้าน reed — ชั้นสีน้ำหอมวาดทับตอน runtime
  late final ui.Image bottleEmpty;
  late final ui.Image bottleReeds;

  late final Map<ProductKind, ui.Image> products;
  late final Map<DecorKind, ui.Image> decors;

  static Future<void> ensureLoaded() async {
    if (_instance != null) return;
    final s = PixelSprites._();

    s.playerSheet = await PixelSheet.fromGrids(
      _characterFrames(Palette.peach, apron: true),
    );
    s.customerSheets = {
      for (final c in Palette.customerColors)
        c.toARGB32(): await PixelSheet.fromGrids(_characterFrames(c)),
    };

    s.blendBar = await _blendBar().toImage();
    s.shelf = await _shelf().toImage();
    s.bin = await _bin().toImage();
    s.crates = await _crates().toImage();
    s.window = await _window().toImage();
    s.menuBoard = await _menuBoard().toImage();
    s.ingredientShelf = await _ingredientShelf().toImage();
    s.door = await _door().toImage();
    s.displayStand = await _displayStand().toImage();
    s.bottleEmpty = await _bottle(reeds: false).toImage();
    s.bottleReeds = await _bottle(reeds: true).toImage();
    s.products = {
      for (final kind in ProductKind.values)
        kind: await _product(kind).toImage(),
    };
    s.decors = {
      for (final kind in DecorKind.values) kind: await _decor(kind).toImage(),
    };

    _instance = s;
  }

  PixelSheet sheetFor(Color customerColor) =>
      customerSheets[customerColor.toARGB32()] ??
      customerSheets.values.first;
}

// ---------- ตัวละคร (16×20) ----------

const _ink = Color(0xFF4A3A30);
const _cheek = Color(0xFFE8909C);

List<PixelGrid> _characterFrames(Color body, {bool apron = false}) {
  final palette = <String, Color>{
    'o': darken(body, 0.5),
    'b': body,
    'h': lighten(body, 0.4),
    's': darken(body, 0.18),
  };
  // ลำตัวบล็อบ (ยังไม่มีหน้า/เท้า) — 16 กว้าง 17 สูง
  final torso = PixelGrid.fromRows(const [
    '....oooooooo....',
    '..oobbbbbbbboo..',
    '..obhhbbbbbbbo..',
    '.obhhbbbbbbbbso.',
    '.obhbbbbbbbbbso.',
    '.obbbbbbbbbbbso.',
    '.obbbbbbbbbbbso.',
    '.obbbbbbbbbbbso.',
    '.obbbbbbbbbbbso.',
    '.obbbbbbbbbbbso.',
    '.obbbbbbbbbbbso.',
    '.obbbbbbbbbbbso.',
    '.obbbbbbbbbbbso.',
    '.obbbbbbbbbbsso.',
    '..obbbbbbbbsso..',
    '..oobbbbbbssoo..',
    '....oooooooo....',
  ], palette);

  if (apron) {
    final apronDark = const Color(0xFF8A6248);
    final apronLight = const Color(0xFFA57B5B);
    // ผ้ากันเปื้อนครึ่งล่าง + สายคาด + กระเป๋าหน้า
    torso.fillRect(4, 10, 8, 6, apronDark);
    torso.hline(4, 10, 8, apronLight);
    torso.hline(3, 9, 2, apronLight);
    torso.hline(11, 9, 2, apronLight);
    torso.outlineRect(6, 12, 4, 3, apronLight);
  }

  PixelGrid withFace(CustomerFace face) {
    final g = PixelGrid(16, 20);
    g.stamp(torso, 0, 0);
    switch (face) {
      case CustomerFace.neutral:
        g.fillRect(5, 6, 1, 2, _ink);
        g.fillRect(10, 6, 1, 2, _ink);
        g.hline(7, 9, 2, _ink);
      case CustomerFace.happy:
        // ตายิ้มหยี ^^
        g.set(4, 7, _ink);
        g.set(5, 6, _ink);
        g.set(6, 7, _ink);
        g.set(9, 7, _ink);
        g.set(10, 6, _ink);
        g.set(11, 7, _ink);
        g.hline(6, 9, 4, _ink);
        g.set(6, 8, _ink);
        g.set(9, 8, _ink);
      case CustomerFace.angry:
        g.hline(4, 5, 2, _ink);
        g.hline(10, 5, 2, _ink);
        g.fillRect(5, 6, 1, 2, _ink);
        g.fillRect(10, 6, 1, 2, _ink);
        g.hline(7, 10, 2, _ink);
        g.set(6, 11, _ink);
        g.set(9, 11, _ink);
    }
    // แก้มชมพู
    g.fillRect(3, 8, 1, 1, _cheek);
    g.fillRect(12, 8, 1, 1, _cheek);
    return g;
  }

  final foot = PixelGrid(3, 3)
    ..fillRect(0, 0, 3, 2, darken(body, 0.28))
    ..hline(0, 2, 3, darken(body, 0.5));

  /// ประกอบเฟรม: หน้า + ตำแหน่งเท้าสองข้าง (+เด้งตัวขึ้นในเฟรม pass)
  PixelGrid frame(CustomerFace face, int lx, int rx, {bool up = false}) {
    final g = PixelGrid(16, 20);
    g.stamp(withFace(face).shifted(0, up ? -1 : 0), 0, 0);
    g.stamp(foot, lx, up ? 16 : 17);
    g.stamp(foot, rx, up ? 16 : 17);
    return g;
  }

  return [
    frame(CustomerFace.neutral, 4, 9),
    frame(CustomerFace.happy, 4, 9),
    frame(CustomerFace.angry, 4, 9),
    // walk cycle: ก้าวซ้าย → ชิด(เด้ง) → ก้าวขวา → ชิด(เด้ง)
    frame(CustomerFace.neutral, 2, 9),
    frame(CustomerFace.neutral, 4, 9, up: true),
    frame(CustomerFace.neutral, 4, 11),
    frame(CustomerFace.neutral, 4, 9, up: true),
  ];
}

enum CustomerFace { neutral, happy, angry }

// ---------- สีไม้/ของกลาง ----------

const _woodL = Color(0xFFC89A6B);
const _wood = Color(0xFFA97B52);
const _woodD = Color(0xFF7A5335);
const _woodOutline = Color(0xFF573A24);
const _cream = Color(0xFFF4E6CF);
const _glass = Color(0xFFDCEFF5);
const _glassHi = Color(0xFFF3FBFD);

// ---------- โต๊ะปรุงน้ำหอม (44×34) ----------

PixelGrid _blendBar() {
  final g = PixelGrid(44, 34);
  // ขาโต๊ะ + แผงหน้า
  g.fillRect(2, 16, 40, 16, _wood);
  g.outlineRect(2, 16, 40, 16, _woodOutline);
  for (var x = 8; x < 40; x += 7) {
    g.vline(x, 18, 12, _woodD);
  }
  g.hline(3, 30, 38, _woodD);
  // ท็อปโต๊ะหนา
  g.fillRect(0, 12, 44, 4, _cream);
  g.outlineRect(0, 12, 44, 4, _woodOutline);
  g.hline(1, 15, 42, darken(_cream, 0.25));
  // แถวขวดหัวน้ำหอม 6 สีบนโต๊ะ
  final notes = ScentNote.values.take(6).toList();
  for (var i = 0; i < 6; i++) {
    final x = 3 + i * 7;
    final c = notes[i].color;
    g.fillRect(x, 3, 4, 9, c);
    g.outlineRect(x, 3, 4, 9, darken(c, 0.45));
    g.vline(x + 1, 4, 6, lighten(c, 0.4));
    g.fillRect(x + 1, 1, 2, 2, _woodD); // จุกไม้
  }
  return g;
}

// ---------- ชั้นสินค้าสำเร็จ (34×30) ----------

PixelGrid _shelf() {
  final g = PixelGrid(34, 30);
  // เสาข้าง + ฐาน
  g.fillRect(0, 2, 3, 28, _wood);
  g.fillRect(31, 2, 3, 28, _wood);
  g.outlineRect(0, 2, 3, 28, _woodOutline);
  g.outlineRect(31, 2, 3, 28, _woodOutline);
  g.fillRect(2, 24, 30, 6, _wood);
  g.outlineRect(2, 24, 30, 6, _woodOutline);
  g.hline(3, 27, 28, _woodD);
  // แผ่นชั้น
  g.fillRect(1, 16, 32, 3, _cream);
  g.outlineRect(1, 16, 32, 3, _woodOutline);
  // สินค้า 3 ชิ้นบนชั้น
  g.stamp(_product(ProductKind.candle), 4, 3);
  g.stamp(_product(ProductKind.sachet), 14, 3);
  g.stamp(_product(ProductKind.soap), 23, 6);
  return g;
}

// ---------- ถังขยะ (12×15) ----------

PixelGrid _bin() {
  final g = PixelGrid(12, 15);
  const green = Color(0xFF7FA878);
  g.fillRect(1, 4, 10, 11, green);
  g.outlineRect(1, 4, 10, 11, darken(green, 0.45));
  g.vline(3, 6, 8, darken(green, 0.2));
  g.vline(8, 6, 8, darken(green, 0.2));
  // ฝา + จุก
  g.fillRect(0, 2, 12, 3, lighten(green, 0.2));
  g.outlineRect(0, 2, 12, 3, darken(green, 0.45));
  g.fillRect(5, 0, 2, 2, darken(green, 0.3));
  return g;
}

// ---------- ลังไม้ (24×20) ----------

PixelGrid _crates() {
  final g = PixelGrid(24, 20);
  void crate(int x, int y, int w, int h) {
    g.fillRect(x, y, w, h, _woodL);
    g.outlineRect(x, y, w, h, _woodOutline);
    g.outlineRect(x + 2, y + 2, w - 4, h - 4, _woodD);
  }

  crate(0, 9, 12, 11);
  crate(11, 11, 13, 9);
  crate(4, 0, 11, 10);
  return g;
}

// ---------- หน้าต่างหลังร้าน (24×22) ----------

PixelGrid _window() {
  final g = PixelGrid(24, 22);
  g.fillRect(0, 0, 24, 20, _wood);
  g.outlineRect(0, 0, 24, 20, _woodOutline);
  g.fillRect(2, 2, 20, 16, _glass);
  // แสงเฉียงบนกระจก
  g.dither(3, 3, 6, 14, _glassHi);
  // คานกลาง
  g.hline(2, 9, 20, _woodOutline);
  g.vline(11, 2, 16, _woodOutline);
  // ขอบล่าง
  g.fillRect(1, 20, 22, 2, _woodL);
  g.outlineRect(1, 20, 22, 2, _woodOutline);
  return g;
}

// ---------- ป้ายสูตร (18×22) ----------

PixelGrid _menuBoard() {
  final g = PixelGrid(18, 22);
  g.fillRect(0, 0, 18, 22, _wood);
  g.outlineRect(0, 0, 18, 22, _woodOutline);
  const board = Color(0xFF4C4038);
  g.fillRect(2, 2, 14, 18, board);
  // ดอกไม้หัวป้าย + เส้นชอล์ก
  const chalk = Color(0xFFEFE8DC);
  g.set(8, 4, chalk);
  g.set(9, 4, chalk);
  g.set(7, 5, chalk);
  g.set(10, 5, chalk);
  g.set(8, 6, chalk);
  g.set(9, 6, chalk);
  for (var i = 0; i < 3; i++) {
    g.hline(4, 9 + i * 3, 8 + i, chalk);
  }
  return g;
}

// ---------- ชั้นขวดวัตถุดิบหลังร้าน (32×22) ----------

PixelGrid _ingredientShelf() {
  final g = PixelGrid(32, 22);
  const rowColors = [
    [Color(0xFFB39DDB), Color(0xFFF4A7B9), Color(0xFF9FD08C), Color(0xFFF0DFAE), Color(0xFFA98467)],
    [Color(0xFFEDE7F6), Color(0xFFE5A34D), Color(0xFFB39DDB), Color(0xFFC8D96F), Color(0xFF8B5E4B)],
  ];
  for (var row = 0; row < 2; row++) {
    final boardY = 9 + row * 11;
    g.fillRect(0, boardY, 32, 2, _wood);
    g.hline(0, boardY + 1, 32, _woodOutline);
    for (var i = 0; i < 5; i++) {
      final c = rowColors[row][i];
      final h = 6 + (i.isOdd ? 1 : 0);
      final x = 1 + i * 6;
      g.fillRect(x, boardY - h, 4, h, c);
      g.outlineRect(x, boardY - h, 4, h, darken(c, 0.45));
      g.vline(x + 1, boardY - h + 1, h - 2, lighten(c, 0.35));
    }
  }
  return g;
}

// ---------- ประตูถนน (22×44) ----------

PixelGrid _door() {
  final g = PixelGrid(22, 44);
  g.fillRect(0, 0, 22, 44, _woodL);
  g.outlineRect(0, 0, 22, 44, _woodOutline);
  // โค้งบนแบบขั้นบันได
  g.fillRect(0, 0, 3, 3, const Color(0x00000000));
  g.fillRect(19, 0, 3, 3, const Color(0x00000000));
  g.set(0, 3, _woodOutline);
  g.set(21, 3, _woodOutline);
  g.hline(3, 0, 16, _woodOutline);
  g.vline(2, 1, 2, _woodOutline);
  g.vline(19, 1, 2, _woodOutline);
  g.set(3, 1, _woodL);
  // กระจกบนมองเห็นฟ้า
  g.fillRect(5, 5, 12, 14, _glass);
  g.outlineRect(5, 5, 12, 14, _woodOutline);
  g.dither(6, 6, 4, 12, _glassHi);
  // มือจับ
  g.fillRect(4, 26, 2, 2, _woodOutline);
  // แผงล่าง
  g.outlineRect(5, 24, 12, 14, _woodD);
  return g;
}

// ---------- แผงโชว์น้ำหอมตัวอย่าง (30×24) ----------

PixelGrid _displayStand() {
  final g = PixelGrid(30, 24);
  // ตัวแท่น
  g.fillRect(3, 12, 24, 12, _wood);
  g.outlineRect(3, 12, 24, 12, _woodOutline);
  g.outlineRect(6, 15, 18, 6, _woodD);
  // ท็อปหนา
  g.fillRect(1, 9, 28, 3, _cream);
  g.outlineRect(1, 9, 28, 3, _woodOutline);
  // ขวดตัวอย่าง 3 ขวด (ม่วง/ชมพู/แอมเบอร์)
  const colors = [Palette.lavender, Palette.blush, Palette.amber];
  for (var i = 0; i < 3; i++) {
    final x = 5 + i * 8;
    final c = colors[i];
    final h = 6 + (i == 1 ? 2 : 0);
    g.fillRect(x, 9 - h, 4, h, c);
    g.outlineRect(x, 9 - h, 4, h, darken(c, 0.45));
    g.vline(x + 1, 10 - h, h - 2, lighten(c, 0.4));
    g.fillRect(x + 1, 7 - h, 2, 2, _woodD);
  }
  return g;
}

// ---------- ขวด diffuser (12×18 — reed โผล่เหนือขวดอีก 6 แถว = 12×24) ----------

PixelGrid _bottle({required bool reeds}) {
  final g = PixelGrid(12, 24);
  // ก้าน reed
  if (reeds) {
    g.vline(4, 1, 6, _woodD);
    g.vline(6, 0, 7, _wood);
    g.vline(8, 2, 5, _woodD);
    g.set(3, 1, _woodD);
    g.set(9, 2, _woodD);
  }
  // คอขวด + ตัวขวดแก้ว
  g.fillRect(4, 6, 4, 3, _glass);
  g.outlineRect(4, 6, 4, 3, darken(_glass, 0.4));
  g.fillRect(1, 9, 10, 15, _glass);
  g.outlineRect(1, 9, 10, 15, darken(_glass, 0.4));
  g.vline(2, 10, 12, _glassHi);
  return g;
}

/// กรอบภายในขวด (พิกัด sprite) ไว้เทชั้นสีน้ำหอมตอน runtime
const bottleInterior = ui.Rect.fromLTWH(2, 10, 8, 13);
const bottleSpriteSize = ui.Size(12, 24);

// ---------- สินค้าสำเร็จ ----------

PixelGrid _product(ProductKind kind) {
  switch (kind) {
    case ProductKind.candle:
      final g = PixelGrid(12, 14);
      const jar = Color(0xFFEFC98B);
      g.fillRect(2, 5, 8, 9, jar);
      g.outlineRect(2, 5, 8, 9, darken(jar, 0.45));
      g.vline(3, 6, 7, lighten(jar, 0.35));
      // เปลวไฟ
      g.set(5, 1, const Color(0xFFF2B54B));
      g.set(6, 1, const Color(0xFFF2B54B));
      g.fillRect(5, 2, 2, 2, const Color(0xFFE8933B));
      g.set(5, 4, _woodOutline);
      return g;
    case ProductKind.sachet:
      final g = PixelGrid(12, 14);
      const cloth = Color(0xFFC5AEE0);
      g.fillRect(2, 5, 8, 8, cloth);
      g.fillRect(3, 3, 6, 2, cloth);
      g.outlineRect(2, 5, 8, 8, darken(cloth, 0.45));
      g.hline(3, 4, 6, darken(cloth, 0.45));
      g.fillRect(4, 1, 4, 2, darken(cloth, 0.25)); // มัดปาก
      g.set(5, 8, lighten(cloth, 0.45));
      g.set(7, 10, lighten(cloth, 0.45));
      return g;
    case ProductKind.soap:
      final g = PixelGrid(14, 10);
      const soap = Color(0xFFF3B8C3);
      g.fillRect(1, 2, 12, 7, soap);
      g.outlineRect(1, 2, 12, 7, darken(soap, 0.45));
      g.hline(2, 3, 10, lighten(soap, 0.35));
      // ดอกไม้กลางก้อน
      g.set(6, 5, const Color(0xFFF6E27F));
      g.set(5, 4, Palette.white);
      g.set(7, 4, Palette.white);
      g.set(5, 6, Palette.white);
      g.set(7, 6, Palette.white);
      return g;
  }
}

// ---------- ของตกแต่ง 13 ชิ้น ----------

PixelGrid _decor(DecorKind kind) {
  switch (kind) {
    case DecorKind.painting:
      final g = PixelGrid(16, 18);
      g.fillRect(0, 0, 16, 18, _wood);
      g.outlineRect(0, 0, 16, 18, _woodOutline);
      g.fillRect(2, 2, 12, 14, const Color(0xFFF6E27F));
      // แมวดำ
      g.fillRect(6, 8, 4, 6, _ink);
      g.fillRect(6, 5, 4, 3, _ink);
      g.set(5, 4, _ink);
      g.set(10, 4, _ink);
      return g;
    case DecorKind.clock:
      final g = PixelGrid(14, 14);
      g.fillRect(2, 2, 10, 10, Palette.white);
      g.outlineRect(1, 1, 12, 12, _woodOutline);
      g.outlineRect(0, 4, 14, 6, const Color(0x00000000));
      g.vline(7, 4, 3, _ink);
      g.hline(7, 7, 3, _ink);
      g.set(7, 7, const Color(0xFFE8909C));
      return g;
    case DecorKind.shelfPlants:
      final g = PixelGrid(22, 14);
      g.fillRect(0, 11, 22, 2, _wood);
      g.hline(0, 12, 22, _woodOutline);
      const pots = [Palette.blush, Palette.butter, Palette.sky];
      for (var i = 0; i < 3; i++) {
        final x = 2 + i * 7;
        g.fillRect(x, 8, 4, 3, pots[i]);
        g.outlineRect(x, 8, 4, 3, darken(pots[i], 0.4));
        g.fillRect(x, 4, 4, 4, const Color(0xFF8FB08A));
        g.fillRect(x + 1, 2, 2, 2, const Color(0xFFA8C8A0));
      }
      return g;
    case DecorKind.stringLights:
      final g = PixelGrid(30, 10);
      const bulbs = [Palette.butter, Palette.blush, Palette.sky, Palette.sage, Palette.peach];
      for (var i = 0; i < 5; i++) {
        final x = 2 + i * 6;
        final y = 2 + ((i.isEven) ? 0 : 2);
        g.set(x + 1, y - 1, _woodD);
        if (i < 4) {
          g.hline(x + 2, y - (i.isEven ? 1 : 3) + 1, 4, _woodD);
        }
        g.fillRect(x, y, 3, 3, bulbs[i]);
        g.set(x, y, lighten(bulbs[i], 0.45));
      }
      return g;
    case DecorKind.plant:
      final g = PixelGrid(14, 22);
      const leafD = Color(0xFF7FA878);
      const leafL = Color(0xFFA8C8A0);
      g.fillRect(3, 16, 8, 6, Palette.peach);
      g.outlineRect(3, 16, 8, 6, darken(Palette.peach, 0.4));
      g.fillRect(2, 6, 5, 7, leafD);
      g.fillRect(7, 4, 5, 9, leafD);
      g.fillRect(4, 1, 6, 6, leafL);
      g.set(6, 14, _woodD);
      g.set(7, 14, _woodD);
      return g;
    case DecorKind.floorLamp:
      final g = PixelGrid(14, 26);
      g.fillRect(3, 1, 8, 6, Palette.blush);
      g.outlineRect(3, 1, 8, 6, darken(Palette.blush, 0.4));
      g.fillRect(5, 0, 4, 1, const Color(0xFFF6E27F));
      g.vline(6, 7, 16, _woodD);
      g.vline(7, 7, 16, _woodOutline);
      g.fillRect(3, 23, 8, 3, _woodD);
      g.hline(3, 25, 8, _woodOutline);
      return g;
    case DecorKind.bookshelf:
      final g = PixelGrid(22, 28);
      g.fillRect(0, 0, 22, 28, _wood);
      g.outlineRect(0, 0, 22, 28, _woodOutline);
      const spines = [Palette.blush, Palette.sky, Palette.butter, Palette.sage, Palette.lavender];
      for (var row = 0; row < 3; row++) {
        final y = 2 + row * 9;
        g.fillRect(2, y, 18, 7, const Color(0xFF5E4630));
        for (var i = 0; i < 5; i++) {
          final c = spines[(row + i) % spines.length];
          g.fillRect(3 + i * 4, y + (i.isOdd ? 1 : 0), 3, 7 - (i.isOdd ? 1 : 0), c);
          g.vline(3 + i * 4, y + (i.isOdd ? 1 : 0), 7 - (i.isOdd ? 1 : 0), darken(c, 0.3));
        }
      }
      return g;
    case DecorKind.armchair:
      final g = PixelGrid(20, 16);
      g.fillRect(3, 0, 14, 8, Palette.blush);
      g.fillRect(0, 6, 20, 7, Palette.blush);
      g.outlineRect(0, 6, 20, 7, darken(Palette.blush, 0.4));
      g.outlineRect(3, 0, 14, 7, darken(Palette.blush, 0.4));
      g.fillRect(5, 5, 10, 4, Palette.peach);
      g.outlineRect(5, 5, 10, 4, darken(Palette.peach, 0.35));
      g.fillRect(2, 13, 2, 3, _woodD);
      g.fillRect(16, 13, 2, 3, _woodD);
      return g;
    case DecorKind.cafeTable:
      final g = PixelGrid(26, 20);
      for (final x in [1, 20]) {
        g.fillRect(x, 8, 5, 8, Palette.sage);
        g.outlineRect(x, 8, 5, 8, darken(Palette.sage, 0.4));
      }
      g.fillRect(6, 6, 14, 3, _cream);
      g.outlineRect(6, 6, 14, 3, _woodOutline);
      g.vline(12, 9, 9, _woodD);
      g.vline(13, 9, 9, _woodOutline);
      g.fillRect(11, 2, 4, 4, Palette.white);
      g.outlineRect(11, 2, 4, 4, darken(Palette.white, 0.35));
      return g;
    case DecorKind.rugRound:
      final g = PixelGrid(22, 10);
      g.fillRect(3, 1, 16, 8, Palette.blush);
      g.fillRect(1, 3, 20, 4, Palette.blush);
      g.fillRect(6, 3, 10, 4, Palette.peach);
      return g;
    case DecorKind.rugLong:
      final g = PixelGrid(30, 8);
      g.fillRect(0, 0, 30, 8, Palette.sky);
      g.outlineRect(0, 0, 30, 8, darken(Palette.sky, 0.3));
      for (var i = 0; i < 3; i++) {
        g.fillRect(4 + i * 9, 2, 4, 4, Palette.white);
      }
      return g;
    case DecorKind.wallpaperSage || DecorKind.wallpaperPeach:
      final g = PixelGrid(12, 14);
      final c = kind == DecorKind.wallpaperSage
          ? Palette.wallSageLight
          : Palette.wallPeachLight;
      g.fillRect(0, 0, 12, 14, c);
      g.outlineRect(0, 0, 12, 14, darken(c, 0.35));
      g.dither(2, 2, 8, 10, lighten(c, 0.35));
      return g;
  }
}

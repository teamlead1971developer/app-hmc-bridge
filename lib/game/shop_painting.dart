import 'dart:ui';

import '../models/decor_item.dart';
import '../models/placed_decor.dart';
import '../models/product.dart';
import '../models/scent_blend.dart';
import '../theme/palette.dart';
import 'pixel/pixel_art.dart';
import 'pixel/sprites.dart';
import 'room_layout.dart';

enum CustomerMood { neutral, happy, angry }

Paint _fill(Color color) => Paint()
  ..color = color
  ..isAntiAlias = false;

/// เส้นทางกล่องมุมขั้นบันได (ใช้กับ UI ในฉากเกม: บับเบิล/แถบต่างๆ)
Path pixelRectPath(Rect rect, double corner) {
  final c = corner.clamp(0, rect.shortestSide / 3).toDouble();
  final u = c / 2;
  final l = rect.left, t = rect.top, r = rect.right, b = rect.bottom;
  return Path()
    ..moveTo(l + c, t)
    ..lineTo(r - c, t)
    ..lineTo(r - c, t + u)
    ..lineTo(r - u, t + u)
    ..lineTo(r - u, t + c)
    ..lineTo(r, t + c)
    ..lineTo(r, b - c)
    ..lineTo(r - u, b - c)
    ..lineTo(r - u, b - u)
    ..lineTo(r - c, b - u)
    ..lineTo(r - c, b)
    ..lineTo(l + c, b)
    ..lineTo(l + c, b - u)
    ..lineTo(l + u, b - u)
    ..lineTo(l + u, b - c)
    ..lineTo(l, b - c)
    ..lineTo(l, t + c)
    ..lineTo(l + u, t + c)
    ..lineTo(l + u, t + u)
    ..lineTo(l + c, t + u)
    ..close();
}

/// กล่อง pixel: กรอบหนา + พื้นข้างใน (มุมขั้นบันได)
void drawPixelRect(
  Canvas canvas,
  Rect rect, {
  required Color fill,
  Color border = Palette.espresso,
  double borderWidth = 2,
  double corner = 6,
}) {
  canvas.drawPath(pixelRectPath(rect, corner), _fill(border));
  canvas.drawPath(
    pixelRectPath(rect.deflate(borderWidth), corner),
    _fill(fill),
  );
}

/// วาด sprite ลงกรอบ [dest] แบบรักษาสัดส่วน ยึดขอบล่างกึ่งกลาง (พิกเซลคม)
void drawSpriteFit(Canvas canvas, Image image, Rect dest) {
  final scale = (dest.width / image.width < dest.height / image.height)
      ? dest.width / image.width
      : dest.height / image.height;
  final w = image.width * scale;
  final h = image.height * scale;
  drawPixelImage(
    canvas,
    image,
    Rect.fromLTWH(dest.center.dx - w / 2, dest.bottom - h, w, h),
  );
}

// ---------- ห้อง ----------

/// วอลเปเปอร์ที่ติดอยู่ตอนนี้ (ถ้ามี)
DecorKind? activeWallpaper(List<PlacedDecor> placed) {
  for (final p in placed) {
    if (p.item.layer == DecorLayer.wallpaper) return p.item.kind;
  }
  return null;
}

/// วาดโครงโลกทั้งสองห้องแบบ pixel: ผนัง/พื้นสองโทน ซุ้มกลาง สถานี ประตู
void paintRoom(Canvas canvas, RoomLayout room, {DecorKind? wallpaper}) {
  final worldW = room.worldW;
  final frontX = room.frontX;
  final floorTop = room.floorTop;
  // ขนาด "พิกเซลจอ" หนึ่งเม็ดของฉาก — ทุกอย่าง snap กับกริดนี้
  final px = (room.w / 110).clamp(2.0, 8.0);

  double snap(double v) => (v / px).floorToDouble() * px;

  // ผนังหลังร้าน (โทนขรึม) / หน้าร้าน (ตามวอลเปเปอร์)
  canvas.drawRect(
    Rect.fromLTWH(0, 0, frontX, floorTop),
    _fill(darken(Palette.wallLight, 0.08)),
  );
  final frontWallColor = switch (wallpaper) {
    DecorKind.wallpaperSage => Palette.wallSageLight,
    DecorKind.wallpaperPeach => Palette.wallPeachLight,
    _ => Palette.wallLight,
  };
  canvas.drawRect(
    Rect.fromLTWH(frontX, 0, room.w, floorTop),
    _fill(frontWallColor),
  );
  // ลายจุด pixel บนวอลเปเปอร์ (หน้าร้าน)
  if (wallpaper != null) {
    final dot = _fill(lighten(frontWallColor, 0.35));
    for (var y = 0; y < 5; y++) {
      for (var x = 0; x < 13; x++) {
        canvas.drawRect(
          Rect.fromLTWH(
            snap(frontX + room.w * (0.05 + x * 0.075 + (y.isOdd ? 0.037 : 0))),
            snap(floorTop * (0.12 + y * 0.19)),
            px,
            px,
          ),
          dot,
        );
      }
    }
  }
  // แผงไม้ครึ่งล่างผนัง (wainscot) กันผนังโล่ง — สไตล์ร้านบูติก
  final wainscotH = px * 12;
  for (final (x0, x1, base) in [
    (0.0, frontX, darken(Palette.wallLight, 0.08)),
    (frontX, worldW, frontWallColor),
  ]) {
    final wainscot = darken(base, 0.14);
    canvas.drawRect(
      Rect.fromLTWH(x0, floorTop - wainscotH, x1 - x0, wainscotH),
      _fill(wainscot),
    );
    canvas.drawRect(
      Rect.fromLTWH(x0, floorTop - wainscotH, x1 - x0, px),
      _fill(lighten(wainscot, 0.25)),
    );
    // ร่องแผงไม้แนวตั้ง
    for (var sx = x0 + px * 10; sx < x1; sx += px * 10) {
      canvas.drawRect(
        Rect.fromLTWH(snap(sx), floorTop - wainscotH + px * 2, px, wainscotH - px * 4),
        _fill(darken(wainscot, 0.12)),
      );
    }
  }

  // พื้นไม้สองโทน แบบแผ่นไม้แถวละ ~6px
  final plankH = px * 6;
  final backFloor = darken(Palette.floorLight, 0.16);
  final frontFloor = Palette.floorLight;
  var rowIndex = 0;
  for (var y = floorTop; y < room.h; y += plankH) {
    final h = (y + plankH > room.h) ? room.h - y : plankH;
    for (final (x0, x1, base) in [
      (0.0, frontX, backFloor),
      (frontX, worldW, frontFloor),
    ]) {
      final tone = rowIndex.isEven ? base : darken(base, 0.05);
      canvas.drawRect(Rect.fromLTWH(x0, y, x1 - x0, h), _fill(tone));
      // ร่องไม้แนวนอน
      canvas.drawRect(
        Rect.fromLTWH(x0, y + h - px, x1 - x0, px),
        _fill(darken(base, 0.22)),
      );
      // รอยต่อแผ่นไม้แนวตั้ง (สลับแถว)
      final seamStep = px * 22;
      var sx = x0 + (rowIndex.isOdd ? seamStep / 2 : 0);
      for (; sx < x1; sx += seamStep) {
        canvas.drawRect(
          Rect.fromLTWH(snap(sx), y, px, h - px),
          _fill(darken(base, 0.14)),
        );
      }
    }
    rowIndex++;
  }

  // บัวเชิงผนัง
  canvas.drawRect(
    Rect.fromLTWH(0, floorTop - px * 2, worldW, px * 2),
    _fill(Palette.latte),
  );
  canvas.drawRect(
    Rect.fromLTWH(0, floorTop - px * 2, worldW, px),
    _fill(lighten(Palette.latte, 0.3)),
  );
  // รอยต่อพื้นสองห้อง
  canvas.drawRect(
    Rect.fromLTWH(snap(frontX) - px, floorTop, px * 2, room.floorDepth),
    _fill(darken(backFloor, 0.15)),
  );

  // หลังร้าน
  final s = PixelSprites.I;
  drawSpriteFit(canvas, s.menuBoard, room.menuBoardRect);
  drawSpriteFit(canvas, s.ingredientShelf, room.ingredientShelfRect);
  drawSpriteFit(canvas, s.window, room.backWindowRect);
  drawSpriteFit(canvas, s.crates, room.cratesRect);
  drawSpriteFit(canvas, s.blendBar, room.blendBarRect);
  drawSpriteFit(canvas, s.shelf, room.shelfRect);
  drawSpriteFit(canvas, s.bin, room.binRect);
  // หน้าร้าน
  drawSpriteFit(canvas, s.door, room.doorRect);

  _paintDivider(canvas, room, px);
}

/// ผนังกั้นกลาง + ซุ้มโค้งแบบขั้นบันได pixel
void _paintDivider(Canvas canvas, RoomLayout room, double px) {
  final d = room.dividerRect;
  final a = room.archRect;
  canvas.drawRect(d, _fill(const Color(0xFF7A5335)));
  canvas.drawRect(
    Rect.fromLTWH(d.left, d.top, px, d.height),
    _fill(const Color(0xFFC89A6B)),
  );
  canvas.drawRect(
    Rect.fromLTWH(d.right - px, d.top, px, d.height),
    _fill(const Color(0xFF573A24)),
  );
  // ช่องซุ้ม: มืดด้านใน โค้งบนแบบขั้นบันได
  final inner = Rect.fromLTRB(a.left + px, a.top + px * 3, a.right - px, a.bottom);
  canvas.drawRect(inner, _fill(const Color(0xFF3E2A1B)));
  canvas.drawRect(
    Rect.fromLTWH(inner.left + px, a.top + px, inner.width - px * 2, px * 2),
    _fill(const Color(0xFF3E2A1B)),
  );
}

// ---------- ของตกแต่ง / แผงโชว์ / สินค้า / ขวด ----------

/// วาดของตกแต่งทุกชิ้นที่วางไว้ ตามลำดับชั้น พรม → ผนัง → เฟอร์นิเจอร์พื้น
void paintPlacedDecor(Canvas canvas, RoomLayout room, List<PlacedDecor> placed) {
  for (final layer in const [DecorLayer.rug, DecorLayer.wall, DecorLayer.floor]) {
    for (final p in placed) {
      if (p.item.layer != layer) continue;
      final rect = room.slotRect(layer, p.slot, p.item.cells);
      canvas.save();
      canvas.translate(rect.left, rect.top);
      paintDecor(canvas, p.item.kind, rect.size);
      canvas.restore();
    }
  }
}

/// วาดของตกแต่งชนิด [kind] ลงในกล่อง (0,0)–[size]
void paintDecor(Canvas canvas, DecorKind kind, Size size) {
  drawSpriteFit(
    canvas,
    PixelSprites.I.decors[kind]!,
    Rect.fromLTWH(0, 0, size.width, size.height),
  );
}

/// แผงโชว์น้ำหอมตัวอย่าง
void paintDisplayStand(Canvas canvas, Size size) {
  drawSpriteFit(
    canvas,
    PixelSprites.I.displayStand,
    Rect.fromLTWH(0, 0, size.width, size.height),
  );
}

/// สินค้าสำเร็จหนึ่งชิ้น
void paintProduct(Canvas canvas, Size size, Product product) {
  drawSpriteFit(
    canvas,
    PixelSprites.I.products[product.kind]!,
    Rect.fromLTWH(0, 0, size.width, size.height),
  );
}

/// ขวด diffuser + ชั้นสีของกลิ่นที่หยดแล้ว (สูงสุด 4 ชั้น)
void paintBottle(Canvas canvas, Size size, List<ScentNote> mixed) {
  final image = mixed.isEmpty ? PixelSprites.I.bottleEmpty : PixelSprites.I.bottleReeds;
  final box = Rect.fromLTWH(0, 0, size.width, size.height);
  // กรอบจริงที่ sprite ถูกวาด (สัดส่วนเดิม ชิดล่างกึ่งกลาง)
  final scale = (box.width / image.width < box.height / image.height)
      ? box.width / image.width
      : box.height / image.height;
  final dest = Rect.fromLTWH(
    box.center.dx - image.width * scale / 2,
    box.bottom - image.height * scale,
    image.width * scale,
    image.height * scale,
  );
  drawPixelImage(canvas, image, dest);

  if (mixed.isEmpty) return;
  // เทชั้นสีในกรอบภายในขวด (พิกัด sprite → พิกัดจอ)
  final interior = Rect.fromLTWH(
    dest.left + bottleInterior.left * scale,
    dest.top + bottleInterior.top * scale,
    bottleInterior.width * scale,
    bottleInterior.height * scale,
  );
  final layerH = (bottleInterior.height / 4).floorToDouble() * scale;
  for (var i = 0; i < mixed.length && i < 4; i++) {
    final top = interior.bottom - layerH * (i + 1);
    canvas.drawRect(
      Rect.fromLTWH(interior.left, top, interior.width, layerH),
      _fill(mixed[i].color),
    );
    canvas.drawRect(
      Rect.fromLTWH(interior.left, top, interior.width, scale),
      _fill(lighten(mixed[i].color, 0.3)),
    );
  }
  // ไฮไลต์แก้วทับชั้นสี
  canvas.drawRect(
    Rect.fromLTWH(interior.left + scale, interior.top, scale, interior.height),
    _fill(const Color(0x66FFFFFF)),
  );
}

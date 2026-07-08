import 'dart:ui';

import '../models/decor_item.dart';
import '../services/balance.dart';

/// ตำแหน่งทุกอย่างในโลกของร้าน คิดจากขนาด viewport (Size) ที่เดียว
/// ใช้ร่วมกันทั้งฉาก Flame ตอนเล่น และ CustomPainter ในหน้าแต่งร้าน
///
/// โลกกว้าง 2 เท่าของจอ แบ่งเป็นสองห้อง เดินทะลุถึงกันผ่านซุ้มประตูกลาง:
/// - **หลังร้าน** (x: 0..w) โซนทำงาน: ป้ายสูตร, โต๊ะปรุงน้ำหอม, ชั้นสินค้า,
///   ถังขยะ + ของแต่งตายตัว (ชั้นวัตถุดิบ, หน้าต่าง, ลังไม้)
/// - **หน้าร้าน** (x: w..2w) โซนลูกค้า: แผงโชว์น้ำหอมตัวอย่าง 4 แผง,
///   ประตูถนนขวาสุด, ช่องของแต่ง (decor) ทั้งหมดอยู่ห้องนี้
class RoomLayout {
  const RoomLayout(this.size);

  /// ขนาด viewport (จอเกม) — โลกกว้างเป็น 2 เท่าของ [w]
  final Size size;

  double get w => size.width;
  double get h => size.height;

  /// ความกว้างทั้งโลก
  double get worldW => w * 2;

  /// x ที่หน้าร้านเริ่ม (= ครึ่งโลก)
  double get frontX => w;

  /// เส้นรอยต่อผนัง/พื้น
  double get floorTop => h * 0.40;

  double get floorDepth => h - floorTop;

  /// y ที่ระยะ [t] (0=แนวผนัง, 1=ขอบล่างจอ) ของพื้น
  double floorY(double t) => floorTop + floorDepth * t;

  // ---- ผนังกั้นสองห้อง ----

  /// แถบผนังกั้นกลาง (บนแนวผนังหลัง)
  Rect get dividerRect =>
      Rect.fromLTWH(frontX - w * 0.030, 0, w * 0.060, floorTop);

  /// ช่องซุ้มประตูโค้งในผนังกั้น (ส่วนล่างของแถบ)
  Rect get archRect => Rect.fromLTWH(
    frontX - w * 0.030,
    floorTop - h * 0.24,
    w * 0.060,
    h * 0.24,
  );

  // ---- หลังร้าน (x: 0..w) ----

  /// ป้ายสูตรกลิ่นติดผนัง (ของตายตัว ไม่ใช่ decor)
  Rect get menuBoardRect => Rect.fromLTWH(w * 0.05, h * 0.08, w * 0.17, h * 0.17);

  /// โต๊ะปรุงน้ำหอม (blending bar)
  Rect get blendBarRect =>
      Rect.fromLTWH(w * 0.05, floorTop - h * 0.045, w * 0.24, h * 0.17);

  /// ชั้นวางสินค้าสำเร็จ
  Rect get shelfRect =>
      Rect.fromLTWH(w * 0.40, floorTop - h * 0.035, w * 0.17, h * 0.16);

  /// ถังขยะ (เทถาดทิ้ง)
  Rect get binRect =>
      Rect.fromLTWH(w * 0.66, floorTop + h * 0.005, w * 0.065, h * 0.115);

  /// ชั้นขวดวัตถุดิบบนผนังหลังร้าน (ของตายตัว)
  Rect get ingredientShelfRect =>
      Rect.fromLTWH(w * 0.30, h * 0.09, w * 0.32, h * 0.22);

  /// หน้าต่างหลังร้าน (ของตายตัว)
  Rect get backWindowRect =>
      Rect.fromLTWH(w * 0.70, h * 0.10, w * 0.20, h * 0.21);

  /// กองลังไม้มุมหลังร้าน (ของตายตัว)
  Rect get cratesRect =>
      Rect.fromLTWH(w * 0.80, floorTop - h * 0.10, w * 0.16, h * 0.16);

  /// จุดยืนทำงานหน้าสถานีแต่ละอัน (เท้าผู้เล่น)
  Offset get blendBarStand => Offset(blendBarRect.center.dx, floorY(0.30));

  Offset get shelfStand => Offset(shelfRect.center.dx, floorY(0.29));

  Offset get binStand => Offset(binRect.center.dx, floorY(0.28));

  // ---- หน้าร้าน (x: w..2w) ----

  /// ประตูถนนขวาสุดของโลก — ลูกค้าโผล่จากตรงนี้
  Rect get doorRect =>
      Rect.fromLTWH(frontX + w * 0.84, floorTop - h * 0.32, w * 0.13, h * 0.32);

  Offset get doorSpawn => Offset(frontX + w * 0.905, floorY(0.10));

  /// จุดกลางหน้าร้าน (ปุ่มกระดิ่งเรียกกลับมาที่นี่)
  Offset get frontRoomCenter => Offset(frontX + w * 0.45, floorY(0.50));

  /// จุดศูนย์กลางแผงโชว์แต่ละแผง (สัดส่วนภายในหน้าร้าน)
  static const _standAnchors = <Offset>[
    Offset(0.16, 0.46),
    Offset(0.55, 0.44),
    Offset(0.24, 0.76),
    Offset(0.65, 0.74),
  ];

  /// กล่องแผงโชว์น้ำหอมตัวอย่าง (พื้นที่วาด + โซนแตะ)
  Rect standRect(int i) {
    assert(i >= 0 && i < Balance.standCount);
    final a = _standAnchors[i];
    return Rect.fromCenter(
      center: Offset(frontX + w * a.dx, floorY(a.dy)),
      width: w * 0.20,
      height: h * 0.125,
    );
  }

  /// จุดเท้าลูกค้าตอนยืนเลือกดู (ด้านหลังแผง หันหน้าเข้าจอ)
  Offset browsePoint(int i) {
    final r = standRect(i);
    return Offset(r.center.dx, r.top + r.height * 0.22);
  }

  /// จุดยืนของผู้เล่นตอนมาเสิร์ฟ (ด้านหน้าแผง)
  Offset serveStand(int i) {
    final r = standRect(i);
    return Offset(r.center.dx, r.bottom + h * 0.035);
  }

  // ---- เขตเดิน (ต่อเนื่องทั้งโลก ผ่านซุ้มได้เลย) ----

  Rect get walkableRect =>
      Rect.fromLTRB(w * 0.05, floorY(0.16), worldW - w * 0.05, h * 0.97);

  Offset clampToWalkable(Offset p) => Offset(
    p.dx.clamp(walkableRect.left, walkableRect.right),
    p.dy.clamp(walkableRect.top, walkableRect.bottom),
  );

  /// ขนาดตัวลูกค้า/ผู้เล่น — สัดส่วนล็อกตาม sprite พิกเซล (16×20)
  Size get customerSize => Size(w * 0.105, w * 0.105 * 1.25);

  Size get playerSize => Size(w * 0.115, w * 0.115 * 1.25);

  // ---- ช่องวางของตกแต่ง (หน้าร้านทั้งหมด — โซนที่ลูกค้าเห็น) ----

  /// กล่องของชิ้นที่วางบนชั้น [layer] เริ่มช่อง [slot] กว้าง [cells] ช่อง
  Rect slotRect(DecorLayer layer, int slot, int cells) => switch (layer) {
    DecorLayer.wall => _bandRect(
      slot,
      cells,
      start: 0.08,
      end: 0.78,
      count: DecorLayer.wall.slotCount,
      top: h * 0.08,
      height: h * 0.17,
    ),
    DecorLayer.floor => _bandRect(
      slot,
      cells,
      start: 0.36,
      end: 0.80,
      count: DecorLayer.floor.slotCount,
      top: floorY(0.06) - h * 0.17,
      height: h * 0.17,
    ),
    DecorLayer.rug => _bandRect(
      slot,
      cells,
      start: 0.06,
      end: 0.94,
      count: DecorLayer.rug.slotCount,
      top: floorY(0.42),
      height: floorDepth * 0.30,
    ),
    // วอลเปเปอร์ครอบผนังหน้าร้าน
    DecorLayer.wallpaper => Rect.fromLTWH(frontX, 0, w, floorTop),
  };

  /// แถบช่องวางภายในหน้าร้าน ([start]/[end] เป็นสัดส่วนของความกว้างหน้าร้าน)
  Rect _bandRect(
    int slot,
    int cells, {
    required double start,
    required double end,
    required int count,
    required double top,
    required double height,
  }) {
    final slotW = w * (end - start) / count;
    return Rect.fromLTWH(
      frontX + w * start + slotW * slot,
      top,
      slotW * cells,
      height,
    );
  }
}

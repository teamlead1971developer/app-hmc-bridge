import 'dart:ui';

import 'package:flame/components.dart';

import '../shop_game.dart';
import '../shop_painting.dart';
import 'customer.dart';

/// แผงโชว์น้ำหอมตัวอย่างหนึ่งแผงในหน้าร้าน —
/// วาดแท่นโชว์ และจำว่ามีลูกค้ายืนเลือกดูอยู่ไหม
class DisplayStand extends PositionComponent with HasGameReference<ShopGame> {
  DisplayStand(this.index);

  final int index;

  /// ลูกค้าที่จอง/ยืนดูแผงนี้อยู่ (จองตั้งแต่ตอนเดินเข้าร้าน)
  CustomerComponent? occupant;

  bool get isFree => occupant == null;

  @override
  Future<void> onLoad() async {
    _syncToRoom();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) _syncToRoom();
  }

  void _syncToRoom() {
    final rect = game.room.standRect(index);
    position = Vector2(rect.left, rect.top);
    size = Vector2(rect.width, rect.height);
    priority = rect.bottom.toInt();
  }

  @override
  void render(Canvas canvas) {
    paintDisplayStand(canvas, Size(size.x, size.y));
  }
}

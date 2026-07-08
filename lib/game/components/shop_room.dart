import 'dart:ui';

import 'package:flame/components.dart';

import '../shop_game.dart';
import '../shop_painting.dart';

/// ฉากหลังทั้งโลก (สองห้อง): โครงห้อง + ของตกแต่งที่ผู้เล่นวางไว้ในหน้าร้าน
class ShopRoom extends Component with HasGameReference<ShopGame> {
  ShopRoom() : super(priority: -10);

  @override
  void render(Canvas canvas) {
    final room = game.room;
    final placed = game.save.placed;
    paintRoom(canvas, room, wallpaper: activeWallpaper(placed));
    paintPlacedDecor(canvas, room, placed);
  }
}

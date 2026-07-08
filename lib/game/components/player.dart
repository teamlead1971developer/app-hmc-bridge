import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../theme/palette.dart';
import '../pixel/sprites.dart';
import '../shop_game.dart';

/// ตัวละครเจ้าของร้าน — เดินตามจุดที่แตะ (tap-to-move) แบบนุ่มนวล:
/// เร่งตอนออกตัว ชะลอก่อนถึงเป้า พร้อม squash-stretch เบาๆ ระหว่างเดิน
class PlayerComponent extends PositionComponent
    with HasGameReference<ShopGame> {
  PlayerComponent({required Vector2 spawn})
    : super(position: spawn, anchor: Anchor.bottomCenter);

  Vector2? _target;
  void Function()? _onArrive;

  double _speed = 0; // ความเร็วปัจจุบัน (px/s) — ไต่ขึ้น/ลงแบบนุ่ม
  double _walkPhase = 0;
  bool _facingLeft = false;

  @override
  Future<void> onLoad() async {
    final s = game.room.playerSize;
    size = Vector2(s.width, s.height);
  }

  /// สั่งเดินไป [target] (จุดเท้า) — [onArrive] ทำงานครั้งเดียวเมื่อถึง
  void walkTo(Offset target, {void Function()? onArrive}) {
    _target = Vector2(target.dx, target.dy);
    _onArrive = onArrive;
  }

  bool get isWalking => _target != null;

  @override
  void update(double dt) {
    super.update(dt);
    priority = position.y.toInt();

    final target = _target;
    if (target == null) {
      // ผ่อนความเร็วลงจนหยุดสนิท
      _speed = math.max(0, _speed - game.size.x * 2.2 * dt);
      return;
    }

    final delta = target - position;
    final dist = delta.length;
    final maxSpeed = game.size.x * 0.46;
    // ชะลอเมื่อใกล้เป้า (ease-out): ความเร็วเป้าหมายแปรตามระยะที่เหลือ
    final desired = math.min(maxSpeed, dist * 5.5 + game.size.x * 0.04);
    // ไต่เข้าใกล้ความเร็วเป้าหมายแบบนุ่ม (ease-in ตอนออกตัว)
    final blend = math.min(1.0, dt * 9);
    _speed += (desired - _speed) * blend;

    final step = _speed * dt;
    if (dist > step) {
      position += delta.normalized() * step;
      _walkPhase += dt * (6 + 6 * (_speed / maxSpeed));
      if (delta.x.abs() > 0.5) _facingLeft = delta.x < 0;
    } else {
      position.setFrom(target);
      _target = null;
      _speed = 0;
      _walkPhase = 0;
      final action = _onArrive;
      _onArrive = null;
      action?.call();
    }
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    final frame = isWalking
        ? CharFrame.walkStart + _walkPhase.floor() % CharFrame.walkCount
        : CharFrame.idleHappy;
    PixelSprites.I.playerSheet.drawFrame(
      canvas,
      frame,
      Rect.fromLTWH(0, 0, w, h),
      flipH: _facingLeft,
    );

    // ของบนถาดลอยเหนือหัว (ถาดไม้ + กล่องของทรงเหลี่ยม pixel)
    final tray = game.tray.value;
    if (tray.isEmpty) return;
    Paint fill(Color c) => Paint()
      ..color = c
      ..isAntiAlias = false;
    final s = w * 0.26;
    final trayW = s * 1.3 * tray.length + 6;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(w * 0.5, -h * 0.08),
        width: trayW,
        height: 5,
      ),
      fill(Palette.woodDark),
    );
    final startX = w * 0.5 - (tray.length - 1) * s * 0.65;
    for (var i = 0; i < tray.length; i++) {
      final c = Offset(startX + i * s * 1.3, -h * 0.08 - 3 - s / 2);
      final itemColor = switch (tray[i]) {
        TrayBlend(:final mixed) =>
          mixed.isEmpty ? Palette.latte : mixed.last.color,
        TrayProduct(:final product) => product.color,
      };
      final box = Rect.fromCenter(center: c, width: s, height: s);
      canvas.drawRect(box.inflate(2), fill(Palette.espresso));
      canvas.drawRect(box, fill(Palette.white));
      canvas.drawRect(box.deflate(s * 0.2), fill(itemColor));
      canvas.drawRect(
        Rect.fromLTWH(box.left + 2, box.top + 2, 3, 3),
        fill(Palette.white.withValues(alpha: 0.9)),
      );
    }
  }
}

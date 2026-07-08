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

    // ของบนถาดลอยเหนือหัว
    final tray = game.tray.value;
    if (tray.isEmpty) return;
    final r = w * 0.14;
    final startX = w * 0.5 - (tray.length - 1) * r * 1.4;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, -h * 0.10),
        width: r * 2.8 * tray.length,
        height: r * 1.2,
      ),
      Paint()..color = Palette.woodDark,
    );
    for (var i = 0; i < tray.length; i++) {
      final c = Offset(startX + i * r * 2.8, -h * 0.16);
      final itemColor = switch (tray[i]) {
        TrayBlend(:final mixed) =>
          mixed.isEmpty ? Palette.latte : mixed.last.color,
        TrayProduct(:final product) => product.color,
      };
      canvas.drawCircle(c, r, Paint()..color = Palette.white);
      canvas.drawCircle(c, r * 0.66, Paint()..color = itemColor);
      canvas.drawCircle(
        c + Offset(-r * 0.25, -r * 0.25),
        r * 0.18,
        Paint()..color = Palette.white.withValues(alpha: 0.8),
      );
    }
  }
}

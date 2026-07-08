import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../theme/palette.dart';

final _rng = math.Random();

/// ละอองหอมหนึ่งเม็ด: ลอยขึ้น โตขึ้น แล้วจางหาย
class MistPuff extends PositionComponent {
  MistPuff({
    required Vector2 super.position,
    this.baseRadius = 5,
    this.life = 1.8,
    this.color = Palette.lavender,
  }) : super(anchor: Anchor.center, priority: 50000) {
    _drift = (_rng.nextDouble() - 0.5) * 14;
  }

  final double baseRadius;
  final double life;
  final Color color;

  double _age = 0;
  late final double _drift;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= life) {
      removeFromParent();
      return;
    }
    position.y -= 26 * dt;
    position.x += _drift * dt;
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / life).clamp(0.0, 1.0);
    final alpha = (1 - t) * 0.35;
    final radius = baseRadius * (0.7 + t * 1.1);
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..color = color.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
  }
}

/// ตัวปล่อยละอองหอมจากจุดหนึ่งเป็นระยะ (เช่นเหนือโต๊ะปรุงน้ำหอม)
class MistEmitter extends Component {
  MistEmitter({
    required this.at,
    this.interval = 0.9,
    this.color = Palette.lavender,
  });

  /// ตำแหน่งปล่อย (คำนวณใหม่ทุกครั้ง เผื่อจอ resize)
  final Vector2 Function() at;
  final double interval;
  final Color color;

  double _timer = 0.4;

  @override
  void update(double dt) {
    super.update(dt);
    _timer -= dt;
    if (_timer <= 0) {
      _timer = interval * (0.7 + _rng.nextDouble() * 0.6);
      final p = at();
      parent?.add(
        MistPuff(
          position: p + Vector2((_rng.nextDouble() - 0.5) * 14, 0),
          baseRadius: 4 + _rng.nextDouble() * 3,
          color: color,
        ),
      );
    }
  }
}

/// ประกายเพชรเล็กๆ กระจายออกแล้วจาง (ตอนเสิร์ฟสำเร็จ/ค้นพบกลิ่นใหม่)
class Sparkle extends PositionComponent {
  Sparkle({required Vector2 super.position, this.color = Palette.gold})
    : super(anchor: Anchor.center, priority: 60000) {
    final angle = _rng.nextDouble() * math.pi * 2;
    final speed = 34 + _rng.nextDouble() * 40;
    _velocity = Vector2(math.cos(angle), math.sin(angle) - 0.6) * speed;
    _size = 2.5 + _rng.nextDouble() * 2.5;
  }

  static const _life = 0.65;
  final Color color;
  late final Vector2 _velocity;
  late final double _size;
  double _age = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _life) {
      removeFromParent();
      return;
    }
    position += _velocity * dt;
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _life).clamp(0.0, 1.0);
    final s = _size * (1 - t * 0.6);
    final diamond = Path()
      ..moveTo(0, -s * 1.6)
      ..lineTo(s, 0)
      ..lineTo(0, s * 1.6)
      ..lineTo(-s, 0)
      ..close();
    canvas.drawPath(
      diamond,
      Paint()..color = color.withValues(alpha: 1 - t),
    );
  }
}

/// หัวใจลอยขึ้นพร้อมส่ายเบาๆ (ลูกค้าพอใจ)
class HeartFloat extends PositionComponent {
  HeartFloat({required Vector2 super.position})
    : super(anchor: Anchor.center, priority: 60000);

  static const _life = 1.0;
  double _age = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _life) {
      removeFromParent();
      return;
    }
    position.y -= 46 * dt;
    position.x += math.sin(_age * 9) * 12 * dt;
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / _life).clamp(0.0, 1.0);
    final s = 6.0 * (1 + t * 0.25);
    final heart = Path()
      ..moveTo(0, s * 0.9)
      ..cubicTo(-s * 1.5, -s * 0.2, -s * 0.7, -s * 1.2, 0, -s * 0.35)
      ..cubicTo(s * 0.7, -s * 1.2, s * 1.5, -s * 0.2, 0, s * 0.9);
    canvas.drawPath(
      heart,
      Paint()..color = Palette.blush.withValues(alpha: 1 - t * t),
    );
  }
}

/// ยิงประกาย + หัวใจชุดหนึ่งที่ตำแหน่ง [at] — [parent] คือเกม
void spawnServeBurst(Component parent, Vector2 at) {
  for (var i = 0; i < 7; i++) {
    parent.add(Sparkle(position: at.clone()));
  }
  parent.add(HeartFloat(position: at - Vector2(0, 8)));
}

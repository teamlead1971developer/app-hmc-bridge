import 'package:flame/components.dart';
import 'package:flutter/animation.dart' show Curves;
import 'package:flutter/painting.dart';

/// ตัวหนังสือลอยขึ้นแบบ ease-out แล้วค่อยๆ จางหาย (เช่น "+62" ตอนได้เงิน)
class FloatingText extends TextComponent {
  FloatingText(
    String text, {
    required Vector2 position,
    required Color color,
  }) : _baseColor = color,
       _startY = position.y,
       super(
         text: text,
         position: position,
         anchor: Anchor.center,
         // ตัวละครใช้ priority = พิกัด y (หลักร้อยถึงพัน) — ต้องลอยเหนือทุกตัว
         priority: 100000,
       );

  static const _life = 1.1;
  static const _rise = 52.0;

  final Color _baseColor;
  final double _startY;
  double _age = 0;

  @override
  Future<void> onLoad() async {
    _applyStyle(1);
  }

  void _applyStyle(double alpha) {
    textRenderer = TextPaint(
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: _baseColor.withValues(alpha: alpha),
        shadows: [
          Shadow(color: Color.fromRGBO(0, 0, 0, 0.4 * alpha), blurRadius: 4),
        ],
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _life) {
      removeFromParent();
      return;
    }
    final t = (_age / _life).clamp(0.0, 1.0);
    position.y = _startY - _rise * Curves.easeOutCubic.transform(t);
    // จางเฉพาะช่วงท้าย อ่านทันก่อนหาย
    _applyStyle(t < 0.55 ? 1.0 : 1.0 - (t - 0.55) / 0.45);
  }
}

import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart'
    show TextPainter, TextSpan, TextStyle, TextDirection, FontWeight;

import '../../models/customer_order.dart';
import '../../theme/palette.dart';
import '../pixel/sprites.dart';
import '../shop_game.dart';
import '../shop_painting.dart';

enum CustomerState { entering, seated, leaving }

/// ลูกค้าหนึ่งคน: เดินเข้าร้าน → นั่งโต๊ะที่จองไว้ → โชว์ออเดอร์รอเสิร์ฟ
/// → ได้ครบ/หมดความอดทน → เดินออก (เดินแบบเร่ง-ชะลอนุ่มนวลเหมือนผู้เล่น)
class CustomerComponent extends PositionComponent
    with HasGameReference<ShopGame> {
  CustomerComponent({
    required this.order,
    required this.color,
    required this.standIndex,
    required Vector2 spawn,
  }) : super(position: spawn, anchor: Anchor.bottomCenter);

  final CustomerOrder order;
  final Color color;

  /// แผงโชว์ที่ลูกค้าคนนี้จองไว้
  final int standIndex;

  CustomerState state = CustomerState.entering;
  CustomerMood mood = CustomerMood.neutral;
  double patienceLeft = 0;

  /// ของที่ยังไม่ได้เสิร์ฟ (ตั้งต้นจากออเดอร์ แล้วค่อยๆ ถูกหักออก)
  bool blendPending = false;
  bool productPending = false;

  /// มีชิ้นไหนถูกเสิร์ฟแบบผิดสูตรไหม (ตัดสิทธิ์ทิป)
  bool anyWrong = false;

  double _speed = 0;
  double _walkPhase = 0;
  bool _facingLeft = false;
  bool _moving = false;
  final _labelPainters = <TextPainter>[];

  bool get orderComplete => !blendPending && !productPending;

  @override
  Future<void> onLoad() async {
    final s = game.room.customerSize;
    size = Vector2(s.width, s.height);
    patienceLeft = order.patienceSeconds;
    blendPending = order.blend != null;
    productPending = order.product != null;

    for (final name in [order.blend?.name, order.product?.name]) {
      if (name == null) continue;
      _labelPainters.add(
        TextPainter(
          text: TextSpan(
            text: name,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Palette.espresso,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(),
      );
    }
  }

  Vector2 get _target {
    final room = game.room;
    final p = switch (state) {
      CustomerState.leaving => room.doorSpawn,
      _ => room.browsePoint(standIndex),
    };
    return Vector2(p.dx, p.dy);
  }

  @override
  void update(double dt) {
    super.update(dt);
    priority = position.y.toInt();

    final target = _target;
    final delta = target - position;
    final dist = delta.length;
    final maxSpeed = game.size.x * 0.26;
    final desired = math.min(maxSpeed, dist * 5.0 + game.size.x * 0.03);
    _speed += (desired - _speed) * math.min(1.0, dt * 8);
    final step = _speed * dt;

    if (dist > step) {
      position += delta.normalized() * step;
      // ความเร็วเฟรมเดินแปรตามความเร็วจริง (sprite walk cycle)
      _walkPhase += dt * (5 + 5 * (_speed / maxSpeed));
      _moving = true;
      if (delta.x.abs() > 0.5) _facingLeft = delta.x < 0;
    } else {
      position.setFrom(target);
      _speed = 0;
      _walkPhase = 0;
      _moving = false;
      if (state == CustomerState.entering) state = CustomerState.seated;
      if (state == CustomerState.leaving) {
        removeFromParent();
        return;
      }
    }

    // ความอดทนนับเฉพาะตอนนั่งรอแล้ว
    if (state == CustomerState.seated) {
      patienceLeft -= dt;
      if (patienceLeft <= 0) {
        game.customerLost(this);
      }
    }
  }

  void leave({required bool happy}) {
    mood = happy ? CustomerMood.happy : CustomerMood.angry;
    state = CustomerState.leaving;
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    final frame = _moving
        ? CharFrame.walkStart + _walkPhase.floor() % CharFrame.walkCount
        : switch (mood) {
            CustomerMood.neutral => CharFrame.idleNeutral,
            CustomerMood.happy => CharFrame.idleHappy,
            CustomerMood.angry => CharFrame.idleAngry,
          };
    PixelSprites.I
        .sheetFor(color)
        .drawFrame(canvas, frame, Rect.fromLTWH(0, 0, w, h), flipH: _facingLeft);

    if (state != CustomerState.seated) return;

    // แถบความอดทนเหนือหัว
    final ratio = (patienceLeft / order.patienceSeconds).clamp(0.0, 1.0);
    final barRect = Rect.fromLTWH(w * 0.1, -h * 0.12, w * 0.8, h * 0.06);
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, Radius.circular(h * 0.03)),
      Paint()..color = Palette.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barRect.left, barRect.top, barRect.width * ratio, barRect.height),
        Radius.circular(h * 0.03),
      ),
      Paint()..color = Color.lerp(Palette.angry, Palette.happy, ratio)!,
    );

    _renderOrderBubble(canvas, w, h);
  }

  /// บับเบิลออเดอร์: บรรทัดละชิ้นที่ยังไม่ได้เสิร์ฟ (ชื่อ + จุดสีกลิ่น/สินค้า)
  void _renderOrderBubble(Canvas canvas, double w, double h) {
    final lines = <({TextPainter label, List<Color> dots, bool served})>[];
    var painterIndex = 0;
    if (order.blend case final blend?) {
      lines.add((
        label: _labelPainters[painterIndex],
        dots: [for (final note in blend.recipe) note.color],
        served: !blendPending,
      ));
      painterIndex++;
    }
    if (order.product case final product?) {
      lines.add((
        label: _labelPainters[painterIndex],
        dots: [product.color],
        served: !productPending,
      ));
    }

    final lineH = h * 0.30;
    final maxLabelW = lines.map((l) => l.label.width).reduce(math.max);
    final bubbleH = lineH * lines.length + h * 0.16;
    final bubble = Rect.fromCenter(
      // ชิดหัวลูกค้า (โต๊ะสองแถวอยู่ใกล้กัน อย่าให้บับเบิลลอยไปทับแถวบน)
      center: Offset(w * 0.5, -h * 0.24 - bubbleH / 2),
      width: math.max(w * 1.7, maxLabelW + w * 0.9),
      height: bubbleH,
    );
    final tail = Path()
      ..moveTo(w * 0.40, bubble.bottom - 1)
      ..lineTo(w * 0.50, bubble.bottom + h * 0.09)
      ..lineTo(w * 0.64, bubble.bottom - 1)
      ..close();
    // เงาบับเบิลจางๆ ให้ลอยจากฉาก
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        bubble.translate(0, h * 0.02),
        Radius.circular(h * 0.12),
      ),
      Paint()
        ..color = Palette.shadow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawPath(tail, Paint()..color = Palette.white);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bubble, Radius.circular(h * 0.12)),
      Paint()..color = Palette.white,
    );

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final top = bubble.top + h * 0.08 + lineH * i;
      final dimmed = line.served ? 0.25 : 1.0;

      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, dimmed));
      line.label.paint(canvas, Offset(bubble.left + w * 0.16, top));

      final dotR = lineH * 0.20;
      for (var d = 0; d < line.dots.length; d++) {
        final c = Offset(
          bubble.right - w * 0.16 - dotR * 2.4 * (line.dots.length - 1 - d),
          top + lineH * 0.28,
        );
        canvas.drawCircle(c, dotR + 1.2, Paint()..color = Palette.shadow);
        canvas.drawCircle(c, dotR, Paint()..color = line.dots[d]);
      }
      if (line.served) {
        canvas.drawLine(
          Offset(bubble.left + w * 0.12, top + lineH * 0.28),
          Offset(bubble.right - w * 0.12, top + lineH * 0.28),
          Paint()
            ..color = Palette.sageDark
            ..strokeWidth = 2.5,
        );
      }
      canvas.restore();
    }
  }
}

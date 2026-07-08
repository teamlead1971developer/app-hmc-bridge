import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// กรอบสไตล์ pixel chibi: มุมโค้งแบบขั้นบันได + เส้นขอบหนา
/// เป็น [OutlinedBorder] จึงใช้ได้ทั้งปุ่ม/dialog ผ่าน theme และ ShapeDecoration
class PixelBorder extends OutlinedBorder {
  const PixelBorder({
    super.side = const BorderSide(color: Palette.espresso, width: 3),
    this.corner = 10,
  });

  /// ขนาดมุมตัด (สองขั้นบันไดในระยะนี้)
  final double corner;

  /// เส้นทางกรอบมุมขั้นบันได (pixel-rounded rect)
  Path _path(Rect r, double inset) {
    final rect = r.deflate(inset);
    final c = corner.clamp(0, rect.shortestSide / 3).toDouble();
    final u = c / 2; // หนึ่งขั้นบันได
    final l = rect.left;
    final t = rect.top;
    final rr = rect.right;
    final b = rect.bottom;
    return Path()
      // เริ่มบนซ้าย ไล่ตามเข็มนาฬิกา
      ..moveTo(l + c, t)
      ..lineTo(rr - c, t)
      ..lineTo(rr - c, t + u)
      ..lineTo(rr - u, t + u)
      ..lineTo(rr - u, t + c)
      ..lineTo(rr, t + c)
      ..lineTo(rr, b - c)
      ..lineTo(rr - u, b - c)
      ..lineTo(rr - u, b - u)
      ..lineTo(rr - c, b - u)
      ..lineTo(rr - c, b)
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

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _path(rect, side.width);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _path(rect, 0);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width <= 0) return;
    // วาดขอบแบบ stroke ตามแนวกึ่งกลางเส้น (Path.combine เพี้ยนบนบางแพลตฟอร์ม)
    canvas.drawPath(
      _path(rect, side.width / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = side.width
        ..strokeJoin = StrokeJoin.miter
        ..color = side.color
        ..isAntiAlias = false,
    );
  }

  @override
  ShapeBorder scale(double t) =>
      PixelBorder(side: side.scale(t), corner: corner * t);

  @override
  PixelBorder copyWith({BorderSide? side, double? corner}) =>
      PixelBorder(side: side ?? this.side, corner: corner ?? this.corner);
}

/// แผงกล่องสไตล์ pixel: พื้น + กรอบหนา + เงาตกแบบ hard-edge (ไม่เบลอ)
class PixelPanel extends StatelessWidget {
  const PixelPanel({
    super.key,
    this.fill = Palette.white,
    this.borderColor = Palette.espresso,
    this.borderWidth = 3,
    this.corner = 10,
    this.shadow = true,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.width,
    this.child,
  });

  final Color fill;
  final Color borderColor;
  final double borderWidth;
  final double corner;
  final bool shadow;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin,
      padding: padding,
      decoration: ShapeDecoration(
        color: fill,
        shape: PixelBorder(
          side: BorderSide(color: borderColor, width: borderWidth),
          corner: corner,
        ),
        shadows: shadow
            ? const [
                BoxShadow(
                  color: Palette.shadow,
                  offset: Offset(0, 5),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

/// แถบ progress สไตล์ pixel: กรอบหนา เติมเป็นก้อนๆ ทีละ 4px มีเส้นไฮไลต์บน
class PixelProgressBar extends StatelessWidget {
  const PixelProgressBar({
    super.key,
    required this.value,
    this.color = Palette.lilacDeep,
    this.background = Palette.cream,
    this.height = 12,
  });

  final double value;
  final Color color;
  final Color background;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _PixelBarPainter(
          value: value.clamp(0.0, 1.0),
          color: color,
          background: background,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _PixelBarPainter extends CustomPainter {
  _PixelBarPainter({
    required this.value,
    required this.color,
    required this.background,
  });

  final double value;
  final Color color;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    Paint fill(Color c) => Paint()
      ..color = c
      ..isAntiAlias = false;

    const bw = 2.0; // ขอบ
    canvas.drawRect(Offset.zero & size, fill(Palette.espresso));
    final inner = Rect.fromLTWH(bw, bw, size.width - bw * 2, size.height - bw * 2);
    canvas.drawRect(inner, fill(background));
    if (value > 0) {
      // เติมทีละก้อน 4px ให้ดูเป็นพิกเซล
      final w = ((inner.width * value) / 4).floorToDouble() * 4;
      final bar = Rect.fromLTWH(inner.left, inner.top, w.clamp(2, inner.width), inner.height);
      canvas.drawRect(bar, fill(color));
      canvas.drawRect(
        Rect.fromLTWH(bar.left, bar.top, bar.width, 2),
        fill(Color.lerp(color, Colors.white, 0.4)!),
      );
    }
  }

  @override
  bool shouldRepaint(_PixelBarPainter old) =>
      old.value != value || old.color != color || old.background != background;
}

/// ป้ายหัวเรื่องแบบริบบิ้น pixel (ไว้หัว dialog/แผง)
class PixelRibbon extends StatelessWidget {
  const PixelRibbon({
    super.key,
    required this.text,
    this.fill = Palette.lilacDeep,
  });

  final String text;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      fill: fill,
      corner: 6,
      borderWidth: 2.5,
      shadow: false,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          color: Palette.white,
        ),
      ),
    );
  }
}

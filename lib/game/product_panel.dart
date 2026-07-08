import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/palette.dart';
import '../widgets/pixel_ui.dart';
import 'shop_painting.dart';

/// แผงชั้นสินค้าสำเร็จ (เด้งขึ้นเมื่อผู้เล่นเดินถึงชั้น): แตะชิ้นที่ต้องการหยิบ
class ProductPanel extends StatefulWidget {
  const ProductPanel({super.key, required this.onTake, required this.onClose});

  /// คืน false เมื่อถาดเต็ม
  final bool Function(Product product) onTake;
  final VoidCallback onClose;

  @override
  State<ProductPanel> createState() => _ProductPanelState();
}

class _ProductPanelState extends State<ProductPanel> {
  String? _feedback;
  Color _feedbackColor = Palette.mocha;

  void _take(Product product) {
    final added = widget.onTake(product);
    setState(() {
      if (added) {
        _feedback = 'หยิบ${product.name}ใส่ถาดแล้ว 🕯️';
        _feedbackColor = Palette.sageDark;
      } else {
        _feedback = 'ถาดเต็มแล้ว! ไปเสิร์ฟหรือเททิ้งก่อน';
        _feedbackColor = Palette.angry;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Palette.counterTop,
        border: Border(
          top: BorderSide(color: Palette.espresso, width: 3.5),
          left: BorderSide(color: Palette.espresso, width: 3.5),
          right: BorderSide(color: Palette.espresso, width: 3.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: .min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _feedback ?? 'ชั้นสินค้า — แตะชิ้นที่ต้องการหยิบ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _feedback == null ? Palette.espresso : _feedbackColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  tooltip: 'ปิด',
                  icon: const Icon(Icons.close_rounded, color: Palette.mocha),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                for (final product in ProductCatalog.all)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => _take(product),
                        child: PixelPanel(
                          fill: Palette.white,
                          borderWidth: 2.5,
                          corner: 6,
                          shadow: false,
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisSize: .min,
                            children: [
                              SizedBox(
                                width: 48,
                                height: 44,
                                child: CustomPaint(
                                  painter: _ProductPainter(product),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: .ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Palette.espresso,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductPainter extends CustomPainter {
  _ProductPainter(this.product);

  final Product product;

  @override
  void paint(Canvas canvas, Size size) => paintProduct(canvas, size, product);

  @override
  bool shouldRepaint(_ProductPainter oldDelegate) =>
      oldDelegate.product != product;
}

import 'product.dart';
import 'scent_blend.dart';

/// ออเดอร์ของลูกค้าหนึ่งคน — มีน้ำหอมผสม และ/หรือ สินค้าสำเร็จ อย่างน้อยหนึ่งอย่าง
class CustomerOrder {
  const CustomerOrder({
    this.blend,
    this.product,
    required this.patienceSeconds,
  }) : assert(
         blend != null || product != null,
         'ออเดอร์ต้องมีของอย่างน้อยหนึ่งอย่าง',
       );

  final ScentBlend? blend;
  final Product? product;

  /// เวลาความอดทนทั้งหมด (วินาที) เริ่มนับเมื่อนั่งโต๊ะแล้ว
  final double patienceSeconds;

  /// จำนวนชิ้นทั้งหมดที่ต้องเสิร์ฟ
  int get itemCount => (blend != null ? 1 : 0) + (product != null ? 1 : 0);

  /// ราคารวมเต็มของออเดอร์
  int get totalPrice => (blend?.price ?? 0) + (product?.price ?? 0);
}

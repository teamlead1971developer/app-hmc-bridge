import 'dart:ui' show Color;

/// รูปทรงของสินค้า — ตัวกำหนดว่าจะวาดด้วยลายอะไร
enum ProductKind { candle, sachet, soap }

/// สินค้าสำเร็จบนชั้นวาง — หยิบได้เลยไม่ต้องปรุง ราคาเป็นเหรียญ (int เสมอ)
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.unlockDay,
    required this.color,
    required this.kind,
  });

  final String id;
  final String name;
  final int price;

  /// สินค้านี้เริ่มมีลูกค้าสั่งตั้งแต่วันที่เท่าไร
  final int unlockDay;

  /// สีหลักของสินค้า ใช้ทั้งตอนวาดและไอคอนบนถาด
  final Color color;
  final ProductKind kind;
}

abstract final class ProductCatalog {
  static const all = <Product>[
    Product(
      id: 'candle',
      name: 'เทียนหอม',
      price: 45,
      unlockDay: 3,
      color: Color(0xFFEFC98B),
      kind: ProductKind.candle,
    ),
    Product(
      id: 'sachet',
      name: 'ถุงหอมลาเวนเดอร์',
      price: 50,
      unlockDay: 3,
      color: Color(0xFFC5AEE0),
      kind: ProductKind.sachet,
    ),
    Product(
      id: 'soap',
      name: 'สบู่ดอกไม้',
      price: 55,
      unlockDay: 4,
      color: Color(0xFFF3B8C3),
      kind: ProductKind.soap,
    ),
  ];

  static List<Product> forDay(int day) =>
      all.where((p) => p.unlockDay <= day).toList();
}

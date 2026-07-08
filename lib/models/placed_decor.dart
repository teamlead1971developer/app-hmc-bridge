import 'decor_item.dart';

/// ของตกแต่งที่ซื้อและวางในร้านแล้ว
class PlacedDecor {
  const PlacedDecor({required this.itemId, required this.slot});

  factory PlacedDecor.fromJson(Map<String, dynamic> json) => PlacedDecor(
    itemId: json['itemId'] as String,
    slot: json['slot'] as int,
  );

  final String itemId;

  /// ช่องเริ่มต้นบนชั้นของ item นั้น (ชิ้นที่กินหลายช่องนับจากช่องนี้ไปทางขวา)
  final int slot;

  DecorItem get item => DecorCatalog.byId(itemId);

  Map<String, dynamic> toJson() => {'itemId': itemId, 'slot': slot};
}

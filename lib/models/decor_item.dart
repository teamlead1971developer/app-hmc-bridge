/// ชั้นการวางของตกแต่งในห้อง — แต่ละชั้นมีช่อง (slot) ของตัวเอง
enum DecorLayer {
  /// เปลี่ยนสีผนังทั้งห้อง มีได้ทีละ 1 ชิ้น
  wallpaper(slotCount: 1),

  /// ของแขวนผนัง
  wall(slotCount: 6),

  /// พรม (วาดใต้เฟอร์นิเจอร์และลูกค้า)
  rug(slotCount: 3),

  /// เฟอร์นิเจอร์ตั้งพื้น (แนวชิดผนังด้านหลัง)
  floor(slotCount: 4);

  const DecorLayer({required this.slotCount});

  final int slotCount;
}

/// ชนิดของของตกแต่ง — ตัวกำหนดว่าจะวาดด้วยลายอะไร
enum DecorKind {
  painting,
  clock,
  shelfPlants,
  stringLights,
  plant,
  floorLamp,
  bookshelf,
  armchair,
  cafeTable,
  rugRound,
  rugLong,
  wallpaperSage,
  wallpaperPeach,
}

/// ของตกแต่งหนึ่งชนิดในแคตตาล็อกร้านค้า — ราคาเป็นเหรียญ (int เสมอ)
class DecorItem {
  const DecorItem({
    required this.id,
    required this.name,
    required this.price,
    required this.ambiance,
    required this.kind,
    required this.layer,
    this.cells = 1,
  });

  final String id;
  final String name;
  final int price;

  /// แต้มบรรยากาศ ⭐ ที่ชิ้นนี้ให้ — รวมกันแล้วไปคูณความอดทน/ทิปของลูกค้า
  final int ambiance;
  final DecorKind kind;
  final DecorLayer layer;

  /// จำนวนช่องติดกันที่กินบนชั้นนั้น
  final int cells;
}

abstract final class DecorCatalog {
  static const all = <DecorItem>[
    // ผนัง
    DecorItem(
      id: 'painting',
      name: 'กรอบรูปแมว',
      price: 60,
      ambiance: 3,
      kind: DecorKind.painting,
      layer: DecorLayer.wall,
    ),
    DecorItem(
      id: 'clock',
      name: 'นาฬิกาแขวน',
      price: 50,
      ambiance: 2,
      kind: DecorKind.clock,
      layer: DecorLayer.wall,
    ),
    DecorItem(
      id: 'shelf_plants',
      name: 'ชั้นต้นไม้เล็ก',
      price: 90,
      ambiance: 4,
      kind: DecorKind.shelfPlants,
      layer: DecorLayer.wall,
    ),
    DecorItem(
      id: 'string_lights',
      name: 'ไฟประดับ',
      price: 120,
      ambiance: 5,
      kind: DecorKind.stringLights,
      layer: DecorLayer.wall,
      cells: 2,
    ),
    // ตั้งพื้น
    DecorItem(
      id: 'plant',
      name: 'ต้นไม้กระถาง',
      price: 70,
      ambiance: 3,
      kind: DecorKind.plant,
      layer: DecorLayer.floor,
    ),
    DecorItem(
      id: 'floor_lamp',
      name: 'โคมไฟตั้งพื้น',
      price: 100,
      ambiance: 4,
      kind: DecorKind.floorLamp,
      layer: DecorLayer.floor,
    ),
    DecorItem(
      id: 'armchair',
      name: 'เก้าอี้นวม',
      price: 140,
      ambiance: 5,
      kind: DecorKind.armchair,
      layer: DecorLayer.floor,
    ),
    DecorItem(
      id: 'bookshelf',
      name: 'ชั้นหนังสือ',
      price: 150,
      ambiance: 6,
      kind: DecorKind.bookshelf,
      layer: DecorLayer.floor,
      cells: 2,
    ),
    DecorItem(
      id: 'cafe_table',
      name: 'โต๊ะกาแฟคู่',
      price: 160,
      ambiance: 6,
      kind: DecorKind.cafeTable,
      layer: DecorLayer.floor,
      cells: 2,
    ),
    // พรม
    DecorItem(
      id: 'rug_round',
      name: 'พรมกลม',
      price: 80,
      ambiance: 3,
      kind: DecorKind.rugRound,
      layer: DecorLayer.rug,
    ),
    DecorItem(
      id: 'rug_long',
      name: 'พรมยาว',
      price: 130,
      ambiance: 5,
      kind: DecorKind.rugLong,
      layer: DecorLayer.rug,
      cells: 2,
    ),
    // วอลเปเปอร์
    DecorItem(
      id: 'wallpaper_sage',
      name: 'วอลเปเปอร์เขียวเซจ',
      price: 200,
      ambiance: 8,
      kind: DecorKind.wallpaperSage,
      layer: DecorLayer.wallpaper,
    ),
    DecorItem(
      id: 'wallpaper_peach',
      name: 'วอลเปเปอร์พีช',
      price: 200,
      ambiance: 8,
      kind: DecorKind.wallpaperPeach,
      layer: DecorLayer.wallpaper,
    ),
  ];

  static DecorItem byId(String id) => all.firstWhere((d) => d.id == id);
}

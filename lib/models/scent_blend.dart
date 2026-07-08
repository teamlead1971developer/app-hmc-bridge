import 'dart:ui' show Color;

/// หัวน้ำมันหอมที่หยดผสมได้บนโต๊ะปรุงน้ำหอม
/// [unlockPrice] > 0 = ต้องซื้อปลดล็อกใน Scentorium ก่อนใช้ (0 = มีตั้งแต่ต้น)
enum ScentNote {
  lavender('ลาเวนเดอร์', Color(0xFFB39DDB), 0),
  rose('กุหลาบ', Color(0xFFF4A7B9), 0),
  bergamot('เบอร์กาม็อต', Color(0xFFC8D96F), 0),
  sandalwood('ไม้จันทน์', Color(0xFFA98467), 0),
  vanilla('วานิลลา', Color(0xFFF0DFAE), 0),
  whiteMusk('มัสก์ขาว', Color(0xFFEDE7F6), 0),
  jasmine('มะลิ', Color(0xFFEFF2D0), 300),
  lemongrass('ตะไคร้', Color(0xFF9FD08C), 600),
  amber('แอมเบอร์', Color(0xFFE5A34D), 1200),
  cedar('ซีดาร์วูด', Color(0xFF8B5E4B), 2000);

  const ScentNote(this.label, this.color, this.unlockPrice);

  final String label;
  final Color color;
  final int unlockPrice;

  /// โน้ตที่มีให้ตั้งแต่เริ่มเกม
  static List<ScentNote> get starters =>
      values.where((n) => n.unlockPrice == 0).toList();
}

/// สูตรน้ำหอม diffuser หนึ่งกลิ่น — ราคาเป็นเหรียญ (int เสมอ)
/// [secret] = สูตรลับ: ไม่โชว์ส่วนผสม ต้องทดลองผสมให้ตรงเองถึง "ค้นพบ"
class ScentBlend {
  const ScentBlend({
    required this.id,
    required this.name,
    required this.recipe,
    required this.price,
    this.unlockDay = 1,
    this.secret = false,
    this.hint = '',
  });

  final String id;
  final String name;

  /// หัวน้ำหอมที่ต้องหยด (เทียบแบบไม่สนลำดับ)
  final List<ScentNote> recipe;
  final int price;

  /// สูตรทั่วไป: เริ่มมีลูกค้าสั่งตั้งแต่วันนี้ (สูตรลับไม่ใช้ค่านี้)
  final int unlockDay;

  final bool secret;

  /// คำใบ้เชิงกวีของสูตรลับ (โชว์ใน Scentorium)
  final String hint;

  /// true ถ้ากลิ่นที่ผสมมาตรงกับสูตร (ไม่สนลำดับ แต่จำนวนต้องครบ)
  bool matches(List<ScentNote> mixed) {
    if (mixed.length != recipe.length) return false;
    final want = List<ScentNote>.of(recipe)..sort((a, b) => a.index - b.index);
    final got = List<ScentNote>.of(mixed)..sort((a, b) => a.index - b.index);
    for (var i = 0; i < want.length; i++) {
      if (want[i] != got[i]) return false;
    }
    return true;
  }

  /// ผสมได้ด้วยโน้ตที่มีอยู่ไหม
  bool craftableWith(Set<ScentNote> owned) => recipe.every(owned.contains);
}

abstract final class BlendCatalog {
  static const all = <ScentBlend>[
    // ---- สูตรทั่วไป: ปลดตามวัน สูตรโชว์ในสมุด ----
    ScentBlend(
      id: 'lavender_dream',
      name: 'ลาเวนเดอร์ดรีม',
      recipe: [ScentNote.lavender],
      price: 35,
      unlockDay: 1,
    ),
    ScentBlend(
      id: 'rose_garden',
      name: 'สวนกุหลาบ',
      recipe: [ScentNote.rose, ScentNote.whiteMusk],
      price: 50,
      unlockDay: 1,
    ),
    ScentBlend(
      id: 'citrus_spa',
      name: 'ซิตรัสสปา',
      recipe: [ScentNote.bergamot, ScentNote.lavender, ScentNote.whiteMusk],
      price: 60,
      unlockDay: 2,
    ),
    ScentBlend(
      id: 'sandal_forest',
      name: 'ป่าไม้จันทน์',
      recipe: [ScentNote.sandalwood, ScentNote.bergamot, ScentNote.whiteMusk],
      price: 65,
      unlockDay: 3,
    ),
    ScentBlend(
      id: 'warm_vanilla',
      name: 'วานิลลาอุ่น',
      recipe: [ScentNote.vanilla, ScentNote.sandalwood],
      price: 55,
      unlockDay: 4,
    ),
    ScentBlend(
      id: 'sweet_bouquet',
      name: 'บูเก้หวาน',
      recipe: [ScentNote.rose, ScentNote.vanilla, ScentNote.whiteMusk],
      price: 70,
      unlockDay: 5,
    ),
    ScentBlend(
      id: 'morning_jasmine',
      name: 'มะลิยามเช้า',
      recipe: [ScentNote.jasmine],
      price: 45,
      unlockDay: 6,
    ),
    ScentBlend(
      id: 'lemongrass_garden',
      name: 'ตะไคร้บ้านสวน',
      recipe: [ScentNote.lemongrass, ScentNote.bergamot],
      price: 55,
      unlockDay: 7,
    ),
    ScentBlend(
      id: 'golden_silk',
      name: 'มะลิไหมทอง',
      recipe: [ScentNote.jasmine, ScentNote.vanilla],
      price: 65,
      unlockDay: 8,
    ),
    ScentBlend(
      id: 'amber_night',
      name: 'แอมเบอร์ราตรี',
      recipe: [ScentNote.amber, ScentNote.whiteMusk],
      price: 75,
      unlockDay: 9,
    ),
    ScentBlend(
      id: 'cedar_peak',
      name: 'ซีดาร์ภูผา',
      recipe: [ScentNote.cedar, ScentNote.sandalwood],
      price: 70,
      unlockDay: 10,
    ),
    ScentBlend(
      id: 'white_tea',
      name: 'ชาขาวดอกไม้',
      recipe: [ScentNote.jasmine, ScentNote.rose, ScentNote.whiteMusk],
      price: 85,
      unlockDay: 11,
    ),
    // ---- สูตรลับ: ต้องทดลองผสมค้นพบเอง (มีคำใบ้ใน Scentorium) ----
    ScentBlend(
      id: 'moonlight',
      name: 'แสงจันทรา',
      recipe: [ScentNote.lavender, ScentNote.whiteMusk],
      price: 60,
      secret: true,
      hint: 'แสงจันทร์สีม่วงตกกระทบผ้าไหมสีขาว',
    ),
    ScentBlend(
      id: 'herb_breeze',
      name: 'ลมกลางสวน',
      recipe: [ScentNote.bergamot, ScentNote.lemongrass, ScentNote.whiteMusk],
      price: 75,
      secret: true,
      hint: 'ลมเย็นพัดผ่านสวนสมุนไพรยามบ่าย',
    ),
    ScentBlend(
      id: 'rainforest',
      name: 'พฤกษ์พนา',
      recipe: [ScentNote.cedar, ScentNote.lemongrass, ScentNote.whiteMusk],
      price: 90,
      secret: true,
      hint: 'กลิ่นป่าใหญ่หลังฝนแรกของปี',
    ),
    ScentBlend(
      id: 'eastern_caravan',
      name: 'คาราวานบูรพา',
      recipe: [ScentNote.amber, ScentNote.sandalwood, ScentNote.cedar],
      price: 110,
      secret: true,
      hint: 'ขบวนคาราวานข้ามทะเลทรายยามค่ำ',
    ),
    ScentBlend(
      id: 'flower_queen',
      name: 'ราชินีบุปผา',
      recipe: [ScentNote.jasmine, ScentNote.rose, ScentNote.vanilla],
      price: 100,
      secret: true,
      hint: 'ผู้สูงศักดิ์ที่สุดในสวนดอกไม้ทั้งปวง',
    ),
    ScentBlend(
      id: 'childhood_memory',
      name: 'ความทรงจำวัยเยาว์',
      recipe: [ScentNote.vanilla, ScentNote.whiteMusk],
      price: 65,
      secret: true,
      hint: 'อ้อมกอดอุ่นนุ่มหอมหวานในวันเก่า',
    ),
    ScentBlend(
      id: 'golden_midnight',
      name: 'เที่ยงคืนสีทอง',
      recipe: [ScentNote.amber, ScentNote.vanilla],
      price: 85,
      secret: true,
      hint: 'ทองคำละลายกลางความมืดหวานละมุน',
    ),
    ScentBlend(
      id: 'zen_garden',
      name: 'สวนเซน',
      recipe: [ScentNote.cedar, ScentNote.lavender, ScentNote.lemongrass],
      price: 95,
      secret: true,
      hint: 'นั่งสมาธิใต้ร่มไม้กลางสวนหินเงียบสงบ',
    ),
    ScentBlend(
      id: 'night_bloom',
      name: 'เกสรราตรี',
      recipe: [ScentNote.jasmine, ScentNote.lavender, ScentNote.whiteMusk],
      price: 90,
      secret: true,
      hint: 'ดอกไม้ขาวที่แย้มบานเฉพาะยามค่ำคืน',
    ),
    ScentBlend(
      id: 'dawn_fire',
      name: 'เพลิงรุ่งอรุณ',
      recipe: [ScentNote.amber, ScentNote.bergamot],
      price: 80,
      secret: true,
      hint: 'เปลวแดดแรกที่แตะขอบฟ้าสีส้ม',
    ),
    ScentBlend(
      id: 'four_realms',
      name: 'ตำนานสี่แผ่นดิน',
      recipe: [
        ScentNote.sandalwood,
        ScentNote.vanilla,
        ScentNote.amber,
        ScentNote.whiteMusk,
      ],
      price: 150,
      secret: true,
      hint: 'สูตรโบราณที่เดินทางผ่านสี่แผ่นดิน (สี่หยด)',
    ),
    ScentBlend(
      id: 'royal_perfume',
      name: 'สุคนธ์ราชสำนัก',
      recipe: [
        ScentNote.rose,
        ScentNote.jasmine,
        ScentNote.amber,
        ScentNote.whiteMusk,
      ],
      price: 160,
      secret: true,
      hint: 'กลิ่นหอมลับเฉพาะแห่งวังหลวง (สี่หยด)',
    ),
  ];

  static ScentBlend byId(String id) => all.firstWhere((b) => b.id == id);

  /// สูตรทั่วไปที่ปลดแล้วในวันนั้น (ไม่รวมสูตรลับ)
  static List<ScentBlend> forDay(int day) =>
      all.where((b) => !b.secret && b.unlockDay <= day).toList();

  /// หาสูตรที่ตรงกับส่วนผสม (null ถ้าไม่ตรงสูตรไหนเลย = กลิ่นประหลาด)
  static ScentBlend? matching(List<ScentNote> mixed) {
    for (final blend in all) {
      if (blend.matches(mixed)) return blend;
    }
    return null;
  }
}

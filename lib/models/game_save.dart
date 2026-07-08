import 'placed_decor.dart';
import 'scent_blend.dart';

/// สถานะเกมทั้งหมดที่ต้องเซฟ — เงินเป็นเหรียญ (int เสมอ)
class GameSave {
  GameSave({
    required this.coins,
    required this.day,
    required this.placed,
    List<String>? discovered,
    List<String>? notesOwned,
    this.questDate = '',
    this.questDay = 1,
    List<int>? questProgress,
    List<bool>? questClaimed,
    this.lastSeenMs = 0,
    this.tutorialSeen = false,
  }) : discovered = discovered ?? [],
       notesOwned = notesOwned ?? [for (final n in ScentNote.starters) n.name],
       questProgress = questProgress ?? [0, 0, 0],
       questClaimed = questClaimed ?? [false, false, false];

  /// เซฟใหม่สำหรับผู้เล่นเริ่มเกมครั้งแรก
  factory GameSave.fresh() => GameSave(coins: 120, day: 1, placed: []);

  factory GameSave.fromJson(Map<String, dynamic> json) => GameSave(
    coins: json['coins'] as int,
    day: json['day'] as int,
    placed: [
      for (final p in json['placed'] as List)
        PlacedDecor.fromJson(p as Map<String, dynamic>),
    ],
    // ฟิลด์ใหม่กว่าเซฟเก่า → ใช้ default (backward-compatible)
    discovered: (json['discovered'] as List?)?.cast<String>(),
    notesOwned: (json['notesOwned'] as List?)?.cast<String>(),
    questDate: (json['questDate'] as String?) ?? '',
    questDay: (json['questDay'] as int?) ?? 1,
    questProgress: (json['questProgress'] as List?)?.cast<int>(),
    questClaimed: (json['questClaimed'] as List?)?.cast<bool>(),
    lastSeenMs: (json['lastSeenMs'] as int?) ?? 0,
    tutorialSeen: (json['tutorialSeen'] as bool?) ?? false,
  );

  int coins;

  /// วันถัดไปที่จะเล่น (เริ่มที่ 1)
  int day;

  final List<PlacedDecor> placed;

  /// id ของสูตรลับที่ค้นพบแล้ว
  final List<String> discovered;

  /// ชื่อ ScentNote ที่ซื้อ/มีแล้ว
  final List<String> notesOwned;

  /// วันที่ (yyyy-MM-dd) ของชุดเควสรายวันปัจจุบัน — ไม่ตรงวันนี้ = ต้องรีเซ็ต
  String questDate;

  /// วันในเกม ณ ตอนสร้างชุดเควส — ตรึงเป้า/รางวัลไม่ให้ขยับระหว่างวันจริง
  int questDay;

  /// ความคืบหน้าเควส 3 ข้อของวันนี้
  List<int> questProgress;

  /// รับรางวัลเควสข้อนั้นแล้วหรือยัง
  List<bool> questClaimed;

  /// เวลาเซฟล่าสุด (epoch ms) — ใช้คำนวณรายได้ออฟไลน์
  int lastSeenMs;

  /// ผ่านหน้าสอนเล่นครั้งแรกแล้ว
  bool tutorialSeen;

  /// โน้ตที่ใช้ได้จริง (แปลงจากชื่อ ข้ามชื่อที่ไม่รู้จัก)
  Set<ScentNote> get ownedNotes => {
    for (final name in notesOwned)
      for (final n in ScentNote.values)
        if (n.name == name) n,
  };

  /// ค่าบรรยากาศ ⭐ รวมจากของตกแต่งทุกชิ้นที่วางอยู่
  int get ambiance => placed.fold(0, (sum, p) => sum + p.item.ambiance);

  Map<String, dynamic> toJson() => {
    'coins': coins,
    'day': day,
    'placed': [for (final p in placed) p.toJson()],
    'discovered': discovered,
    'notesOwned': notesOwned,
    'questDate': questDate,
    'questDay': questDay,
    'questProgress': questProgress,
    'questClaimed': questClaimed,
    'lastSeenMs': lastSeenMs,
    'tutorialSeen': tutorialSeen,
  };
}

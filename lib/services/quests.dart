import 'dart:math';

import '../game/shop_game.dart';
import '../models/game_save.dart';

/// ชนิดเควสรายวัน — แต่ละชนิดนับจากผลรวมของทุกวันทำงานในวันจริงนั้น
enum QuestType { perfectServes, earnCoins, sellProducts, serveSecrets }

class DailyQuest {
  const DailyQuest({
    required this.type,
    required this.target,
    required this.reward,
  });

  final QuestType type;
  final int target;

  /// รางวัลเหรียญเมื่อครบเป้า
  final int reward;

  String get label => switch (type) {
    QuestType.perfectServes => 'เสิร์ฟออเดอร์เพอร์เฟกต์ $target ครั้ง',
    QuestType.earnCoins => 'ทำยอดขายรวม $target 🪙',
    QuestType.sellProducts => 'ขายสินค้าสำเร็จ $target ชิ้น',
    QuestType.serveSecrets => 'เสิร์ฟกลิ่นสูตรลับ $target ครั้ง',
  };

  String get emoji => switch (type) {
    QuestType.perfectServes => '✨',
    QuestType.earnCoins => '🪙',
    QuestType.sellProducts => '🕯️',
    QuestType.serveSecrets => '🏺',
  };
}

abstract final class Quests {
  static String dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// เควส 3 ข้อของวันนั้น — deterministic จากวันที่ (ไม่ต้องเก็บตัวเควสในเซฟ)
  /// เป้า/รางวัลสเกลตามความคืบหน้าเกม [gameDay]
  static List<DailyQuest> generateDaily(DateTime date, int gameDay) {
    final rng = Random(dateKey(date).hashCode);
    final types = List.of(QuestType.values)..shuffle(rng);
    final scale = 1 + (gameDay - 1) * 0.15;
    return [
      for (final type in types.take(3))
        switch (type) {
          QuestType.perfectServes => DailyQuest(
            type: type,
            target: (3 + rng.nextInt(3) * scale).round(),
            reward: 60 + gameDay * 10,
          ),
          QuestType.earnCoins => DailyQuest(
            type: type,
            target: ((150 + rng.nextInt(3) * 50) * scale).round(),
            reward: 80 + gameDay * 10,
          ),
          QuestType.sellProducts => DailyQuest(
            type: type,
            target: (2 + rng.nextInt(2) * scale).round(),
            reward: 70 + gameDay * 10,
          ),
          QuestType.serveSecrets => DailyQuest(
            type: type,
            target: (1 + rng.nextInt(2) * scale).round(),
            reward: 90 + gameDay * 10,
          ),
        },
    ];
  }

  /// รีเซ็ตชุดเควสถ้าข้ามวันจริงแล้ว — ตรึงระดับเป้าไว้ที่วันในเกมตอนนั้น
  static void ensureFresh(GameSave save, DateTime now) {
    final key = dateKey(now);
    if (save.questDate == key) return;
    save.questDate = key;
    save.questDay = save.day;
    save.questProgress = [0, 0, 0];
    save.questClaimed = [false, false, false];
  }

  /// ชุดเควสปัจจุบันของเซฟนี้ (เป้าตรึงตาม questDay)
  static List<DailyQuest> current(GameSave save, DateTime now) {
    ensureFresh(save, now);
    return generateDaily(now, save.questDay);
  }

  /// สะสมผลจากหนึ่งวันทำงานเข้าเควสของวันนี้
  static void applyDayResult(GameSave save, DateTime now, DayResult result) {
    final quests = current(save, now);
    for (var i = 0; i < quests.length; i++) {
      save.questProgress[i] += switch (quests[i].type) {
        QuestType.perfectServes => result.perfect,
        QuestType.earnCoins => result.earned,
        QuestType.sellProducts => result.productsSold,
        QuestType.serveSecrets => result.secretServes,
      };
    }
  }
}

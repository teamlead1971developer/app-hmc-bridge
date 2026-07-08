import 'dart:math';

import '../models/customer_order.dart';
import '../models/game_save.dart';
import '../models/product.dart';
import '../models/scent_blend.dart';

/// ค่าคงที่และสูตรสมดุลเกมทั้งหมด — จูนความยาก/เศรษฐกิจที่ไฟล์นี้ไฟล์เดียว
abstract final class Balance {
  /// ความยาวหนึ่งวันทำงาน (วินาที)
  static const dayLengthSeconds = 120.0;

  /// จำนวนแผงโชว์น้ำหอมตัวอย่างในหน้าร้าน
  static const standCount = 4;

  /// ถาดถือของได้สูงสุดกี่ชิ้น
  static const traySize = 2;

  /// ระยะห่างเฉลี่ยระหว่างลูกค้าเข้าร้าน — วันหลังๆ ถี่ขึ้นเรื่อยๆ
  /// (ฐานยาวขึ้นจากเดิมเพราะต้องเดินไป-กลับหลังร้าน)
  static double spawnInterval(int day) =>
      (17.0 - (day - 1) * 1.0).clamp(9.0, 17.0);

  /// ความอดทนพื้นฐานลดลงตามวัน แต่ถูกชดเชยด้วยค่าบรรยากาศของร้าน
  static double patienceSeconds(int day, int ambiance) {
    final base = (44.0 - (day - 1) * 1.0).clamp(30.0, 44.0);
    return base * patienceMultiplier(ambiance);
  }

  /// ทุก ⭐ บรรยากาศ = ลูกค้าอดทนขึ้น 1%
  static double patienceMultiplier(int ambiance) => 1 + ambiance * 0.01;

  /// ทุก ⭐ บรรยากาศ = ทิปแพงขึ้น 2%
  static double tipMultiplier(int ambiance) => 1 + ambiance * 0.02;

  /// ทิปสูงสุดคือครึ่งราคาออเดอร์ สเกลตามความเร็ว (สัดส่วนความอดทนที่เหลือ)
  static int tip(int price, double patienceLeftRatio, int ambiance) =>
      (price * 0.5 * patienceLeftRatio.clamp(0, 1) * tipMultiplier(ambiance))
          .round();

  /// เสิร์ฟของผิด: ได้ครึ่งราคาของชิ้นนั้น ไม่มีทิป
  static int wrongItemPay(int price) => price ~/ 2;

  /// โบนัสทันทีตอนค้นพบสูตรลับใหม่
  static int discoveryBonus(ScentBlend blend) => blend.price * 3;

  /// รายได้ออฟไลน์ต่อชั่วโมง — โตตามบรรยากาศร้านและจำนวนสูตรลับที่ค้นพบ
  static int offlineRatePerHour(GameSave save) =>
      10 + save.ambiance * 2 + save.discovered.length * 6;

  /// สะสมรายได้ออฟไลน์ได้สูงสุดกี่ชั่วโมง
  static const offlineCapHours = 8.0;

  /// เหรียญที่ร้านขายเองระหว่างผู้เล่นไม่อยู่ (จาก lastSeenMs ถึง [nowMs])
  static int offlineEarnings(GameSave save, int nowMs) {
    if (save.lastSeenMs <= 0 || nowMs <= save.lastSeenMs) return 0;
    final hours =
        ((nowMs - save.lastSeenMs) / Duration.millisecondsPerHour)
            .clamp(0.0, offlineCapHours);
    return (hours * offlineRatePerHour(save)).floor();
  }

  /// กลิ่นที่ลูกค้าสั่งได้ตอนนี้: สูตรทั่วไปที่ปลดตามวัน + สูตรลับที่ค้นพบแล้ว
  /// และต้องผสมได้ด้วยโน้ตที่ผู้เล่นมี
  static List<ScentBlend> orderPool(int day, GameSave save) {
    final owned = save.ownedNotes;
    return BlendCatalog.all
        .where(
          (b) =>
              (b.secret ? save.discovered.contains(b.id) : b.unlockDay <= day) &&
              b.craftableWith(owned),
        )
        .toList();
  }

  /// สุ่มออเดอร์ตามความยากของวัน
  /// วัน 1-2: น้ำหอมผสมล้วน • วัน 3-4: มีสั่งสินค้าสำเร็จปน • วัน 5+: มีสั่งคู่
  static CustomerOrder randomOrder(int day, GameSave save, Random rng) {
    final blends = orderPool(day, save);
    final products = ProductCatalog.forDay(day);
    final patience = patienceSeconds(day, save.ambiance);

    ScentBlend pickBlend() => blends[rng.nextInt(blends.length)];
    Product pickProduct() => products[rng.nextInt(products.length)];

    if (products.isEmpty) {
      return CustomerOrder(blend: pickBlend(), patienceSeconds: patience);
    }
    final roll = rng.nextDouble();
    if (day >= 5) {
      // 35% สั่งคู่ • 25% สินค้าสำเร็จเดี่ยว • ที่เหลือน้ำหอมผสมเดี่ยว
      if (roll < 0.35) {
        return CustomerOrder(
          blend: pickBlend(),
          product: pickProduct(),
          patienceSeconds: patience,
        );
      }
      if (roll < 0.60) {
        return CustomerOrder(product: pickProduct(), patienceSeconds: patience);
      }
      return CustomerOrder(blend: pickBlend(), patienceSeconds: patience);
    }
    // วัน 3-4: 30% สินค้าสำเร็จเดี่ยว ที่เหลือน้ำหอมผสมเดี่ยว
    if (roll < 0.30) {
      return CustomerOrder(product: pickProduct(), patienceSeconds: patience);
    }
    return CustomerOrder(blend: pickBlend(), patienceSeconds: patience);
  }
}

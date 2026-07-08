import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:app_hmc_bridge/game/room_layout.dart';
import 'package:app_hmc_bridge/models/decor_item.dart';
import 'package:app_hmc_bridge/models/game_save.dart';
import 'package:app_hmc_bridge/models/placed_decor.dart';
import 'package:app_hmc_bridge/models/product.dart';
import 'package:app_hmc_bridge/models/scent_blend.dart';
import 'package:app_hmc_bridge/game/shop_game.dart';
import 'package:app_hmc_bridge/services/balance.dart';
import 'package:app_hmc_bridge/services/quests.dart';

void main() {
  group('GameSave', () {
    test('รอด JSON round-trip ครบทุกฟิลด์', () {
      final save = GameSave(
        coins: 345,
        day: 7,
        placed: [
          const PlacedDecor(itemId: 'plant', slot: 2),
          const PlacedDecor(itemId: 'wallpaper_sage', slot: 0),
        ],
      );
      final restored = GameSave.fromJson(
        jsonDecode(jsonEncode(save.toJson())) as Map<String, dynamic>,
      );
      expect(restored.coins, 345);
      expect(restored.day, 7);
      expect(restored.placed.length, 2);
      expect(restored.placed[0].itemId, 'plant');
      expect(restored.placed[1].slot, 0);
    });

    test('ambiance รวมจากของที่วางทุกชิ้น', () {
      final save = GameSave(
        coins: 0,
        day: 1,
        placed: [
          const PlacedDecor(itemId: 'plant', slot: 0), // ⭐3
          const PlacedDecor(itemId: 'bookshelf', slot: 2), // ⭐6
        ],
      );
      expect(save.ambiance, 9);
    });

    test('เซฟใหม่เริ่มต้นถูกต้อง', () {
      final fresh = GameSave.fresh();
      expect(fresh.coins, 120);
      expect(fresh.day, 1);
      expect(fresh.placed, isEmpty);
      expect(fresh.ambiance, 0);
      expect(fresh.discovered, isEmpty);
      expect(fresh.ownedNotes, ScentNote.starters.toSet());
    });

    test('เซฟเก่า (ไม่มีฟิลด์ discovery) โหลดได้ด้วย default', () {
      final restored = GameSave.fromJson(
        jsonDecode('{"coins":50,"day":3,"placed":[]}')
            as Map<String, dynamic>,
      );
      expect(restored.coins, 50);
      expect(restored.discovered, isEmpty);
      expect(restored.ownedNotes.length, 6);
    });

    test('ฟิลด์เควส/ออฟไลน์/tutorial รอด round-trip + เซฟเก่า default', () {
      final save = GameSave.fresh()
        ..questDate = '2026-07-08'
        ..questProgress = [1, 200, 0]
        ..questClaimed = [true, false, false]
        ..lastSeenMs = 12345
        ..tutorialSeen = true;
      final restored = GameSave.fromJson(
        jsonDecode(jsonEncode(save.toJson())) as Map<String, dynamic>,
      );
      expect(restored.questDate, '2026-07-08');
      expect(restored.questProgress, [1, 200, 0]);
      expect(restored.questClaimed, [true, false, false]);
      expect(restored.lastSeenMs, 12345);
      expect(restored.tutorialSeen, isTrue);

      final old = GameSave.fromJson(
        jsonDecode('{"coins":50,"day":3,"placed":[]}') as Map<String, dynamic>,
      );
      expect(old.questDate, '');
      expect(old.questProgress, [0, 0, 0]);
      expect(old.tutorialSeen, isFalse);
    });

    test('discovered/notesOwned รอด round-trip', () {
      final save = GameSave.fresh()
        ..discovered.add('moonlight')
        ..notesOwned.add(ScentNote.amber.name);
      final restored = GameSave.fromJson(
        jsonDecode(jsonEncode(save.toJson())) as Map<String, dynamic>,
      );
      expect(restored.discovered, ['moonlight']);
      expect(restored.ownedNotes.contains(ScentNote.amber), isTrue);
    });
  });

  group('DecorCatalog', () {
    test('id ไม่ซ้ำกัน และ byId หาเจอทุกชิ้น', () {
      final ids = DecorCatalog.all.map((d) => d.id).toSet();
      expect(ids.length, DecorCatalog.all.length);
      for (final item in DecorCatalog.all) {
        expect(DecorCatalog.byId(item.id).name, item.name);
      }
    });

    test('ทุกชิ้นวางลงชั้นของตัวเองได้จริง (cells ไม่เกิน slotCount)', () {
      for (final item in DecorCatalog.all) {
        expect(item.cells, lessThanOrEqualTo(item.layer.slotCount),
            reason: item.id);
      }
    });
  });

  group('BlendCatalog', () {
    test('สูตรปลดล็อกเพิ่มตามวัน (ไม่รวมสูตรลับ)', () {
      expect(BlendCatalog.forDay(1).length, 2);
      expect(
        BlendCatalog.forDay(5).length,
        greaterThan(BlendCatalog.forDay(1).length),
      );
      final commons = BlendCatalog.all.where((b) => !b.secret).length;
      expect(BlendCatalog.forDay(99).length, commons);
      // มีสูตรลับให้ค้นพบจริง
      expect(BlendCatalog.all.length - commons, greaterThanOrEqualTo(10));
    });

    test('multiset ของทุกสูตรไม่ซ้ำกัน (เทียบแบบไม่สนลำดับได้)', () {
      final signatures = BlendCatalog.all
          .map(
            (b) => (List.of(b.recipe)..sort((a, c) => a.index - c.index))
                .map((n) => n.name)
                .join('|'),
          )
          .toSet();
      expect(signatures.length, BlendCatalog.all.length);
    });

    test('matching หาสูตรถูกตัว (ทั่วไปก่อนสูตรลับ ตามลำดับแคตตาล็อก)', () {
      expect(
        BlendCatalog.matching([ScentNote.rose, ScentNote.whiteMusk])!.id,
        'rose_garden',
      );
      expect(
        BlendCatalog.matching([ScentNote.lavender, ScentNote.whiteMusk])!.id,
        'moonlight',
      );
      expect(
        BlendCatalog.matching([ScentNote.cedar, ScentNote.cedar]),
        isNull, // กลิ่นประหลาด
      );
    });

    test('เทียบสูตรไม่สนลำดับ แต่จำนวนต้องตรง', () {
      final rose = BlendCatalog.all.firstWhere((b) => b.id == 'rose_garden');
      expect(rose.matches([ScentNote.whiteMusk, ScentNote.rose]), isTrue);
      expect(rose.matches([ScentNote.rose, ScentNote.whiteMusk]), isTrue);
      expect(rose.matches([ScentNote.rose]), isFalse);
      expect(
        rose.matches([ScentNote.rose, ScentNote.rose, ScentNote.whiteMusk]),
        isFalse,
      );
      expect(rose.matches([ScentNote.rose, ScentNote.vanilla]), isFalse);
    });
  });

  group('Quests', () {
    test('วันเดียวกันได้ชุดเดิม คนละวันได้ชุดใหม่ ไม่ซ้ำชนิด', () {
      final d1 = DateTime(2026, 7, 8);
      final a = Quests.generateDaily(d1, 3);
      final b = Quests.generateDaily(d1, 3);
      for (var i = 0; i < 3; i++) {
        expect(a[i].type, b[i].type);
        expect(a[i].target, b[i].target);
      }
      expect(a.map((q) => q.type).toSet().length, 3);

      final c = Quests.generateDaily(DateTime(2026, 7, 9), 3);
      final sameTypes =
          List.generate(3, (i) => a[i].type == c[i].type).every((x) => x);
      final sameTargets =
          List.generate(3, (i) => a[i].target == c[i].target).every((x) => x);
      expect(sameTypes && sameTargets, isFalse);
    });

    test('ensureFresh รีเซ็ตเมื่อข้ามวัน + applyDayResult สะสมถูกช่อง', () {
      final save = GameSave.fresh();
      final now = DateTime(2026, 7, 8);
      Quests.ensureFresh(save, now);
      expect(save.questDate, '2026-07-08');

      final quests = Quests.generateDaily(now, save.day);
      Quests.applyDayResult(
        save,
        now,
        const DayResult(
          earned: 100,
          tips: 10,
          served: 4,
          lost: 0,
          perfect: 3,
          productsSold: 2,
          secretServes: 1,
        ),
      );
      for (var i = 0; i < 3; i++) {
        final expected = switch (quests[i].type) {
          QuestType.perfectServes => 3,
          QuestType.earnCoins => 100,
          QuestType.sellProducts => 2,
          QuestType.serveSecrets => 1,
        };
        expect(save.questProgress[i], expected);
      }

      // ข้ามวัน → รีเซ็ต
      Quests.ensureFresh(save, DateTime(2026, 7, 9));
      expect(save.questProgress, [0, 0, 0]);
      expect(save.questClaimed, [false, false, false]);
    });
  });

  group('รายได้ออฟไลน์', () {
    test('คิดตามชั่วโมง + เพดาน 8 ชม. + ไม่ติดลบ', () {
      final save = GameSave.fresh();
      final rate = Balance.offlineRatePerHour(save);
      final base = DateTime(2026, 7, 8).millisecondsSinceEpoch;
      save.lastSeenMs = base;

      expect(
        Balance.offlineEarnings(save, base + Duration.millisecondsPerHour * 2),
        rate * 2,
      );
      expect(
        Balance.offlineEarnings(save, base + Duration.millisecondsPerHour * 50),
        rate * 8, // เพดาน
      );
      expect(Balance.offlineEarnings(save, base - 1000), 0);
      save.lastSeenMs = 0;
      expect(Balance.offlineEarnings(save, base), 0);
    });

    test('อัตราโตตามสูตรลับที่ค้นพบ', () {
      final save = GameSave.fresh();
      final before = Balance.offlineRatePerHour(save);
      save.discovered.add('moonlight');
      expect(Balance.offlineRatePerHour(save), greaterThan(before));
    });
  });

  group('ProductCatalog', () {
    test('id ไม่ซ้ำ และปลดล็อกตามวัน', () {
      final ids = ProductCatalog.all.map((p) => p.id).toSet();
      expect(ids.length, ProductCatalog.all.length);
      expect(ProductCatalog.forDay(1), isEmpty);
      expect(ProductCatalog.forDay(3), isNotEmpty);
      expect(ProductCatalog.forDay(99).length, ProductCatalog.all.length);
    });
  });

  group('Balance', () {
    test('บรรยากาศสูง → ลูกค้าอดทนขึ้นและทิปแพงขึ้น', () {
      expect(
        Balance.patienceSeconds(1, 20),
        greaterThan(Balance.patienceSeconds(1, 0)),
      );
      expect(Balance.tip(60, 1.0, 20), greaterThan(Balance.tip(60, 1.0, 0)));
    });

    test('วันหลังๆ ลูกค้ามาถี่ขึ้นแต่ไม่ต่ำกว่าขั้นต่ำ', () {
      expect(Balance.spawnInterval(5), lessThan(Balance.spawnInterval(1)));
      expect(Balance.spawnInterval(100), 9.0);
    });

    test('เสิร์ฟช้าทิปน้อยกว่าเสิร์ฟไว', () {
      expect(Balance.tip(60, 0.2, 0), lessThan(Balance.tip(60, 0.9, 0)));
    });

    test('เสิร์ฟผิดได้ครึ่งราคา', () {
      expect(Balance.wrongItemPay(61), 30);
    });

    test('วัน 1-2 ออเดอร์มีแต่น้ำหอมผสม', () {
      final rng = Random(42);
      final save = GameSave.fresh();
      for (var i = 0; i < 50; i++) {
        final order = Balance.randomOrder(1, save, rng);
        expect(order.blend, isNotNull);
        expect(order.product, isNull);
      }
    });

    test('order pool: ไม่มีสูตรลับก่อนค้นพบ / โผล่หลังค้นพบ', () {
      final save = GameSave.fresh();
      final pool = Balance.orderPool(99, save);
      expect(pool.any((b) => b.secret), isFalse);

      save.discovered.add('moonlight');
      final poolAfter = Balance.orderPool(99, save);
      expect(poolAfter.any((b) => b.id == 'moonlight'), isTrue);
    });

    test('order pool: ไม่มีสูตรที่ใช้โน้ตที่ยังไม่ซื้อ', () {
      final save = GameSave.fresh(); // มีแค่ 6 โน้ตแรก
      final pool = Balance.orderPool(99, save);
      // มะลิยามเช้า (ใช้มะลิ) ต้องไม่อยู่ แม้ปลดตามวันแล้ว
      expect(pool.any((b) => b.id == 'morning_jasmine'), isFalse);

      save.notesOwned.add(ScentNote.jasmine.name);
      expect(
        Balance.orderPool(99, save).any((b) => b.id == 'morning_jasmine'),
        isTrue,
      );
    });

    test('โบนัสค้นพบ = 3 เท่าราคากลิ่น', () {
      final blend = BlendCatalog.byId('royal_perfume');
      expect(Balance.discoveryBonus(blend), blend.price * 3);
    });

    test('โลกสองห้อง: สถานีอยู่หลังร้าน (ซ้าย) ลูกค้าอยู่หน้าร้าน (ขวา)', () {
      const room = RoomLayout(Size(440, 812));
      expect(room.worldW, 880);
      // สถานีทำงานทั้งหมดอยู่ครึ่งซ้าย
      expect(room.blendBarRect.right, lessThan(room.frontX));
      expect(room.shelfRect.right, lessThan(room.frontX));
      expect(room.binRect.right, lessThan(room.frontX));
      // ประตูถนน + แผงโชว์ + ช่อง decor ทุกชั้น อยู่ครึ่งขวา
      expect(room.doorRect.left, greaterThan(room.frontX));
      for (var i = 0; i < Balance.standCount; i++) {
        expect(room.standRect(i).left, greaterThan(room.frontX));
        expect(
          room.walkableRect.contains(
            Offset(room.serveStand(i).dx, room.serveStand(i).dy),
          ),
          isTrue,
        );
      }
      for (final layer in DecorLayer.values) {
        expect(room.slotRect(layer, 0, 1).left,
            greaterThanOrEqualTo(room.frontX));
      }
      // จุดยืนสถานีหลังร้านอยู่ในเขตเดิน
      for (final p in [room.blendBarStand, room.shelfStand, room.binStand]) {
        expect(room.walkableRect.contains(Offset(p.dx, p.dy)), isTrue);
      }
    });

    test('วัน 5+ มีทั้งน้ำหอมเดี่ยว สินค้าเดี่ยว และสั่งคู่', () {
      final rng = Random(42);
      final save = GameSave.fresh();
      var blendOnly = 0;
      var productOnly = 0;
      var both = 0;
      for (var i = 0; i < 300; i++) {
        final order = Balance.randomOrder(6, save, rng);
        expect(order.itemCount, greaterThan(0));
        if (order.blend != null && order.product != null) {
          both++;
        } else if (order.product != null) {
          productOnly++;
        } else {
          blendOnly++;
        }
      }
      expect(blendOnly, greaterThan(0));
      expect(productOnly, greaterThan(0));
      expect(both, greaterThan(0));
    });
  });
}

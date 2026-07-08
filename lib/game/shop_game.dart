import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../models/game_save.dart';
import '../models/product.dart';
import '../models/scent_blend.dart';
import '../services/balance.dart';
import '../services/save_service.dart';
import '../theme/palette.dart';
import 'components/customer.dart';
import 'components/display_stand.dart';
import 'components/floating_text.dart';
import 'components/particles.dart';
import 'components/player.dart';
import 'components/shop_room.dart';
import 'pixel/sprites.dart';
import 'room_layout.dart';

/// แผงสถานีที่เปิดอยู่ (โชว์เป็น Flutter panel ทับเกม)
enum StationPanel { blend, product }

/// ของหนึ่งชิ้นบนถาดของผู้เล่น
sealed class TrayItem {
  const TrayItem();
}

class TrayBlend extends TrayItem {
  const TrayBlend(this.mixed);

  /// กลิ่นที่ผสมไว้ — เทียบกับสูตรตอนเสิร์ฟที่แผงโชว์
  final List<ScentNote> mixed;
}

class TrayProduct extends TrayItem {
  const TrayProduct(this.product);

  final Product product;
}

/// สรุปผลหนึ่งวันทำงาน ส่งต่อให้หน้าสรุป/ระบบเควส
class DayResult {
  const DayResult({
    required this.earned,
    required this.tips,
    required this.served,
    required this.lost,
    required this.perfect,
    required this.productsSold,
    required this.secretServes,
  });

  final int earned;
  final int tips;
  final int served;
  final int lost;

  /// ออเดอร์ที่จบแบบไม่มีของผิดเลย
  final int perfect;

  /// จำนวนสินค้าสำเร็จที่ขายได้ (ชิ้น)
  final int productsSold;

  /// จำนวนครั้งที่เสิร์ฟน้ำหอมสูตรลับถูกต้อง
  final int secretServes;
}

/// เกมช่วงเปิดร้านหนึ่งวัน (v4 — โลกสองห้อง):
/// หน้าร้านรับลูกค้าที่แผงโชว์ / หลังร้านปรุงน้ำหอม+หยิบสินค้า
/// กล้องแพนตามผู้เล่นแบบนุ่มนวลระหว่างสองห้อง
class ShopGame extends FlameGame with TapCallbacks {
  ShopGame({required this.save, required this.onDayEnd});

  final GameSave save;
  final void Function(DayResult result) onDayEnd;

  final earnedToday = ValueNotifier<int>(0);
  final timeLeft = ValueNotifier<double>(Balance.dayLengthSeconds);

  /// ของที่ถืออยู่ (สูงสุด [Balance.traySize] ชิ้น)
  final tray = ValueNotifier<List<TrayItem>>(const []);

  /// แผงสถานีที่ควรโชว์ตอนนี้ — ShiftScreen ฟังค่านี้
  final activePanel = ValueNotifier<StationPanel?>(null);

  /// จำนวนลูกค้าที่ยืนรอสั่ง/รอของอยู่หน้าร้าน — HUD ใช้โชว์กระดิ่ง 🔔
  final waitingCount = ValueNotifier<int>(0);

  /// สูตรลับที่เพิ่งค้นพบ — ShiftScreen ฟังไว้โชว์แบนเนอร์ฉลอง
  final discovery = ValueNotifier<ScentBlend?>(null);

  /// รากของโลกทั้งใบ — เลื่อน x เพื่อทำหน้าที่กล้อง (ทุก component อยู่ใต้ตัวนี้)
  late final PositionComponent worldRoot;
  late final PlayerComponent player;
  final stands = <DisplayStand>[];

  int _tips = 0;
  int _served = 0;
  int _lost = 0;
  int _perfect = 0;
  int _productsSold = 0;
  int _secretServes = 0;
  bool _dayOver = false;

  final _rng = math.Random();
  double _spawnTimer = 2.0;
  double _camX = 0;

  RoomLayout get room => RoomLayout(size.toSize());

  bool get trayFull => tray.value.length >= Balance.traySize;

  @override
  Color backgroundColor() => Palette.cream;

  @override
  Future<void> onLoad() async {
    await PixelSprites.ensureLoaded();
    worldRoot = PositionComponent();
    add(worldRoot);

    worldRoot.add(ShopRoom());
    for (var i = 0; i < Balance.standCount; i++) {
      final stand = DisplayStand(i);
      stands.add(stand);
      worldRoot.add(stand);
    }
    final spawn = room.frontRoomCenter;
    player = PlayerComponent(spawn: Vector2(spawn.dx, spawn.dy));
    worldRoot.add(player);
    // เริ่มเกมโดยกล้องอยู่หน้าร้านพอดี
    _camX = _cameraTarget();
    worldRoot.position.x = -_camX;

    // ละอองหอมลอยจากโต๊ะปรุงหลังร้านตลอดเวลา
    worldRoot.add(
      MistEmitter(
        at: () {
          final r = room.blendBarRect;
          return Vector2(r.center.dx, r.top - room.h * 0.02);
        },
      ),
    );
  }

  /// กล้องล็อกเป็นรายห้อง: นิ่งสนิทระหว่างทำงานในห้อง (เล็งเสิร์ฟง่าย)
  /// แล้วแพนนุ่มๆ เต็มจอเฉพาะตอนผู้เล่นเดินข้ามซุ้มกลาง
  double _cameraTarget() =>
      player.position.x < room.frontX ? 0.0 : room.worldW - size.x;

  @override
  void update(double dt) {
    super.update(dt);

    // กล้องไล่ตามผู้เล่นแบบ lerp นุ่มๆ เฉพาะแกน x
    _camX += (_cameraTarget() - _camX) * math.min(1.0, dt * 5);
    worldRoot.position.x = -_camX;

    if (_dayOver) return;

    // นับลูกค้าที่ยืนรออยู่ (แจ้งเตือนกระดิ่งบน HUD)
    var waiting = 0;
    for (final stand in stands) {
      final c = stand.occupant;
      if (c != null && c.state == CustomerState.seated) waiting++;
    }
    waitingCount.value = waiting;

    timeLeft.value = math.max(0, timeLeft.value - dt);
    if (timeLeft.value <= 0) {
      _endDay();
      return;
    }

    _spawnTimer -= dt;
    if (_spawnTimer <= 0) {
      _spawnTimer =
          Balance.spawnInterval(save.day) * (0.7 + _rng.nextDouble() * 0.6);
      _spawnCustomer();
    }
  }

  void _spawnCustomer() {
    final freeStands = stands.where((s) => s.isFree).toList();
    if (freeStands.isEmpty) return; // แผงเต็ม ลูกค้าไม่เข้า

    final stand = freeStands[_rng.nextInt(freeStands.length)];
    final customer = CustomerComponent(
      order: Balance.randomOrder(save.day, save, _rng),
      color: Palette
          .customerColors[_rng.nextInt(Palette.customerColors.length)],
      standIndex: stand.index,
      spawn: Vector2(room.doorSpawn.dx, room.doorSpawn.dy),
    );
    stand.occupant = customer;
    worldRoot.add(customer);
  }

  /// เดินกลับไปกลางหน้าร้าน (ปุ่มกระดิ่งบน HUD เรียก)
  void goToFrontRoom() {
    if (_dayOver) return;
    activePanel.value = null;
    player.walkTo(room.frontRoomCenter);
  }

  // ---- tap routing ----

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    if (_dayOver) return;

    // ทุกการแตะ = เริ่มเดินใหม่ → ปิดแผงที่เปิดอยู่ก่อนเสมอ
    activePanel.value = null;

    // แปลงพิกัดจอ → พิกัดโลก (ชดเชยตำแหน่งกล้อง)
    final pos = event.canvasPosition.toOffset() + Offset(_camX, 0);
    final r = room;

    // แตะโซนซุ้มประตูกลาง = เดินทะลุไปอีกห้อง (กล้องล็อกห้องทำให้
    // แตะพื้นข้ามฝั่งเองไม่ได้ ต้องมีทางลัดผ่านซุ้ม)
    final archZone = Rect.fromLTWH(
      r.frontX - r.w * 0.09,
      r.floorTop - r.h * 0.30,
      r.w * 0.18,
      r.h,
    );
    if (archZone.contains(pos)) {
      final goingToBack = player.position.x >= r.frontX;
      final targetX = goingToBack
          ? r.frontX - r.w * 0.32
          : r.frontX + r.w * 0.32;
      player.walkTo(r.clampToWalkable(Offset(targetX, r.floorY(0.42))));
      return;
    }

    if (r.blendBarRect.inflate(r.h * 0.02).contains(pos)) {
      player.walkTo(
        r.blendBarStand,
        onArrive: () => activePanel.value = StationPanel.blend,
      );
      return;
    }
    if (r.shelfRect.inflate(r.h * 0.02).contains(pos)) {
      player.walkTo(
        r.shelfStand,
        onArrive: () => activePanel.value = StationPanel.product,
      );
      return;
    }
    if (r.binRect.inflate(r.h * 0.02).contains(pos)) {
      player.walkTo(r.binStand, onArrive: _emptyTray);
      return;
    }
    for (var i = 0; i < stands.length; i++) {
      if (r.standRect(i).contains(pos)) {
        final index = i;
        player.walkTo(r.serveStand(i), onArrive: () => _serveStand(index));
        return;
      }
    }
    player.walkTo(r.clampToWalkable(pos));
  }

  // ---- ถาด ----

  /// เพิ่มน้ำหอมที่ผสมเสร็จลงถาด — false ถ้าถาดเต็ม
  /// ถ้าส่วนผสมตรงสูตรลับที่ยังไม่พบ = "ค้นพบกลิ่นใหม่!" (โบนัส + ฉลอง)
  bool addBlendToTray(List<ScentNote> mixed) {
    if (trayFull) return false;
    tray.value = [...tray.value, TrayBlend(List.of(mixed))];
    // ละอองหอมพุ่งจากขวดตอนใส่ถาด
    for (var i = 0; i < 4; i++) {
      worldRoot.add(
        MistPuff(
          position: player.position - Vector2(0, room.h * 0.16),
          color: mixed.isEmpty ? Palette.lavender : mixed.last.color,
        ),
      );
    }
    _checkDiscovery(mixed);
    return true;
  }

  void _checkDiscovery(List<ScentNote> mixed) {
    final blend = BlendCatalog.matching(mixed);
    if (blend == null || !blend.secret || save.discovered.contains(blend.id)) {
      return;
    }
    save.discovered.add(blend.id);
    // บันทึกทันที การค้นพบต้องไม่หายแม้ออกกลางวัน
    SaveService().save(save);

    final bonus = Balance.discoveryBonus(blend);
    earnedToday.value += bonus;
    _floatText('โบนัสค้นพบ +$bonus', player.position, Palette.gold);

    // ฉลองใหญ่: ประกายหลากสีพุ่งรอบตัว + ละอองหอมฟุ้ง
    final at = player.position - Vector2(0, room.h * 0.12);
    for (var i = 0; i < 18; i++) {
      worldRoot.add(
        Sparkle(
          position: at.clone(),
          color: blend.recipe[i % blend.recipe.length].color,
        ),
      );
    }
    for (var i = 0; i < 6; i++) {
      worldRoot.add(
        MistPuff(position: at.clone(), color: blend.recipe.first.color),
      );
    }

    // แจ้ง ShiftScreen โชว์แบนเนอร์ แล้วเคลียร์เอง
    discovery.value = blend;
    Future<void>.delayed(const Duration(milliseconds: 3000), () {
      if (discovery.value == blend) discovery.value = null;
    });
  }

  /// หยิบสินค้าสำเร็จจากชั้นลงถาด — false ถ้าถาดเต็ม
  bool addProductToTray(Product product) {
    if (trayFull) return false;
    tray.value = [...tray.value, TrayProduct(product)];
    return true;
  }

  void _emptyTray() {
    if (tray.value.isEmpty) return;
    tray.value = const [];
    _floatText('เทถาดแล้ว', player.position, Palette.mocha);
  }

  // ---- เสิร์ฟ ----

  void _serveStand(int index) {
    final customer = stands[index].occupant;
    if (customer == null || customer.state != CustomerState.seated) {
      _floatText('แผงนี้ยังไม่มีลูกค้า', player.position, Palette.mocha);
      return;
    }
    if (tray.value.isEmpty) {
      _floatText('ถาดว่างอยู่', player.position, Palette.mocha);
      return;
    }

    final remaining = List.of(tray.value);
    var paid = 0;
    var servedAnything = false;

    // เสิร์ฟน้ำหอมผสม (หยิบขวดแรกบนถาด)
    if (customer.blendPending) {
      final blendItem = remaining.whereType<TrayBlend>().firstOrNull;
      if (blendItem != null) {
        final wanted = customer.order.blend!;
        final correct = wanted.matches(blendItem.mixed);
        if (!correct) customer.anyWrong = true;
        if (correct && wanted.secret) _secretServes += 1;
        paid += correct ? wanted.price : Balance.wrongItemPay(wanted.price);
        customer.blendPending = false;
        remaining.remove(blendItem);
        servedAnything = true;
      }
    }
    // เสิร์ฟสินค้าสำเร็จ
    if (customer.productPending) {
      final productItem = remaining.whereType<TrayProduct>().firstOrNull;
      if (productItem != null) {
        final wanted = customer.order.product!;
        final correct = productItem.product.id == wanted.id;
        if (!correct) customer.anyWrong = true;
        if (correct) _productsSold += 1;
        paid += correct ? wanted.price : Balance.wrongItemPay(wanted.price);
        customer.productPending = false;
        remaining.remove(productItem);
        servedAnything = true;
      }
    }

    if (!servedAnything) {
      _floatText('ไม่มีของที่ลูกค้าคนนี้สั่ง', player.position, Palette.mocha);
      return;
    }

    tray.value = remaining;
    earnedToday.value += paid;
    _floatText(
      '+$paid',
      customer.position,
      customer.anyWrong ? Palette.mocha : Palette.gold,
    );

    if (customer.orderComplete) {
      if (!customer.anyWrong) {
        _perfect += 1;
        spawnServeBurst(
          worldRoot,
          customer.position - Vector2(0, room.h * 0.10),
        );
        final tip = Balance.tip(
          customer.order.totalPrice,
          customer.patienceLeft / customer.order.patienceSeconds,
          save.ambiance,
        );
        if (tip > 0) {
          _tips += tip;
          earnedToday.value += tip;
          _floatText(
            'ทิป +$tip',
            customer.position - Vector2(0, room.h * 0.05),
            Palette.gold,
          );
        }
      }
      _served += 1;
      stands[index].occupant = null;
      customer.leave(happy: !customer.anyWrong);
    }
  }

  /// ลูกค้าหมดความอดทน (Customer เรียกเอง)
  void customerLost(CustomerComponent customer) {
    if (customer.state == CustomerState.leaving) return;
    _lost += 1;
    stands[customer.standIndex].occupant = null;
    _floatText('ลูกค้าหนีแล้ว!', customer.position, Palette.angry);
    customer.leave(happy: false);
  }

  void _floatText(String text, Vector2 at, Color color) {
    worldRoot.add(
      FloatingText(text, position: at - Vector2(0, room.h * 0.16), color: color),
    );
  }

  /// ปิดร้านก่อนหมดเวลา (ปุ่มพักบน HUD เรียก)
  void endDayEarly() => _endDay();

  void _endDay() {
    if (_dayOver) return;
    _dayOver = true;
    activePanel.value = null;
    onDayEnd(
      DayResult(
        earned: earnedToday.value,
        tips: _tips,
        served: _served,
        lost: _lost,
        perfect: _perfect,
        productsSold: _productsSold,
        secretServes: _secretServes,
      ),
    );
  }
}

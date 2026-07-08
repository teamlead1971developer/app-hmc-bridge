import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/blend_station.dart';
import '../game/product_panel.dart';
import '../game/shop_game.dart';
import '../models/game_save.dart';
import '../models/scent_blend.dart';
import '../services/balance.dart';
import '../services/quests.dart';
import '../services/save_service.dart';
import '../theme/palette.dart';
import '../widgets/pixel_ui.dart';
import '../widgets/smooth.dart';
import 'summary_screen.dart';

/// หน้าเปิดร้านหนึ่งวัน: เกมเต็มจอ แตะเพื่อเดิน
/// แผงผสมกลิ่น/ชั้นสินค้าเด้งขึ้นจากขอบล่างแบบนุ่มนวลเมื่อเดินถึงสถานี
class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key, required this.save});

  final GameSave save;

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  late final ShopGame _game = ShopGame(save: widget.save, onDayEnd: _onDayEnd);

  /// ลำดับการ์ดสอนเล่น (-1 = ไม่โชว์)
  int _tutorialStep = -1;

  static const _tutorialCards = [
    ('💬', 'ลูกค้าจะเดินเข้ามายืนที่แผงโชว์\nแล้วสั่งกลิ่นผ่านบับเบิลเหนือหัว'),
    ('🧪', 'เดินผ่านซุ้มฝั่งซ้ายไปหลังร้าน\nแตะโต๊ะปรุงเพื่อผสมน้ำหอม\nแตะชั้นวางเพื่อหยิบสินค้าสำเร็จ'),
    ('🔔', 'ถือของกลับมาเสิร์ฟที่แผงโชว์\nถ้าอยู่หลังร้าน แตะกระดิ่งบน HUD\nตัวละครจะเดินกลับหน้าร้านให้เอง'),
  ];

  @override
  void initState() {
    super.initState();
    if (!widget.save.tutorialSeen) {
      _tutorialStep = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _tutorialStep >= 0) _game.pauseEngine();
      });
    }
  }

  void _advanceTutorial() {
    setState(() => _tutorialStep++);
    if (_tutorialStep >= _tutorialCards.length) {
      _tutorialStep = -1;
      widget.save.tutorialSeen = true;
      SaveService().save(widget.save);
      _game.resumeEngine();
    }
  }

  Future<void> _showPauseDialog() async {
    _game.pauseEngine();
    final endDay = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Palette.cream,
        title: const Text('พักก่อน ⏸'),
        content: const Text('จะเล่นต่อ หรือปิดร้านวันนี้เลย?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('เล่นต่อ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Palette.lilacDeep),
            child: const Text('ปิดร้านเลย'),
          ),
        ],
      ),
    );
    _game.resumeEngine();
    if (endDay ?? false) _game.endDayEarly();
  }

  Future<void> _onDayEnd(DayResult result) async {
    final save = widget.save
      ..coins += result.earned
      ..day += 1;
    // สะสมความคืบหน้าเควสรายวันก่อนบันทึก
    Quests.applyDayResult(save, DateTime.now(), result);
    await SaveService().save(save);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      smoothRoute(SummaryScreen(save: save, result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _Hud(
                  game: _game,
                  day: widget.save.day,
                  onPause: _showPauseDialog,
                ),
                Expanded(child: GameWidget(game: _game)),
              ],
            ),
            // แบนเนอร์ฉลองตอนค้นพบสูตรลับใหม่
            Align(
              alignment: const Alignment(0, -0.45),
              child: ValueListenableBuilder<ScentBlend?>(
                valueListenable: _game.discovery,
                builder: (context, blend, _) => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 380),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: blend == null
                      ? const SizedBox.shrink(key: ValueKey('none'))
                      : PixelPanel(
                          key: ValueKey(blend.id),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 16,
                          ),
                          borderColor: Palette.gold,
                          borderWidth: 3.5,
                          corner: 12,
                          child: Column(
                            mainAxisSize: .min,
                            children: [
                              const Text(
                                '✨ ค้นพบกลิ่นใหม่! ✨',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Palette.mocha,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                blend.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Palette.espresso,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'เข้าคลัง Scentorium แล้ว • โบนัส +${Balance.discoveryBonus(blend)} 🪙',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Palette.mocha,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
            // แผงสถานีเด้งขึ้นจากขอบล่างแบบ spring ตามสถานีที่ผู้เล่นเดินถึง
            Align(
              alignment: .bottomCenter,
              child: ValueListenableBuilder<StationPanel?>(
                valueListenable: _game.activePanel,
                builder: (context, panel, _) => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 340),
                  reverseDuration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) => SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                  child: switch (panel) {
                    StationPanel.blend => BlendStation(
                      key: const ValueKey('blend'),
                      onAddToTray: _game.addBlendToTray,
                      onClose: () => _game.activePanel.value = null,
                      menu: Balance.orderPool(widget.save.day, widget.save),
                      notes: (widget.save.ownedNotes.toList()
                        ..sort((a, b) => a.index - b.index)),
                    ),
                    StationPanel.product => ProductPanel(
                      key: const ValueKey('product'),
                      onTake: _game.addProductToTray,
                      onClose: () => _game.activePanel.value = null,
                    ),
                    null => const SizedBox.shrink(key: ValueKey('none')),
                  },
                ),
              ),
            ),
            // สอนเล่นครั้งแรก: การ์ด 3 ใบ แตะเพื่อไปต่อ (เกม pause อยู่)
            if (_tutorialStep >= 0 && _tutorialStep < _tutorialCards.length)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _advanceTutorial,
                  child: Container(
                    color: Palette.espresso.withValues(alpha: 0.55),
                    alignment: .center,
                    child: PixelPanel(
                      fill: Palette.cream,
                      borderColor: Palette.lilacDeep,
                      borderWidth: 3.5,
                      corner: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 36),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: .min,
                        children: [
                          Text(
                            _tutorialCards[_tutorialStep].$1,
                            style: const TextStyle(fontSize: 44),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _tutorialCards[_tutorialStep].$2,
                            textAlign: .center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Palette.espresso,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'แตะเพื่อไปต่อ (${_tutorialStep + 1}/${_tutorialCards.length})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Palette.mocha,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({required this.game, required this.day, required this.onPause});

  final ShopGame game;
  final int day;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onPause,
            visualDensity: VisualDensity.compact,
            tooltip: 'พัก/ปิดร้าน',
            icon: const Icon(Icons.pause_circle_outline_rounded,
                color: Palette.espresso),
          ),
          Text(
            'วันที่ $day',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Palette.espresso,
            ),
          ),
          const SizedBox(width: 12),
          // แถบเวลาที่เหลือของวัน
          Expanded(
            child: ValueListenableBuilder<double>(
              valueListenable: game.timeLeft,
              builder: (context, timeLeft, _) => PixelProgressBar(
                value: timeLeft / Balance.dayLengthSeconds,
                height: 14,
                background: Palette.white,
                color: Palette.lilacDeep,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _WaitingBell(game: game),
          const SizedBox(width: 8),
          _TrayBadge(game: game),
          const SizedBox(width: 12),
          // ตัวเลขเหรียญไหลนับขึ้นแบบนุ่มนวล
          ValueListenableBuilder<int>(
            valueListenable: game.earnedToday,
            builder: (context, earned, _) => TweenAnimationBuilder<double>(
              tween: Tween(end: earned.toDouble()),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => Text(
                '🪙 ${value.round()}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Palette.espresso,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// กระดิ่งแจ้งลูกค้ารอหน้าร้าน — แตะแล้วตัวละครเดินกลับหน้าร้านเอง
/// (สำคัญตอนอยู่หลังร้านเพราะมองไม่เห็นลูกค้า)
class _WaitingBell extends StatelessWidget {
  const _WaitingBell({required this.game});

  final ShopGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.waitingCount,
      builder: (context, waiting, _) => AnimatedScale(
        scale: waiting > 0 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        child: GestureDetector(
          onTap: game.goToFrontRoom,
          child: PixelPanel(
            fill: Palette.butter,
            borderColor: Palette.gold,
            borderWidth: 2.5,
            corner: 6,
            shadow: false,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: Text(
              '🔔 $waiting',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Palette.espresso,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ช่องถาด 2 ช่องบน HUD — โชว์ว่าถืออะไรอยู่
class _TrayBadge extends StatelessWidget {
  const _TrayBadge({required this.game});

  final ShopGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<TrayItem>>(
      valueListenable: game.tray,
      builder: (context, tray, _) => Row(
        mainAxisSize: .min,
        children: [
          const Text('🫳', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          for (var i = 0; i < Balance.traySize; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(left: 3),
              decoration: BoxDecoration(
                color: Palette.white,
                border: Border.all(
                  color: i < tray.length ? Palette.espresso : Palette.shadow,
                  width: 2,
                ),
              ),
              child: i < tray.length
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        color: switch (tray[i]) {
                          TrayBlend(:final mixed) =>
                            mixed.isEmpty ? Palette.latte : mixed.last.color,
                          TrayProduct(:final product) => product.color,
                        },
                      ),
                    )
                  : null,
            ),
        ],
      ),
    );
  }
}

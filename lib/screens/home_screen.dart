import 'package:flutter/material.dart';

import '../models/game_save.dart';
import '../models/scent_blend.dart';
import '../services/balance.dart';
import '../services/quests.dart';
import '../services/save_service.dart';
import '../theme/palette.dart';
import '../widgets/pixel_ui.dart';
import '../widgets/smooth.dart';
import 'decorate_screen.dart';
import 'scentorium_screen.dart';
import 'shift_screen.dart';

/// เมนูหลักของเกม: โชว์สถานะร้าน + ปุ่มเข้าโหมดต่างๆ
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _saveService = SaveService();
  GameSave? _save;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final save = await _saveService.load();
    if (!mounted) return;

    final now = DateTime.now();
    // ข้ามวันจริงแล้ว → ชุดเควสใหม่
    final oldQuestDate = save.questDate;
    Quests.ensureFresh(save, now);

    // รายได้ออฟไลน์: ห่างจากครั้งล่าสุดเกิน 3 นาที
    final gapMs = now.millisecondsSinceEpoch - save.lastSeenMs;
    final offline = Balance.offlineEarnings(save, now.millisecondsSinceEpoch);
    final showOffline =
        save.lastSeenMs > 0 && gapMs > 3 * 60 * 1000 && offline > 0;

    setState(() => _save = save);

    if (showOffline) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showOfflineDialog(save, offline),
      );
    } else if (oldQuestDate != save.questDate) {
      // เซฟชุดเควสใหม่ (และประทับเวลา) แม้ไม่มีรายได้ออฟไลน์
      await _saveService.save(save);
    }
  }

  Future<void> _showOfflineDialog(GameSave save, int offline) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Palette.cream,
        title: const Text('ร้านขายเองระหว่างคุณไม่อยู่ 🌙'),
        content: Text(
          'กลิ่นหอมเรียกลูกค้าเข้าร้านตลอดคืน\nได้มา +$offline 🪙\n'
          '(อัตรา ${Balance.offlineRatePerHour(save)}/ชม. ตาม ⭐ และกลิ่นที่ค้นพบ)',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(backgroundColor: Palette.lilacDeep),
            child: const Text('รับเลย'),
          ),
        ],
      ),
    );
    setState(() => save.coins += offline);
    await _saveService.save(save); // ประทับเวลาใหม่ กันรับซ้ำ
  }

  Future<void> _claimQuest(GameSave save, int index, DailyQuest quest) async {
    setState(() {
      save.questClaimed[index] = true;
      save.coins += quest.reward;
    });
    await _saveService.save(save);
  }

  Future<void> _open(Widget Function(GameSave save) builder) async {
    final save = _save;
    if (save == null) return;
    await Navigator.of(context).push(smoothRoute(builder(save)));
    await _reload();
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Palette.cream,
        title: const Text('เริ่มเกมใหม่?'),
        content: const Text('เงินและของตกแต่งทั้งหมดจะหายนะ'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Palette.angry),
            child: const Text('เริ่มใหม่'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await _saveService.reset();
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final save = _save;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: .topCenter,
            end: .bottomCenter,
            colors: [Palette.cream, Palette.lavender],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: save == null
                ? const CircularProgressIndicator(color: Palette.lilacDeep)
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                    mainAxisAlignment: .center,
                    children: [
                      const Text('🌸', style: TextStyle(fontSize: 72)),
                      const SizedBox(height: 8),
                      const Text(
                        'Aroma Atelier',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Palette.espresso,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Text(
                        'บูติกน้ำหอมจิ๋วของคุณ',
                        style: TextStyle(fontSize: 15, color: Palette.mocha),
                      ),
                      const SizedBox(height: 24),
                      _StatsCard(save: save),
                      const SizedBox(height: 14),
                      _QuestBar(
                        save: save,
                        onClaim: (i, q) => _claimQuest(save, i, q),
                      ),
                      const SizedBox(height: 14),
                      PressableScale(
                        child: SizedBox(
                          width: 240,
                          height: 56,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Palette.lilacDeep,
                            ),
                            onPressed: () =>
                                _open((save) => ShiftScreen(save: save)),
                            child: Text('เปิดร้าน — วันที่ ${save.day}'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      PressableScale(
                        child: SizedBox(
                          width: 240,
                          height: 56,
                          child: FilledButton.tonal(
                            onPressed: () =>
                                _open((save) => DecorateScreen(save: save)),
                            child: const Text('แต่งร้าน 🪴'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      PressableScale(
                        child: SizedBox(
                          width: 240,
                          height: 56,
                          child: FilledButton.tonal(
                            onPressed: () =>
                                _open((save) => ScentoriumScreen(save: save)),
                            child: Text(
                              'Scentorium 🏺 '
                              '(${_knownBlendCount(save)}/${BlendCatalog.all.length})',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: _confirmReset,
                        child: const Text(
                          'เริ่มเกมใหม่',
                          style: TextStyle(color: Palette.mocha),
                        ),
                      ),
                    ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// จำนวนกลิ่นที่รู้จักแล้ว (ทั่วไปที่ปลด + สูตรลับที่ค้นพบ)
int _knownBlendCount(GameSave save) => BlendCatalog.all
    .where(
      (b) => b.secret ? save.discovered.contains(b.id) : b.unlockDay <= save.day,
    )
    .length;

/// แถบเควสรายวัน 3 ใบ — ครบเป้าแล้วกดรับเหรียญ
class _QuestBar extends StatelessWidget {
  const _QuestBar({required this.save, required this.onClaim});

  final GameSave save;
  final void Function(int index, DailyQuest quest) onClaim;

  @override
  Widget build(BuildContext context) {
    final quests = Quests.generateDaily(DateTime.now(), save.questDay);
    return PixelPanel(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          const Text(
            '📋 เควสวันนี้',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Palette.mocha,
            ),
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < quests.length; i++) _questRow(i, quests[i]),
        ],
      ),
    );
  }

  Widget _questRow(int i, DailyQuest quest) {
    final progress =
        i < save.questProgress.length ? save.questProgress[i] : 0;
    final claimed = i < save.questClaimed.length && save.questClaimed[i];
    final done = progress >= quest.target;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(quest.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  quest.label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Palette.espresso,
                    decoration: claimed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 3),
                PixelProgressBar(
                  value: (progress / quest.target).clamp(0.0, 1.0),
                  height: 9,
                  color: claimed ? Palette.sage : Palette.lilacDeep,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (claimed)
            const Text('✓', style: TextStyle(color: Palette.sageDark))
          else if (done)
            PressableScale(
              child: FilledButton(
                onPressed: () => onClaim(i, quest),
                style: FilledButton.styleFrom(
                  backgroundColor: Palette.gold,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 30),
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: Text('รับ ${quest.reward}'),
              ),
            )
          else
            Text(
              '$progress/${quest.target}',
              style: const TextStyle(fontSize: 11, color: Palette.mocha),
            ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.save});

  final GameSave save;

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        mainAxisSize: .min,
        children: [
          _Stat(emoji: '🪙', label: 'เหรียญ', value: '${save.coins}'),
          const SizedBox(width: 24),
          _Stat(emoji: '⭐', label: 'บรรยากาศ', value: '${save.ambiance}'),
          const SizedBox(width: 24),
          _Stat(emoji: '🗓️', label: 'วันที่', value: '${save.day}'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.emoji, required this.label, required this.value});

  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      children: [
        Text('$emoji $value',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Palette.espresso,
            )),
        Text(label, style: const TextStyle(fontSize: 12, color: Palette.mocha)),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../game/shop_painting.dart';
import '../models/game_save.dart';
import '../models/scent_blend.dart';
import '../services/save_service.dart';
import '../theme/palette.dart';
import '../widgets/smooth.dart';

/// Scentorium — คลังกลิ่นของร้าน: ผนังขวดโชว์กลิ่นที่รู้จัก/ค้นพบ
/// เงาขวดของสูตรลับ (แตะดูคำใบ้) และโซนซื้อหัวน้ำหอมใหม่
class ScentoriumScreen extends StatefulWidget {
  const ScentoriumScreen({super.key, required this.save});

  final GameSave save;

  @override
  State<ScentoriumScreen> createState() => _ScentoriumScreenState();
}

class _ScentoriumScreenState extends State<ScentoriumScreen> {
  GameSave get save => widget.save;

  /// รู้จักกลิ่นนี้แล้วไหม (ทั่วไปปลดตามวัน / สูตรลับต้องค้นพบ)
  bool _known(ScentBlend b) =>
      b.secret ? save.discovered.contains(b.id) : b.unlockDay <= save.day;

  int get _knownCount => BlendCatalog.all.where(_known).length;

  Future<void> _buyNote(ScentNote note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Palette.cream,
        title: Text('ซื้อหัวน้ำหอม "${note.label}"?'),
        content: Text(
          'ราคา 🪙 ${note.unlockPrice} — ใช้ผสมบนโต๊ะปรุงได้ทันที '
          'และลูกค้าจะเริ่มสั่งกลิ่นที่ใช้โน้ตนี้',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยังก่อน'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Palette.lilacDeep),
            child: const Text('ซื้อเลย'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;
    setState(() {
      save.coins -= note.unlockPrice;
      save.notesOwned.add(note.name);
    });
    await SaveService().save(save);
  }

  void _showBlendDetail(ScentBlend blend) {
    final known = _known(blend);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Palette.cream,
        title: Text(known ? blend.name : 'กลิ่นลึกลับ ❓'),
        content: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            if (known) ...[
              Row(
                children: [
                  for (final note in blend.recipe)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Column(
                        mainAxisSize: .min,
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: note.color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Palette.shadow),
                            ),
                          ),
                          Text(
                            note.label,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Palette.mocha,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'ราคาขาย 🪙 ${blend.price}'
                '${blend.secret ? '  •  ✨ สูตรลับที่คุณค้นพบ' : ''}',
                style: const TextStyle(color: Palette.espresso),
              ),
            ] else if (blend.secret) ...[
              const Text(
                'คำใบ้:',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Palette.mocha,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '"${blend.hint}"',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Palette.espresso,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'ทดลองหยดผสมที่โต๊ะปรุงให้ตรงสูตรเพื่อค้นพบ',
                style: TextStyle(fontSize: 12, color: Palette.mocha),
              ),
            ] else
              Text(
                'สูตรทั่วไป — ปลดล็อกวันที่ ${blend.unlockDay}',
                style: const TextStyle(color: Palette.mocha),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lockedNotes = ScentNote.values
        .where((n) => n.unlockPrice > 0)
        .toList();
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Palette.espresso),
                  ),
                  const Text(
                    'Scentorium 🏺',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Palette.espresso,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'ค้นพบแล้ว $_knownCount/${BlendCatalog.all.length}  •  🪙 ${save.coins}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Palette.espresso,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'คลังกลิ่นของร้าน — สูตรลับต้องทดลองผสมเองถึงจะค้นพบ',
                style: TextStyle(fontSize: 12, color: Palette.mocha),
              ),
            ),
            const SizedBox(height: 8),
            // ผนังขวด
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: .topCenter,
                    end: .bottomCenter,
                    colors: [Palette.woodLight, Palette.woodDark],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: BlendCatalog.all.length,
                  itemBuilder: (context, index) {
                    final blend = BlendCatalog.all[index];
                    return _BottleCard(
                      blend: blend,
                      known: _known(blend),
                      onTap: () => _showBlendDetail(blend),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            // โซนซื้อหัวน้ำหอมใหม่
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'หัวน้ำหอมใหม่',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Palette.espresso.withValues(alpha: 0.85),
                ),
              ),
            ),
            SizedBox(
              height: 96,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: .horizontal,
                children: [
                  for (final note in lockedNotes)
                    _NoteShopCard(
                      note: note,
                      owned: save.notesOwned.contains(note.name),
                      affordable: save.coins >= note.unlockPrice,
                      onBuy: () => _buyNote(note),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// ขวดหนึ่งใบบนผนัง Scentorium
class _BottleCard extends StatelessWidget {
  const _BottleCard({
    required this.blend,
    required this.known,
    required this.onTap,
  });

  final ScentBlend blend;
  final bool known;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: known
                ? Palette.white.withValues(alpha: 0.92)
                : Palette.espresso.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
            border: blend.secret && known
                ? Border.all(color: Palette.gold, width: 1.5)
                : null,
          ),
          child: Column(
            children: [
              Expanded(
                child: CustomPaint(
                  size: const Size(40, 52),
                  painter: _ShelfBottlePainter(blend: blend, known: known),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                known ? blend.name : (blend.secret ? '???' : '🔒 วัน ${blend.unlockDay}'),
                maxLines: 2,
                textAlign: .center,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: known ? Palette.espresso : Palette.cream,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShelfBottlePainter extends CustomPainter {
  _ShelfBottlePainter({required this.blend, required this.known});

  final ScentBlend blend;
  final bool known;

  @override
  void paint(Canvas canvas, Size size) {
    // รู้จักแล้ว = ขวดโชว์ชั้นสีสูตรจริง / ยังลับอยู่ = ขวดเปล่ามืดลึกลับ
    paintBottle(canvas, size, known ? blend.recipe : const []);
    if (!known) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..color = Palette.espresso.withValues(alpha: 0.45)
          ..blendMode = BlendMode.srcATop,
      );
    }
  }

  @override
  bool shouldRepaint(_ShelfBottlePainter oldDelegate) =>
      oldDelegate.known != known || oldDelegate.blend != blend;
}

/// การ์ดซื้อหัวน้ำหอมใหม่
class _NoteShopCard extends StatelessWidget {
  const _NoteShopCard({
    required this.note,
    required this.owned,
    required this.affordable,
    required this.onBuy,
  });

  final ScentNote note;
  final bool owned;
  final bool affordable;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: owned || affordable ? 1 : 0.5,
      child: GestureDetector(
        onTap: owned || !affordable ? null : onBuy,
        child: Container(
          width: 104,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Palette.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: owned ? Palette.sageDark : Palette.shadow,
            ),
          ),
          child: Column(
            mainAxisAlignment: .center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: note.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Palette.shadow),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                note.label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Palette.espresso,
                ),
              ),
              Text(
                owned ? 'มีแล้ว ✓' : '🪙 ${note.unlockPrice}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: owned ? Palette.sageDark : Palette.mocha,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/scent_blend.dart';
import '../theme/palette.dart';
import 'shop_painting.dart';

/// แผงผสมน้ำหอม (เด้งขึ้นเมื่อผู้เล่นเดินถึงโต๊ะปรุง):
/// แตะหัวน้ำหอมหยดลงขวด แล้วกด "ใส่ถาด" เพื่อถือไปเสิร์ฟที่โต๊ะ
class BlendStation extends StatefulWidget {
  const BlendStation({
    super.key,
    required this.onAddToTray,
    required this.onClose,
    required this.menu,
    required this.notes,
  });

  /// คืน false เมื่อถาดเต็ม
  final bool Function(List<ScentNote> mixed) onAddToTray;
  final VoidCallback onClose;

  /// สูตรที่รู้แล้ว (ทั่วไปที่ปลด + สูตรลับที่ค้นพบ) ไว้เปิดดูในสมุด
  final List<ScentBlend> menu;

  /// หัวน้ำหอมที่ผู้เล่นมี (ปุ่มบนแผง)
  final List<ScentNote> notes;

  @override
  State<BlendStation> createState() => _BlendStationState();
}

class _BlendStationState extends State<BlendStation> {
  final _mixed = <ScentNote>[];
  String? _feedback;
  Color _feedbackColor = Palette.espresso;

  void _addNote(ScentNote note) {
    if (_mixed.length >= 4) return;
    setState(() {
      _mixed.add(note);
      _feedback = null;
    });
  }

  void _addToTray() {
    if (_mixed.isEmpty) {
      setState(() {
        _feedback = 'ยังไม่ได้หยดกลิ่นเลย';
        _feedbackColor = Palette.mocha;
      });
      return;
    }
    final added = widget.onAddToTray(List.of(_mixed));
    setState(() {
      if (added) {
        _mixed.clear();
        _feedback = 'ใส่ถาดแล้ว! เดินไปเสิร์ฟได้เลย ✨';
        _feedbackColor = Palette.sageDark;
      } else {
        _feedback = 'ถาดเต็มแล้ว! ไปเสิร์ฟหรือเททิ้งก่อน';
        _feedbackColor = Palette.angry;
      }
    });
  }

  void _showRecipeSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Palette.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              const Text(
                '📖 สูตรกลิ่นวันนี้',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Palette.espresso,
                ),
              ),
              const SizedBox(height: 12),
              for (final blend in widget.menu)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          blend.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Palette.espresso,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      for (final note in blend.recipe)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _NoteDot(note: note),
                        ),
                      const Spacer(),
                      Text(
                        '🪙 ${blend.price}',
                        style: const TextStyle(color: Palette.mocha),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Palette.counterTop,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Palette.shadow, blurRadius: 12, offset: Offset(0, -4)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: .min,
          children: [
            Row(
              children: [
                // พรีวิวขวด diffuser
                SizedBox(
                  width: 64,
                  height: 76,
                  child: CustomPaint(painter: _BottlePainter(List.of(_mixed))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        _feedback ?? 'หยดหัวน้ำหอมตามออเดอร์ แล้วกดใส่ถาด',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _feedback == null
                              ? Palette.mocha
                              : _feedbackColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        children: [
                          for (final note in _mixed)
                            _NoteDot(note: note, size: 18),
                          if (_mixed.isEmpty)
                            const Text(
                              'ขวดยังว่าง',
                              style: TextStyle(
                                fontSize: 12,
                                color: Palette.latte,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _showRecipeSheet,
                  tooltip: 'ดูสูตร',
                  icon: const Icon(Icons.menu_book_rounded, color: Palette.mocha),
                ),
                IconButton(
                  onPressed: _mixed.isEmpty
                      ? null
                      : () => setState(_mixed.clear),
                  tooltip: 'เททิ้ง',
                  icon: const Icon(Icons.delete_outline_rounded, color: Palette.mocha),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  tooltip: 'ปิด',
                  icon: const Icon(Icons.close_rounded, color: Palette.mocha),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final note in widget.notes)
                        _NoteButton(note: note, onTap: () => _addNote(note)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 96,
                  height: 88,
                  child: FilledButton(
                    onPressed: _addToTray,
                    style: FilledButton.styleFrom(
                      backgroundColor: Palette.lilacDeep,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'ใส่ถาด 🌸',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteButton extends StatelessWidget {
  const _NoteButton({required this.note, required this.onTap});

  final ScentNote note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Palette.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 86,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: .min,
            children: [
              _NoteDot(note: note, size: 22),
              const SizedBox(height: 4),
              Text(
                note.label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Palette.espresso,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteDot extends StatelessWidget {
  const _NoteDot({required this.note, this.size = 14});

  final ScentNote note;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: note.color,
        shape: BoxShape.circle,
        border: Border.all(color: Palette.shadow),
      ),
    );
  }
}

class _BottlePainter extends CustomPainter {
  _BottlePainter(this.mixed);

  final List<ScentNote> mixed;

  @override
  void paint(Canvas canvas, Size size) => paintBottle(canvas, size, mixed);

  @override
  bool shouldRepaint(_BottlePainter oldDelegate) =>
      oldDelegate.mixed.length != mixed.length;
}

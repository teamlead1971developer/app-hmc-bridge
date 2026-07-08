import 'package:flutter/material.dart';

import '../game/room_layout.dart';
import '../game/shop_painting.dart';
import '../models/decor_item.dart';
import '../models/game_save.dart';
import '../models/placed_decor.dart';
import '../services/balance.dart';
import '../services/save_service.dart';
import '../theme/palette.dart';
import '../widgets/pixel_ui.dart';

/// โหมดแต่งร้าน: เลือกของจากร้านค้า แตะช่องว่างในห้องเพื่อวาง
/// แตะของที่วางแล้วเพื่อขายคืน — เซฟอัตโนมัติทุกการเปลี่ยนแปลง
class DecorateScreen extends StatefulWidget {
  const DecorateScreen({super.key, required this.save});

  final GameSave save;

  @override
  State<DecorateScreen> createState() => _DecorateScreenState();
}

class _DecorateScreenState extends State<DecorateScreen> {
  final _saveService = SaveService();

  /// ของที่เลือกจากร้านค้า รอแตะช่องวาง
  DecorItem? _selecting;

  GameSave get save => widget.save;

  /// ช่องเริ่มต้นที่ยังวางของชิ้นนี้ได้
  List<int> _freeSlots(DecorItem item) {
    if (item.layer == DecorLayer.wallpaper) return const [0];
    final occupied = <int>{};
    for (final p in save.placed) {
      if (p.item.layer != item.layer) continue;
      for (var c = 0; c < p.item.cells; c++) {
        occupied.add(p.slot + c);
      }
    }
    return [
      for (var s = 0; s <= item.layer.slotCount - item.cells; s++)
        if (![for (var c = 0; c < item.cells; c++) s + c]
            .any(occupied.contains))
          s,
    ];
  }

  Future<void> _persist() => _saveService.save(save);

  void _selectFromShop(DecorItem item) {
    if (save.coins < item.price) return;
    setState(() => _selecting = _selecting?.id == item.id ? null : item);
  }

  Future<void> _placeAt(DecorItem item, int slot) async {
    save.coins -= item.price;
    if (item.layer == DecorLayer.wallpaper) {
      // เปลี่ยนวอลเปเปอร์: ขายแผ่นเก่าคืนเต็มราคา
      final old = save.placed
          .where((p) => p.item.layer == DecorLayer.wallpaper)
          .toList();
      for (final p in old) {
        save.coins += p.item.price;
        save.placed.remove(p);
      }
    }
    save.placed.add(PlacedDecor(itemId: item.id, slot: slot));
    setState(() => _selecting = null);
    await _persist();
  }

  Future<void> _tapRoom(Offset localPos, Size size) async {
    final room = RoomLayout(size);
    // พรีวิวโชว์เฉพาะหน้าร้าน — แปลงพิกัดแตะเป็นพิกัดโลกก่อนเทียบช่อง
    final pos = localPos + Offset(room.frontX, 0);
    final selecting = _selecting;

    if (selecting != null) {
      if (selecting.layer == DecorLayer.wallpaper) {
        if (pos.dy < room.floorTop) await _placeAt(selecting, 0);
        return;
      }
      for (final slot in _freeSlots(selecting)) {
        if (room
            .slotRect(selecting.layer, slot, selecting.cells)
            .contains(pos)) {
          await _placeAt(selecting, slot);
          return;
        }
      }
      return;
    }

    // ไม่ได้เลือกของอยู่ → แตะของที่วางไว้เพื่อขายคืน (เช็คชั้นหน้าไปหลัง)
    for (final layer in const [DecorLayer.floor, DecorLayer.wall, DecorLayer.rug]) {
      for (final p in save.placed.reversed) {
        if (p.item.layer != layer) continue;
        if (room.slotRect(layer, p.slot, p.item.cells).contains(pos)) {
          await _confirmRemove(p);
          return;
        }
      }
    }
  }

  Future<void> _confirmRemove(PlacedDecor placed) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Palette.cream,
        title: Text('ขายคืน "${placed.item.name}"?'),
        content: Text('ได้เงินคืน 🪙 ${placed.item.price}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('เก็บไว้'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ขายคืน'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      setState(() {
        save.placed.remove(placed);
        save.coins += placed.item.price;
      });
      await _persist();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selecting = _selecting;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: Palette.espresso),
                  ),
                  const Text(
                    'แต่งร้าน',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Palette.espresso,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '🪙 ${save.coins}   ⭐ ${save.ambiance}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Palette.espresso,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              selecting == null
                  ? 'ทุก ⭐ ทำให้ลูกค้าใจเย็นขึ้นและทิปแพงขึ้น — แตะของในห้องเพื่อขายคืน'
                  : 'แตะช่องที่ว่างเพื่อวาง "${selecting.name}"',
              style: TextStyle(
                fontSize: 12,
                color: selecting == null ? Palette.mocha : Palette.sageDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            // ห้องพรีวิว
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRect(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = constraints.biggest;
                      return GestureDetector(
                        onTapUp: (details) =>
                            _tapRoom(details.localPosition, size),
                        child: CustomPaint(
                          size: size,
                          painter: _DecorRoomPainter(
                            placed: List.of(save.placed),
                            highlightSlots: selecting == null
                                ? const []
                                : [
                                    for (final s in _freeSlots(selecting))
                                      RoomLayout(size).slotRect(
                                        selecting.layer,
                                        s,
                                        selecting.cells,
                                      ),
                                  ],
                            highlightWall: selecting?.layer ==
                                DecorLayer.wallpaper,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ร้านค้า
            SizedBox(
              height: 128,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: .horizontal,
                itemCount: DecorCatalog.all.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = DecorCatalog.all[index];
                  return _ShopCard(
                    item: item,
                    affordable: save.coins >= item.price,
                    selected: selecting?.id == item.id,
                    active: save.placed.any((p) => p.itemId == item.id &&
                        item.layer == DecorLayer.wallpaper),
                    onTap: () => _selectFromShop(item),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({
    required this.item,
    required this.affordable,
    required this.selected,
    required this.active,
    required this.onTap,
  });

  final DecorItem item;
  final bool affordable;
  final bool selected;

  /// วอลเปเปอร์ชิ้นนี้ติดผนังอยู่ตอนนี้
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: affordable || active ? 1 : 0.45,
      child: GestureDetector(
        onTap: active ? null : onTap,
        child: PixelPanel(
          width: 96,
          padding: const EdgeInsets.all(8),
          fill: selected ? Palette.butter : Palette.white,
          borderColor: selected ? Palette.sageDark : Palette.espresso,
          borderWidth: selected ? 3 : 2.5,
          corner: 6,
          shadow: false,
          child: Column(
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: CustomPaint(painter: _DecorPreviewPainter(item.kind)),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Text(
                  item.name,
                  maxLines: 2,
                  textAlign: .center,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Palette.espresso,
                  ),
                ),
              ),
              Text(
                active ? 'ติดอยู่ ✓' : '🪙${item.price}  ⭐${item.ambiance}',
                style: const TextStyle(fontSize: 10.5, color: Palette.mocha),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecorPreviewPainter extends CustomPainter {
  _DecorPreviewPainter(this.kind);

  final DecorKind kind;

  @override
  void paint(Canvas canvas, Size size) => paintDecor(canvas, kind, size);

  @override
  bool shouldRepaint(_DecorPreviewPainter oldDelegate) =>
      oldDelegate.kind != kind;
}

class _DecorRoomPainter extends CustomPainter {
  _DecorRoomPainter({
    required this.placed,
    required this.highlightSlots,
    required this.highlightWall,
  });

  final List<PlacedDecor> placed;
  final List<Rect> highlightSlots;
  final bool highlightWall;

  @override
  void paint(Canvas canvas, Size size) {
    final room = RoomLayout(size);
    // มองเฉพาะหน้าร้าน (ครึ่งขวาของโลก กว้างพอดี 1 จอ)
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(-room.frontX, 0);

    paintRoom(canvas, room, wallpaper: activeWallpaper(placed));
    paintPlacedDecor(canvas, room, placed);
    // แผงโชว์น้ำหอม (ของตายตัว) วาดไว้ให้เห็นบริบทตอนจัดร้าน
    for (var i = 0; i < Balance.standCount; i++) {
      final rect = room.standRect(i);
      canvas.save();
      canvas.translate(rect.left, rect.top);
      paintDisplayStand(canvas, rect.size);
      canvas.restore();
    }

    final fill = Paint()..color = Palette.sage.withValues(alpha: 0.35);
    final border = Paint()
      ..color = Palette.sageDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    if (highlightWall) {
      final wallRect = Rect.fromLTWH(room.frontX, 0, room.w, room.floorTop);
      canvas.drawRect(wallRect, fill);
      canvas.drawRect(wallRect.deflate(2), border);
    } else {
      for (final rect in highlightSlots) {
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
        canvas.drawRRect(rrect, fill);
        canvas.drawRRect(rrect, border);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DecorRoomPainter oldDelegate) => true;
}

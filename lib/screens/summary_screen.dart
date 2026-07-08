import 'package:flutter/material.dart';

import '../game/shop_game.dart';
import '../models/game_save.dart';
import '../theme/palette.dart';
import '../widgets/pixel_ui.dart';
import '../widgets/smooth.dart';
import 'decorate_screen.dart';
import 'shift_screen.dart';

/// สรุปผลจบวัน — เซฟถูกบันทึกมาแล้วจาก ShiftScreen
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key, required this.save, required this.result});

  final GameSave save;
  final DayResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: .center,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 64)),
                Text(
                  'ปิดร้านวันที่ ${save.day - 1} แล้ว!',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Palette.espresso,
                  ),
                ),
                const SizedBox(height: 24),
                PixelPanel(
                  padding: const EdgeInsets.all(20),
                  corner: 12,
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      _row('ยอดขายรวม', '🪙 ${result.earned}'),
                      _row('ในนั้นเป็นทิป', '💛 ${result.tips}'),
                      _row('ลูกค้าที่ได้ขาย', '😊 ${result.served}'),
                      _row('ลูกค้าหนีไป', '💨 ${result.lost}'),
                      const Divider(color: Palette.latte, height: 24),
                      _row('เงินในกระเป๋าตอนนี้', '🪙 ${save.coins}'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                PressableScale(
                  child: SizedBox(
                    width: 240,
                    height: 56,
                    child: FilledButton.tonal(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        smoothRoute(DecorateScreen(save: save)),
                      ),
                      child: const Text('เอาเงินไปแต่งร้าน 🪴'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                PressableScale(
                  child: SizedBox(
                    width: 240,
                    height: 56,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Palette.lilacDeep,
                      ),
                      onPressed: () => Navigator.of(context).pushReplacement(
                        smoothRoute(ShiftScreen(save: save)),
                      ),
                      child: Text('เปิดร้านวันที่ ${save.day} ▶'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'กลับหน้าหลัก',
                    style: TextStyle(color: Palette.mocha),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: .min,
        children: [
          SizedBox(
            width: 170,
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Palette.mocha),
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              value,
              textAlign: .end,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Palette.espresso,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

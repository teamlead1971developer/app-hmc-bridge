import 'package:flutter/material.dart';

import 'game/pixel/sprites.dart';
import 'screens/home_screen.dart';
import 'theme/palette.dart';
import 'widgets/pixel_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ประกอบ sprite sheet พิกเซลทั้งเกมครั้งเดียว (in-memory, ไม่มีไฟล์ asset)
  await PixelSprites.ensureLoaded();
  runApp(const AromaAtelierApp());
}

class AromaAtelierApp extends StatelessWidget {
  const AromaAtelierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aroma Atelier',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Palette.lilacDeep),
        scaffoldBackgroundColor: Palette.cream,
        textTheme: Typography.blackMountainView.apply(
          bodyColor: Palette.espresso,
          displayColor: Palette.espresso,
        ),
        // สไตล์ Pixel Chibi ทั้งแอป: มุมขั้นบันได + ขอบหนา + ไม่มีเงาเบลอ
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            elevation: 0,
            shape: const PixelBorder(corner: 8),
            side: const BorderSide(color: Palette.espresso, width: 3),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: Palette.cream,
          shape: PixelBorder(
            side: BorderSide(color: Palette.espresso, width: 3.5),
            corner: 12,
          ),
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: Palette.espresso,
          ),
          contentTextStyle: TextStyle(
            fontSize: 14,
            color: Palette.espresso,
            height: 1.5,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            shape: const PixelBorder(
              side: BorderSide(color: Colors.transparent, width: 0),
              corner: 6,
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

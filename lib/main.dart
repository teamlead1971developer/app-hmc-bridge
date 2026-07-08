import 'package:flutter/material.dart';

import 'game/pixel/sprites.dart';
import 'screens/home_screen.dart';
import 'theme/palette.dart';

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
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

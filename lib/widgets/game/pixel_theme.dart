import 'package:flutter/material.dart';

import '../../core/branding.dart';

// ---------------------------------------------------------------------------
// Pixel game design tokens (The Blending Room)
// ---------------------------------------------------------------------------

const kPixelCream = Color(0xFFF3E5C7);
const kPixelCard = Color(0xFFFBF3DC);
const kPixelRecessed = Color(0xFFEFE3C4);
const kPixelWood = Color(0xFF6E4A2C);
const kPixelWoodDark = Color(0xFF3A2618);
const kPixelWoodDarkest = Color(0xFF2A1B10);
const kPixelShowcase = Color(0xFF4E3320);
const kPixelInk = Color(0xFF3A2618);
const kPixelMuted = Color(0xFF5C4530);
const kPixelMutedLight = Color(0xFF8A6A4A);
const kPixelOnWoodMuted = Color(0xFFD9BE96);
const kPixelOnWoodMuted2 = Color(0xFFC9AE8A);
const kPixelDisabled = Color(0xFFA98D66);
const kPixelCoinGold = Color(0xFFE8A33D);
const kPixelCoinGoldBorder = Color(0xFF8A5A16);
const kPixelCoinGoldBright = Color(0xFFF0C464);
const kPixelBridgeRed = Color(0xFFC1201D);
const kPixelBridgeRedDark = Color(0xFFA00E0C);
const kPixelBridgeRedBorder = Color(0xFF7E0B09);
const kPixelGreen = Color(0xFF6E8B4E);
const kPixelSpice = Color(0xFFB05A2A);
const kPixelClay = Color(0xFFC97B63);
const kPixelWoodNote = Color(0xFF8B5E3C);
const kPixelAmber = Color(0xFFD89B3F);
const kPixelFlaskGlass = Color(0xFFDCE9E2);
const kPixelLockedTile = Color(0xFFDDD0AE);
const kPixelLockedBottle = Color(0xFF5C5344);

const kPixelBorderWidth = 4.0;
const kPixelBorderWidthSm = 3.0;

const kPixelCardShadow = BoxShadow(
  offset: Offset(4, 4),
  blurRadius: 0,
  color: Color(0x663A2618),
);

const kPixelScreenShadow = BoxShadow(
  offset: Offset(10, 10),
  blurRadius: 0,
  color: Color(0x73140C06),
);

TextStyle pixelStyle({
  double size = 15,
  FontWeight weight = FontWeight.w600,
  Color color = kPixelInk,
  double letterSpacing = 0,
}) {
  return TextStyle(
    fontFamily: 'PixelifySans',
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: 1.2,
  );
}

TextStyle vtStyle({
  double size = 16,
  Color color = kPixelMuted,
  FontWeight weight = FontWeight.w400,
}) {
  return TextStyle(
    fontFamily: 'VT323',
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: 1.15,
  );
}

/// Repeating 2-color pixel stripe fill.
BoxDecoration stripedDecoration(
  Color c1,
  Color c2, {
  Axis axis = Axis.vertical,
}) {
  return BoxDecoration(gradient: stripedGradient(c1, c2, axis: axis));
}

/// Striped gradient for use in [Container.decoration] or [BoxDecoration].
LinearGradient stripedGradient(
  Color c1,
  Color c2, {
  Axis axis = Axis.vertical,
  double band = 6,
}) {
  final isVertical = axis == Axis.vertical;
  return LinearGradient(
    begin: isVertical ? Alignment.topCenter : Alignment.centerLeft,
    end: isVertical ? Alignment.bottomCenter : Alignment.centerRight,
    colors: [c1, c1, c2, c2],
    stops: const [0, 0.5, 0.5, 1],
    tileMode: TileMode.repeated,
  );
}

/// Bridge brand reds reused from main app branding.
const kPixelBrandRed = kBrandColor;
const kPixelBrandRedLight = kRedLight;

String formatGameNumber(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

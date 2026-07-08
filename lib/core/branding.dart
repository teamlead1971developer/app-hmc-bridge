import 'package:flutter/widgets.dart';

/// BRIDGE glass design tokens — single source of truth for colors, gradients,
/// typography and logo assets (see design_handoff_glass_redesign/DESIGN_SYSTEM.md).

// ---------------------------------------------------------------------------
// Colors
// ---------------------------------------------------------------------------

/// Screen background, always.
const kBaseColor = Color(0xFF0A0A0C);

/// Brand red taken from the BRIDGE logo (#AC0F0D).
const kBrandColor = Color(0xFFAC0F0D);

/// Links, accent icons, chip text.
const kRedLight = Color(0xFFE4514E);

/// Primary text.
const kText = Color(0xFFF5F5F6);

/// Secondary text — white 55%.
const kTextMuted = Color(0x8CFFFFFF);

/// Captions, timestamps — white 40%.
const kTextFaint = Color(0x66FFFFFF);

/// Card fill — white 5%.
const kGlassFill = Color(0x0DFFFFFF);

/// Card border — white 10%.
const kGlassBorder = Color(0x1AFFFFFF);

/// Hero/highlight card border — white 13%.
const kGlassBorderHero = Color(0x21FFFFFF);

/// Nested rows/buttons inside cards — fill white 6%, border white 12%.
const kGlassInnerFill = Color(0x0FFFFFFF);
const kGlassInnerBorder = Color(0x1FFFFFFF);

/// Selected/status fills — rgba(172,15,13,0.14) with 0.32 border.
const kRedTintFill = Color(0x24AC0F0D);
const kRedTintBorder = Color(0x52AC0F0D);

/// Active chip/segment — rgba(172,15,13,0.35) fill, rgba(228,81,78,0.45) border.
const kActiveFill = Color(0x59AC0F0D);
const kActiveBorder = Color(0x73E4514E);

// ---------------------------------------------------------------------------
// Gradients
// ---------------------------------------------------------------------------

/// Primary buttons, slider knobs — 180deg #C1201D → #A00E0C.
const kRedGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFC1201D), Color(0xFFA00E0C)],
);

/// Avatars, icon marks — 160deg #C1201D → #7E0B09.
const kAvatarGradient = LinearGradient(
  begin: Alignment(-0.34, -0.94),
  end: Alignment(0.34, 0.94),
  colors: [Color(0xFFC1201D), Color(0xFF7E0B09)],
);

/// App icon squircle — 150deg #C1201D → #7A0B09.
const kIconGradient = LinearGradient(
  begin: Alignment(-0.5, -0.87),
  end: Alignment(0.5, 0.87),
  colors: [Color(0xFFC1201D), Color(0xFF7A0B09)],
);

// ---------------------------------------------------------------------------
// Shadows
// ---------------------------------------------------------------------------

/// Primary red-gradient CTA: red glow below + inset-like top highlight.
const kPrimaryButtonShadows = [
  BoxShadow(
    color: Color(0x73AC0F0D), // rgba(172,15,13,0.45)
    offset: Offset(0, 10),
    blurRadius: 30,
  ),
];

/// Hero cards.
const kHeroCardShadows = [
  BoxShadow(
    color: Color(0x59000000), // rgba(0,0,0,0.35)
    offset: Offset(0, 20),
    blurRadius: 50,
  ),
];

/// Red-glow accent (employee card).
const kRedGlowShadow = BoxShadow(
  color: Color(0x1FAC0F0D), // rgba(172,15,13,0.12)
  blurRadius: 50,
);

// ---------------------------------------------------------------------------
// Typography
// ---------------------------------------------------------------------------
// The bundled fonts are variable (wght axis), so styles set both fontWeight
// and the matching FontVariation.

const kFontBody = 'Geist';
const kFontDisplay = 'SpaceGrotesk';
const kFontMono = 'GeistMono';

FontWeight _closestWeight(double wght) =>
    FontWeight.values[(wght / 100).round().clamp(1, 9) - 1];

/// Body/UI text — Geist.
TextStyle bodyStyle({
  double size = 14,
  double weight = 400,
  Color color = kText,
  double? height,
}) {
  return TextStyle(
    fontFamily: kFontBody,
    fontSize: size,
    fontWeight: _closestWeight(weight),
    fontVariations: [FontVariation('wght', weight)],
    color: color,
    height: height,
  );
}

/// Names, headings, big numbers — Space Grotesk 600–700.
TextStyle displayStyle({
  double size = 28,
  double weight = 600,
  Color color = kText,
  double height = 1.1,
  double? letterSpacing,
}) {
  return TextStyle(
    fontFamily: kFontDisplay,
    fontSize: size,
    fontWeight: _closestWeight(weight),
    fontVariations: [FontVariation('wght', weight)],
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

/// IDs, times, technical labels — Geist Mono.
TextStyle monoStyle({
  double size = 13,
  double weight = 400,
  Color color = kText,
}) {
  return TextStyle(
    fontFamily: kFontMono,
    fontSize: size,
    fontWeight: _closestWeight(weight),
    fontVariations: [FontVariation('wght', weight)],
    color: color,
  );
}

// ---------------------------------------------------------------------------
// Logo assets
// ---------------------------------------------------------------------------

/// Modernized mark + white wordmark, transparent background — for dark surfaces.
const kLogoAsset = 'assets/images/bridge_logo_dark.png';

/// Original all-red logo — kept for light contexts.
const kLogoLightContextAsset = 'assets/images/bridge_logo.webp';

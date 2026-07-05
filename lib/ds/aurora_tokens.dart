import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Aurora design tokens — Dart mirror of design-system/styles.css :root
/// ("Fresh Matcha": bright spring green + sky blue on milky cream, warm ink
/// outlines, hard offset "pop" shadows, flat fills only — no gradients).
///
/// NOTE on `primaryLight`: in this LIGHT theme it carries the accent
/// FOREGROUND — a deeper, text-safe green for small text on cream surfaces.
/// Never use raw `primary` as small text on cream.
class Aurora {
  Aurora._();

  // ---- palette: spring green + sky blue, sun accent ----
  static const primary = Color(0xFF2C8248);
  static const primaryLight = Color(0xFF226539); // accent foreground (deep green)
  static const primaryDark = Color(0xFF123A1E);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFD4EDD6);
  static const onPrimaryContainer = Color(0xFF123A1E);
  static const secondary = Color(0xFF2F7BB4); // sky blue
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFD6E6F3);
  static const accent = Color(0xFFF4B63C); // soft sun
  static const onAccent = Color(0xFF3A2900);
  static const bloom = Color(0xFFE86A80); // coral pop (badges, blossoms)

  // ---- surfaces & text (milky cream, soft green-black ink) ----
  static const bg = Color(0xFFF6F4E9);
  static const paper = Color(0xFFFCFBF4);
  static const paper2 = Color(0xFFFFFFFF);
  static const paper3 = Color(0xFFECEADB); // sunken well / tracks / empty cells
  static const ink = Color(0xFF26302A); // signature outline colour
  static const textPrimary = Color(0xFF26302A);
  static const textSecondary = Color(0xFF5E6A56);
  static const textDisabled = Color(0xFF97A088);
  static const divider = Color(0x1F26302A);
  static const outline = Color(0x3826302A);
  static const border = Color(0xFFDCE2CE);

  /// Green selection tint (~16%): selected chips, avatar bg, tonal fills.
  static const accentTint = Color(0x292C8248);

  // ---- signature: PARA categories are neutral; status is semantic ----
  static const catNeutral = Color(0xFF6A7562);
  static const catArchive = Color(0xFF8B927F);
  static const stDone = Color(0xFF2E7D46); // success green
  static const stActionable = Color(0xFF2C8248); // primary
  static const stBlocked = Color(0xFF6A7562); // neutral sage
  static const stBlocker = Color(0xFFB93A2C); // brick
  static const stWarning = Color(0xFF8A621A); // deep honey (text-safe)
  static const stFoundation = Color(0xFF75612B); // olive bronze

  // ---- flat expressive fills (no gradients anywhere) ----
  static const washGreen = Color(0xFFE9F1E4); // flat primary-tinted wash
  static const bannerA = Color(0xFFD4EDD6);
  static const bannerB = Color(0xFFF8E4B8);

  // ---- mascot palette: pinned to the baked Lottie hexes ----
  static const mLeaf = Color(0xFF3FA34D);
  static const mInk = Color(0xFF33302B);
  static const mPot = Color(0xFFE8703A);
  static const mCheek = Color(0xFFF6B1B1);
  static const mSpark = Color(0xFFF5C242);
  static const mDrop = Color(0xFF4FA3E0);
  static const mBud = Color(0xFFF2A9C4);
  static const mFruit = Color(0xFFE25C4A);
  static const mWithered = Color(0xFFA6A69C);

  // ---- shape / spacing ----
  static const rSm = 12.0, rMd = 16.0, rLg = 22.0, rXl = 30.0, rFull = 999.0;
  static const s1 = 4.0, s2 = 8.0, s3 = 12.0, s4 = 16.0, s5 = 20.0, s6 = 24.0;

  /// Signature "pop" shadow: hard ink offset, collapses on press.
  static const elevPop = [
    BoxShadow(color: ink, offset: Offset(3, 3), blurRadius: 0),
  ];
  static const elevPopSm = [
    BoxShadow(color: ink, offset: Offset(2, 2), blurRadius: 0),
  ];

  static Color status(String s) => switch (s) {
        'done' => stDone,
        'actionable' => stActionable,
        'blocked' => stBlocked,
        'blocker' => stBlocker,
        'warning' => stWarning,
        'foundation' => stFoundation,
        _ => stBlocked,
      };

  // ---- type scale: chunky rounded display + friendly workhorse body ----
  static const _display = 'Baloo 2';
  static const _body = 'Nunito';
  static const display = TextStyle(fontFamily: _display, fontSize: 28, fontWeight: FontWeight.w800, color: textPrimary, height: 1.12, letterSpacing: -0.3);
  static const h2 = TextStyle(fontFamily: _display, fontSize: 21, fontWeight: FontWeight.w700, color: textPrimary);
  static const title = TextStyle(fontFamily: _body, fontSize: 17, fontWeight: FontWeight.w700, color: textPrimary);
  static const body = TextStyle(fontFamily: _body, fontSize: 15, color: textPrimary, height: 1.5);
  static const body2 = TextStyle(fontFamily: _body, fontSize: 13, color: textSecondary, height: 1.45);
  static const label = TextStyle(fontFamily: _body, fontSize: 12, fontWeight: FontWeight.w700, color: textSecondary, letterSpacing: 0.4);
  static const overline = TextStyle(fontFamily: _body, fontSize: 10, fontWeight: FontWeight.w800, color: textSecondary, letterSpacing: 1.5);
}

/// The living canvas: flat milky cream + sparse warm paper grain.
/// (Flat colour only — no gradient washes.)
class AuroraBackground extends StatelessWidget {
  const AuroraBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Aurora.bg),
      child: CustomPaint(painter: _GrainPainter(), child: child),
    );
  }
}

class _GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // sparse paper speckle on cream — texture, not a gradient
    final rnd = math.Random(7);
    final dot = Paint();
    final count = (size.width * size.height / 900).clamp(0, 4000).toInt();
    for (var i = 0; i < count; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final a = rnd.nextDouble();
      if (a < 0.72) continue; // sparse
      dot.color = const Color(0xFF4A5244).withValues(alpha: (a - 0.72) * 0.16);
      canvas.drawCircle(Offset(x, y), 0.6, dot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

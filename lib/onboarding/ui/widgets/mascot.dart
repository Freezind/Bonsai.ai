import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// The mascot moods shipped as Lottie files (assets/lottie/bonsai-*.json).
enum MascotMood { idle, cheer, thirsty, sleep }

/// The bonsai mascot: a looping Lottie, falling back to a leaf glyph if the
/// asset can't render (tests / stripped builds). Never an emoji.
class Mascot extends StatelessWidget {
  const Mascot({super.key, this.mood = MascotMood.idle, this.size = 180});
  final MascotMood mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        'assets/lottie/bonsai-${mood.name}.json',
        repeat: true,
        errorBuilder: (context, error, stack) => Icon(
          Icons.spa_outlined,
          size: size * 0.6,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

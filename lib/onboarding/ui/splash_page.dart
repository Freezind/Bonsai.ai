import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ds/matcha_tokens.dart';
import 'widgets/growing_bonsai.dart';

/// S1 · First-run brand screen. Mascot grows through its stages, brand line,
/// one CTA.
/// Not skippable; never shown again once the first goal is classified.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700))
    ..forward();
  late final Animation<double> _fade =
      CurvedAnimation(parent: _c, curve: Curves.easeOut);
  late final Animation<Offset> _rise = Tween(
    begin: const Offset(0, 0.06),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Matcha.bg,
      body: MatchaBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Matcha.s6),
            child: Column(
              children: [
                const Spacer(flex: 3),
                FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _rise,
                    child: Column(
                      children: [
                        const GrowingBonsai(size: 220),
                        const SizedBox(height: Matcha.s5),
                        Text('Bonsai',
                            style: Matcha.display.copyWith(
                                fontSize: 40, color: Matcha.primaryLight)),
                        const SizedBox(height: Matcha.s2),
                        const Text('Fed by your life, tending it back.',
                            textAlign: TextAlign.center, style: Matcha.body),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 4),
                FadeTransition(
                  opacity: CurvedAnimation(
                      parent: _c,
                      curve: const Interval(0.45, 1, curve: Curves.easeOut)),
                  child: _PlantButton(
                    onPressed: () => context.go('/seed?entry=project'),
                  ),
                ),
                const SizedBox(height: Matcha.s6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The signature contained button: primary fill, ink outline, hard pop
/// shadow that collapses on press.
class _PlantButton extends StatefulWidget {
  const _PlantButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  State<_PlantButton> createState() => _PlantButtonState();
}

class _PlantButtonState extends State<_PlantButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onPressed();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        transform: Matrix4.translationValues(_down ? 2 : 0, _down ? 2 : 0, 0),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Matcha.primary,
          border: Border.all(color: Matcha.ink, width: 2),
          borderRadius: BorderRadius.circular(Matcha.rFull),
          boxShadow: _down ? Matcha.elevPopSm : Matcha.elevPop,
        ),
        child: const Center(
          child: Text(
            'Plant your first seed',
            style: TextStyle(
              fontFamily: 'Baloo 2',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Matcha.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

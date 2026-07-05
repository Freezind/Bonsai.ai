import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ds/aurora_tokens.dart';
import '../../goals/goal.dart';
import 'widgets/mascot.dart';

/// S3 · Growth loading. Full-screen mascot + microcopy carousel while the
/// goal's dashboard is generated. Real duration, no fake progress bar.
///
/// This phase fakes the generation with a short timer; the bridge fetch
/// replaces [_grow] when the rfw layer lands.
class GrowingPage extends StatefulWidget {
  const GrowingPage({super.key, required this.goal});
  final Goal goal;

  static const microcopy = [
    'Growing your interface…',
    'Composed from Bonsai primitives — structure, never code',
    'Almost there. Good things grow slow.',
  ];

  @override
  State<GrowingPage> createState() => _GrowingPageState();
}

class _GrowingPageState extends State<GrowingPage> {
  Timer? _carousel;
  int _line = 0;

  @override
  void initState() {
    super.initState();
    _carousel = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        setState(() => _line = (_line + 1) % GrowingPage.microcopy.length);
      }
    });
    _grow();
  }

  /// Placeholder generation: a fixed wait, then reveal on the goal's tab.
  Future<void> _grow() async {
    await Future<void>.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    final tabPath = widget.goal.kind == GoalKind.area ? '/areas' : '/projects';
    // Reveal target becomes the goal's own dashboard once the rfw layer
    // lands; until then the tab root stands in.
    context.go(tabPath);
  }

  @override
  void dispose() {
    _carousel?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Aurora.bg,
        body: AuroraBackground(
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                const Mascot(size: 220),
                const SizedBox(height: Aurora.s5),
                Text(widget.goal.title,
                    textAlign: TextAlign.center,
                    style: Aurora.h2.copyWith(color: Aurora.primaryLight)),
                const SizedBox(height: Aurora.s5),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    GrowingPage.microcopy[_line],
                    key: ValueKey(_line),
                    textAlign: TextAlign.center,
                    style: Aurora.body2,
                  ),
                ),
                const Spacer(flex: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

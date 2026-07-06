import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ds/matcha_tokens.dart';
import '../../goals/goal.dart';
import '../../screens/screen_store.dart';
import 'widgets/mascot.dart';

/// S3 · Growth loading. Full-screen mascot + microcopy carousel while the
/// goal's dashboard is generated for real through the bridge. Real duration,
/// no fake progress bar; a hard 90s cap so the flow always completes — the
/// dashboard page keeps tending a goal that isn't ready yet.
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

  /// Generate the dashboard through the bridge (three-layer cache + in-flight
  /// dedupe behind it), then reveal the goal's own page. On failure or after
  /// the 90s cap the reveal STILL happens — the dashboard page shows the
  /// Still-growing state and keeps retrying; the bridge's dedupe means those
  /// retries JOIN a still-running generation rather than restart it.
  Future<void> _grow() async {
    final goal = widget.goal;
    try {
      await ScreenStore.instance
          .fetch(goal.intent, kind: 'reveal', spec: goal.spec, leaf: true)
          .timeout(const Duration(seconds: 90));
    } on Object catch (e) {
      debugPrint('grow> not ready yet: $e');
    }
    if (!mounted) return;
    final tabPath = goal.kind == GoalKind.area ? '/areas' : '/projects';
    context.go('$tabPath/goal/${goal.slug}');
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
        backgroundColor: Matcha.bg,
        body: MatchaBackground(
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                const Mascot(size: 220),
                const SizedBox(height: Matcha.s5),
                Text(widget.goal.title,
                    textAlign: TextAlign.center,
                    style: Matcha.h2.copyWith(color: Matcha.primaryLight)),
                const SizedBox(height: Matcha.s5),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    GrowingPage.microcopy[_line],
                    key: ValueKey(_line),
                    textAlign: TextAlign.center,
                    style: Matcha.body2,
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

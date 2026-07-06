import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rfw/rfw.dart';

import '../ds/matcha_tokens.dart';
import '../onboarding/ui/widgets/growing_bonsai.dart';
import '../onboarding/ui/widgets/mascot.dart';
import '../rfw_pool/demo_dashboards.dart';
import '../rfw_pool/pool_runtime.dart';
import '../screens/screen_store.dart';
import '../state/app_prefs.dart';
import 'goal.dart';

/// S4 · A goal's own dashboard — the reveal landing. Renders the bridge-
/// generated rfw DSL against the frozen pool. While the DSL isn't ready
/// (generation still running / bridge down) it shows the native
/// "Still growing" state and keeps retrying quietly.
///
/// Dashboards are generated as LEAVES for now: `navigate` intents are
/// no-ops with a status line; sub-page generation arrives with the
/// main-body work.
class GoalDashboardPage extends StatefulWidget {
  const GoalDashboardPage({super.key, required this.slug});
  final String slug;

  @override
  State<GoalDashboardPage> createState() => _GoalDashboardPageState();
}

class _GoalDashboardPageState extends State<GoalDashboardPage> {
  Runtime? _runtime;
  DynamicContent? _content;
  String? _dsl;
  bool _fetching = false;

  /// Silent retry backoff while the dashboard is still growing. The bridge's
  /// in-flight dedupe means a retry JOINS a running generation, not restarts.
  static const _backoff = [
    Duration(seconds: 10),
    Duration(seconds: 30),
    Duration(seconds: 60),
    Duration(seconds: 120),
  ];
  int _retryStep = 0;
  Timer? _retry;

  Goal? get _goal {
    for (final g in AppPrefs.instance.goals.value) {
      if (g.slug == widget.slug) return g;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _retry?.cancel();
    super.dispose();
  }

  void _scheduleRetry() {
    if (_dsl != null || !mounted) return;
    final delay = _backoff[_retryStep.clamp(0, _backoff.length - 1)];
    if (_retryStep < _backoff.length) _retryStep++;
    _retry?.cancel();
    _retry = Timer(delay, () {
      if (mounted && _dsl == null) _load(kind: 'retry');
    });
  }

  Future<void> _load({String kind = 'reveal'}) async {
    final goal = _goal;
    if (goal == null || _fetching) return;
    // Fixed-frame dashboards (the pivoted product shape): render the
    // build-time template straight from the pool — no bridge, instant.
    final fixed = kDemoDashboards[goal.slug];
    if (fixed != null) {
      _apply(goal, fixed);
      return;
    }
    setState(() => _fetching = true);
    try {
      final res = await ScreenStore.instance.fetch(
        goal.intent,
        kind: kind,
        spec: goal.spec,
        leaf: true,
      );
      if (!mounted) return;
      _apply(goal, res.dsl);
      ScreenStore.instance.setStatus(
        res.latencyMs == 0
            ? 'from cache · instant'
            : 'grown in ${(res.latencyMs / 1000).toStringAsFixed(0)}s',
      );
    } on Object catch (e) {
      // Keep whatever is on screen (Still-growing state or the prior DSL)
      // and try again quietly — the metaphor holds: bonsai grow slowly.
      ScreenStore.instance.setStatus('still growing');
      debugPrint('dashboard> not ready: $e');
      _scheduleRetry();
    } finally {
      if (mounted) setState(() => _fetching = false);
    }
  }

  void _apply(Goal goal, String dsl) {
    try {
      final runtime = buildRuntime(dsl);
      setState(() {
        _runtime = runtime;
        _content = DynamicContent({
          ...ScreenStore.instance.uiData,
          // per-goal bindings: the frame is fixed, the words are the goal's
          'goal': {'title': goal.title},
        });
        _dsl = dsl;
      });
    } on Object catch (e) {
      // Parse failure NEVER blanks the screen — keep the prior state.
      ScreenStore.instance.setStatus('bad DSL kept off stage: $e');
      return;
    }
    if (goal.status != GoalStatus.ready) {
      AppPrefs.instance.updateGoal(goal.copyWith(status: GoalStatus.ready));
    }
    // The robot chat's edit scope is THIS screen.
    ScreenStore.instance.active.value = EditableScreen(
      intent: goal.intent,
      dsl: dsl,
      apply: (next) {
        final g = _goal;
        if (mounted && g != null) _apply(g, next);
      },
    );
  }

  void _onEvent(String name, DynamicMap args) {
    debugPrint('rfw event: $name $args');
    switch (name) {
      case 'navigate':
        // Leaf dashboards: nothing navigates deeper yet.
        ScreenStore.instance
            .setStatus('sub-pages sprout in a later season');
      case 'back':
        final nav = Navigator.of(context);
        if (nav.canPop()) nav.pop();
      case 'save':
        ScreenStore.instance.setStatus('saved · kept on this device');
      default:
        // State events (toggle/mood/...) flip locally inside the widget.
        ScreenStore.instance.setStatus('event "$name" · state kept on device');
    }
  }

  @override
  Widget build(BuildContext context) {
    final goal = _goal;
    if (goal == null) {
      return Center(
        child: Text('This seed is gone.', style: Matcha.body2),
      );
    }
    final page = Column(
      children: [
        _header(goal),
        const Divider(height: 1, color: Matcha.divider),
        Expanded(child: _body(goal)),
      ],
    );
    if (AppPrefs.instance.coachMarkSeen) return page;
    // One-time coach mark on the first reveal: teach the PARA tabs + "+".
    return Stack(
      children: [
        page,
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              AppPrefs.instance.markCoachMarkSeen();
              setState(() {});
            },
            child: ColoredBox(
              color: const Color(0x8826302A),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.all(Matcha.s5),
                  padding: const EdgeInsets.all(Matcha.s4),
                  decoration: BoxDecoration(
                    color: Matcha.paper2,
                    border: Border.all(color: Matcha.ink, width: 2),
                    borderRadius: BorderRadius.circular(Matcha.rMd),
                    boxShadow: Matcha.elevPop,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('This is your goal\'s home', style: Matcha.title),
                      const SizedBox(height: Matcha.s1),
                      const Text(
                        'Bottom tabs are your PARA structure — tap + anytime '
                        'to plant another seed.',
                        textAlign: TextAlign.center,
                        style: Matcha.body2,
                      ),
                      const SizedBox(height: Matcha.s2),
                      Text('Tap anywhere to start tending',
                          style: Matcha.label
                              .copyWith(color: Matcha.primaryLight)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(Goal goal) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, Matcha.s4, 2),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Matcha.textSecondary),
            onPressed: () {
              final nav = Navigator.of(context);
              if (nav.canPop()) nav.pop();
            },
          ),
          Expanded(
            child: Text(goal.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Matcha.title),
          ),
          // The goal's own tree, grown to its current stage.
          StageBonsai(stage: goal.stage, size: 40),
          const SizedBox(width: Matcha.s2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: goal.kind == GoalKind.area
                  ? Matcha.secondaryContainer
                  : Matcha.primaryContainer,
              borderRadius: BorderRadius.circular(Matcha.rFull),
            ),
            child: Text(
              goal.kind == GoalKind.area ? 'Area' : 'Project',
              style: Matcha.label.copyWith(
                color: goal.kind == GoalKind.area
                    ? Matcha.secondary
                    : Matcha.primaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(Goal goal) {
    final runtime = _runtime;
    final content = _content;
    if (runtime == null || content == null || _dsl == null) {
      return _StillGrowing(fetching: _fetching, onRetry: _load);
    }
    // Min-height viewport + IntrinsicHeight so flex children in the DSL
    // (Gap -> Spacer) get bounded constraints inside the scrollable.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: RemoteWidget(
              runtime: runtime,
              data: content,
              widget: const FullyQualifiedWidgetName(mainLibrary, 'root'),
              onEvent: _onEvent,
            ),
          ),
        ),
      ),
    );
  }
}

/// Native placeholder while the dashboard is generated (or the bridge is
/// down): thirsty mascot + a quiet card. Flat Fresh Matcha, no spinner walls.
class _StillGrowing extends StatelessWidget {
  const _StillGrowing({required this.fetching, required this.onRetry});
  final bool fetching;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Mascot(mood: MascotMood.thirsty, size: 160),
          const SizedBox(height: Matcha.s4),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: Matcha.s6),
            padding: const EdgeInsets.all(Matcha.s4),
            decoration: BoxDecoration(
              color: Matcha.paper2,
              border: Border.all(color: Matcha.border, width: 2),
              borderRadius: BorderRadius.circular(Matcha.rMd),
            ),
            child: Column(
              children: [
                Text('Still growing', style: Matcha.title),
                const SizedBox(height: Matcha.s1),
                const Text('Check back in a moment.',
                    textAlign: TextAlign.center, style: Matcha.body2),
              ],
            ),
          ),
          const SizedBox(height: Matcha.s4),
          if (fetching)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: Matcha.primary),
            )
          else
            TextButton(
              onPressed: onRetry,
              child: const Text('Water it again',
                  style: TextStyle(color: Matcha.primaryLight)),
            ),
        ],
      ),
    );
  }
}

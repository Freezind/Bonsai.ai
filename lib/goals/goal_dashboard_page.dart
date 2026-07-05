import 'package:flutter/material.dart';
import 'package:rfw/rfw.dart';

import '../ds/aurora_tokens.dart';
import '../onboarding/ui/widgets/mascot.dart';
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

  Future<void> _load() async {
    final goal = _goal;
    if (goal == null || _fetching) return;
    setState(() => _fetching = true);
    try {
      final res = await ScreenStore.instance.fetch(
        goal.intent,
        kind: 'reveal',
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
      // Keep whatever is on screen (Still-growing state or the prior DSL).
      ScreenStore.instance.setStatus('still growing · $e');
    } finally {
      if (mounted) setState(() => _fetching = false);
    }
  }

  void _apply(Goal goal, String dsl) {
    try {
      final runtime = buildRuntime(dsl);
      setState(() {
        _runtime = runtime;
        _content = DynamicContent(ScreenStore.instance.uiData);
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
        child: Text('This seed is gone.', style: Aurora.body2),
      );
    }
    return Column(
      children: [
        _header(goal),
        const Divider(height: 1, color: Aurora.divider),
        Expanded(child: _body(goal)),
      ],
    );
  }

  Widget _header(Goal goal) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, Aurora.s4, 2),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Aurora.textSecondary),
            onPressed: () {
              final nav = Navigator.of(context);
              if (nav.canPop()) nav.pop();
            },
          ),
          Expanded(
            child: Text(goal.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Aurora.title),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: goal.kind == GoalKind.area
                  ? Aurora.secondaryContainer
                  : Aurora.primaryContainer,
              borderRadius: BorderRadius.circular(Aurora.rFull),
            ),
            child: Text(
              goal.kind == GoalKind.area ? 'Area' : 'Project',
              style: Aurora.label.copyWith(
                color: goal.kind == GoalKind.area
                    ? Aurora.secondary
                    : Aurora.primaryLight,
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
          const SizedBox(height: Aurora.s4),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: Aurora.s6),
            padding: const EdgeInsets.all(Aurora.s4),
            decoration: BoxDecoration(
              color: Aurora.paper2,
              border: Border.all(color: Aurora.border, width: 2),
              borderRadius: BorderRadius.circular(Aurora.rMd),
            ),
            child: Column(
              children: [
                Text('Still growing', style: Aurora.title),
                const SizedBox(height: Aurora.s1),
                const Text('Check back in a moment.',
                    textAlign: TextAlign.center, style: Aurora.body2),
              ],
            ),
          ),
          const SizedBox(height: Aurora.s4),
          if (fetching)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: Aurora.primary),
            )
          else
            TextButton(
              onPressed: onRetry,
              child: const Text('Water it again',
                  style: TextStyle(color: Aurora.primaryLight)),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ds/matcha_tokens.dart';
import '../goals/goal.dart';
import '../onboarding/ui/widgets/growing_bonsai.dart';
import '../state/app_prefs.dart';
import '../state/demo_scenario.dart';

/// Home = the periodic-note digest: the gardener's weekly report at the top,
/// then one highlight row per project with its grown tree trailing. This is
/// the timeline-comparison screen of the demo:
///
///  · Day 1  — nothing planted: the pot sits quiet and asks for seeds; the
///             digest stays locked until the garden has grown.
///  · Day 90 — a full digest (fake scenario data), trees in later stages
///             with happier faces.
///
/// Native Dart, no DSL. LONG-PRESS the header to flip Day 1 ⟷ Day 90 for
/// screen recording.
class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  /// The Day-1 registry, stashed while the Day-90 world is on stage so the
  /// timeline can flip back and forth without losing the planted seed.
  static List<Goal>? _day1Stash;

  Future<void> _toggleTimeline() {
    final prefs = AppPrefs.instance;
    final toDay90 = !prefs.demoDay90.value;
    if (toDay90) {
      _day1Stash = prefs.goals.value;
      return prefs.applyScenario(
        day90: true,
        // Carry the planted project's title into the Day-90 world.
        scenarioGoals: DemoScenario.day90For(prefs.goals.value),
      );
    }
    return prefs.applyScenario(
      day90: false,
      scenarioGoals: _day1Stash ?? const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MatchaBackground(
      child: ValueListenableBuilder<bool>(
        valueListenable: AppPrefs.instance.demoDay90,
        builder: (context, day90, _) => ValueListenableBuilder<List<Goal>>(
          valueListenable: AppPrefs.instance.goals,
          builder: (context, goals, _) {
            final projects =
                [for (final g in goals) if (g.kind == GoalKind.project) g];
            final rich = day90 && projects.isNotEmpty;
            return GestureDetector(
              // The recording switch: long-press anywhere on the screen.
              onLongPress: _toggleTimeline,
              behavior: HitTestBehavior.opaque,
              child: rich
                  ? _Digest(projects: projects, goals: goals)
                  : _SleepingGarden(planted: goals.length),
            );
          },
        ),
      ),
    );
  }
}

/// Day 1 · the garden hasn't earned a digest yet.
class _SleepingGarden extends StatelessWidget {
  const _SleepingGarden({required this.planted});
  final int planted;

  static const _unlockAt = 2;

  @override
  Widget build(BuildContext context) {
    final remaining = (_unlockAt - planted).clamp(0, _unlockAt);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Matcha.s6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Still just a pot — stage 0, patiently waiting.
            const StageBonsai(stage: 0, size: 180),
            const SizedBox(height: Matcha.s4),
            Text('Your garden sleeps', style: Matcha.h2),
            const SizedBox(height: Matcha.s2),
            const Text(
              'Plant seeds and tend them — your gardener writes a weekly '
              'report here once there is something growing.',
              textAlign: TextAlign.center,
              style: Matcha.body2,
            ),
            const SizedBox(height: Matcha.s4),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Matcha.s4, vertical: Matcha.s2),
              decoration: BoxDecoration(
                color: Matcha.paper2,
                border: Border.all(color: Matcha.border, width: 2),
                borderRadius: BorderRadius.circular(Matcha.rFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline,
                      size: 16, color: Matcha.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    remaining == 0
                        ? 'Digest unlocks with this week\'s tending'
                        : 'Plant $remaining more seed${remaining == 1 ? '' : 's'} to unlock',
                    style: Matcha.label,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Day 90 · the full periodic-note digest.
class _Digest extends StatelessWidget {
  const _Digest({required this.projects, required this.goals});
  final List<Goal> projects;
  final List<Goal> goals;

  Goal? _area(String? slug) {
    if (slug == null) return null;
    for (final g in goals) {
      if (g.slug == slug) return g;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          Matcha.s4, Matcha.s3, Matcha.s4, Matcha.s6 * 2),
      children: [
        // ---- header ----
        Text(DemoScenario.digestOverline, style: Matcha.overline),
        const SizedBox(height: 6),
        Text(DemoScenario.digestTitle, style: Matcha.display),
        const SizedBox(height: Matcha.s4),

        // ---- while you slept (the AI's overnight note + one decision) ----
        Container(
          padding: const EdgeInsets.all(Matcha.s4),
          decoration: BoxDecoration(
            color: Matcha.paper2,
            border: Border.all(color: Matcha.ink, width: 2),
            borderRadius: BorderRadius.circular(Matcha.rMd),
            boxShadow: Matcha.elevPopSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.auto_awesome,
                    size: 18, color: Matcha.stWarning),
                const SizedBox(width: 8),
                Text(DemoScenario.overnightTitle, style: Matcha.title),
              ]),
              const SizedBox(height: Matcha.s2),
              const Text(DemoScenario.overnightBody, style: Matcha.body),
              const SizedBox(height: Matcha.s3),
              Row(children: [
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: Matcha.primary,
                    foregroundColor: Matcha.onPrimary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: Matcha.s4),
                  ),
                  child: const Text(DemoScenario.decisionPrimary),
                ),
                const SizedBox(width: Matcha.s2),
                TextButton(
                  onPressed: () {},
                  child: Text(DemoScenario.decisionSecondary,
                      style: const TextStyle(color: Matcha.textSecondary)),
                ),
              ]),
            ],
          ),
        ),
        const SizedBox(height: Matcha.s5),

        // ---- this week's numbers ----
        Text('THIS WEEK · JOB HUNT', style: Matcha.overline),
        const SizedBox(height: Matcha.s2),
        Row(children: [
          for (final (label, value, delta) in DemoScenario.weekStats) ...[
            Expanded(child: _StatTile(label: label, value: value, delta: delta)),
            if (label != DemoScenario.weekStats.last.$1)
              const SizedBox(width: Matcha.s2),
          ],
        ]),
        const SizedBox(height: Matcha.s5),

        // ---- project highlights, each with its grown tree ----
        Text('PROJECT HIGHLIGHTS', style: Matcha.overline),
        const SizedBox(height: Matcha.s2),
        for (final p in projects) _HighlightRow(project: p, area: _area(p.parentArea)),

        const SizedBox(height: Matcha.s3),

        // ---- health watch-out ----
        Container(
          padding: const EdgeInsets.all(Matcha.s3),
          decoration: BoxDecoration(
            color: const Color(0xFFF8E4B8), // warning container
            border: Border.all(color: Matcha.ink, width: 2),
            borderRadius: BorderRadius.circular(Matcha.rMd),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.bedtime_outlined,
                  size: 20, color: Matcha.stWarning),
              const SizedBox(width: Matcha.s2),
              Expanded(
                child: Text(DemoScenario.healthNote,
                    style: Matcha.body2
                        .copyWith(color: const Color(0xFF4A3300))),
              ),
            ],
          ),
        ),
        const SizedBox(height: Matcha.s4),
        Center(child: Text(DemoScenario.footer, style: Matcha.label)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.delta});
  final String label;
  final String value;
  final String delta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Matcha.s3),
      decoration: BoxDecoration(
        color: Matcha.paper2,
        border: Border.all(color: Matcha.border, width: 2),
        borderRadius: BorderRadius.circular(Matcha.rMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Matcha.label),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: Matcha.h2.copyWith(color: Matcha.primaryLight)),
              const SizedBox(width: 4),
              Text(delta,
                  style: Matcha.label.copyWith(color: Matcha.stDone)),
            ],
          ),
        ],
      ),
    );
  }
}

/// One project's weekly highlight; the trailing tree shows how far it has
/// grown (later stages carry happier faces). Tapping opens the goal.
class _HighlightRow extends StatelessWidget {
  const _HighlightRow({required this.project, this.area});
  final Goal project;
  final Goal? area;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/projects/goal/${project.slug}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: Matcha.s3),
        padding: const EdgeInsets.all(Matcha.s3),
        decoration: BoxDecoration(
          color: Matcha.paper2,
          border: Border.all(color: Matcha.ink, width: 2),
          borderRadius: BorderRadius.circular(Matcha.rMd),
          boxShadow: Matcha.elevPopSm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(project.title, style: Matcha.title),
                  const SizedBox(height: 3),
                  Text(project.highlight, style: Matcha.body2),
                  if (area != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Matcha.accentTint,
                        borderRadius: BorderRadius.circular(Matcha.rFull),
                      ),
                      child: Text('A · ${area!.title}',
                          style: Matcha.label
                              .copyWith(color: Matcha.primaryLight)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: Matcha.s2),
            // The tree this project has grown into.
            StageBonsai(stage: project.stage, size: 64),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ds/aurora_tokens.dart';
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

  Future<void> _toggleTimeline() {
    final prefs = AppPrefs.instance;
    final toDay90 = !prefs.demoDay90.value;
    return prefs.applyScenario(
      day90: toDay90,
      scenarioGoals: toDay90 ? DemoScenario.day90Goals : const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuroraBackground(
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
        padding: const EdgeInsets.symmetric(horizontal: Aurora.s6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Still just a pot — stage 0, patiently waiting.
            const StageBonsai(stage: 0, size: 180),
            const SizedBox(height: Aurora.s4),
            Text('Your garden sleeps', style: Aurora.h2),
            const SizedBox(height: Aurora.s2),
            const Text(
              'Plant seeds and tend them — your gardener writes a weekly '
              'report here once there is something growing.',
              textAlign: TextAlign.center,
              style: Aurora.body2,
            ),
            const SizedBox(height: Aurora.s4),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Aurora.s4, vertical: Aurora.s2),
              decoration: BoxDecoration(
                color: Aurora.paper2,
                border: Border.all(color: Aurora.border, width: 2),
                borderRadius: BorderRadius.circular(Aurora.rFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline,
                      size: 16, color: Aurora.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    remaining == 0
                        ? 'Digest unlocks with this week\'s tending'
                        : 'Plant $remaining more seed${remaining == 1 ? '' : 's'} to unlock',
                    style: Aurora.label,
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
          Aurora.s4, Aurora.s3, Aurora.s4, Aurora.s6 * 2),
      children: [
        // ---- header ----
        Text(DemoScenario.digestOverline, style: Aurora.overline),
        const SizedBox(height: 6),
        Text(DemoScenario.digestTitle, style: Aurora.display),
        const SizedBox(height: Aurora.s4),

        // ---- while you slept (the AI's overnight note + one decision) ----
        Container(
          padding: const EdgeInsets.all(Aurora.s4),
          decoration: BoxDecoration(
            color: Aurora.paper2,
            border: Border.all(color: Aurora.ink, width: 2),
            borderRadius: BorderRadius.circular(Aurora.rMd),
            boxShadow: Aurora.elevPopSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.auto_awesome,
                    size: 18, color: Aurora.stWarning),
                const SizedBox(width: 8),
                Text(DemoScenario.overnightTitle, style: Aurora.title),
              ]),
              const SizedBox(height: Aurora.s2),
              const Text(DemoScenario.overnightBody, style: Aurora.body),
              const SizedBox(height: Aurora.s3),
              Row(children: [
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: Aurora.primary,
                    foregroundColor: Aurora.onPrimary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: Aurora.s4),
                  ),
                  child: const Text(DemoScenario.decisionPrimary),
                ),
                const SizedBox(width: Aurora.s2),
                TextButton(
                  onPressed: () {},
                  child: Text(DemoScenario.decisionSecondary,
                      style: const TextStyle(color: Aurora.textSecondary)),
                ),
              ]),
            ],
          ),
        ),
        const SizedBox(height: Aurora.s5),

        // ---- this week's numbers ----
        Text('THIS WEEK · JOB HUNT', style: Aurora.overline),
        const SizedBox(height: Aurora.s2),
        Row(children: [
          for (final (label, value, delta) in DemoScenario.weekStats) ...[
            Expanded(child: _StatTile(label: label, value: value, delta: delta)),
            if (label != DemoScenario.weekStats.last.$1)
              const SizedBox(width: Aurora.s2),
          ],
        ]),
        const SizedBox(height: Aurora.s5),

        // ---- project highlights, each with its grown tree ----
        Text('PROJECT HIGHLIGHTS', style: Aurora.overline),
        const SizedBox(height: Aurora.s2),
        for (final p in projects) _HighlightRow(project: p, area: _area(p.parentArea)),

        const SizedBox(height: Aurora.s3),

        // ---- health watch-out ----
        Container(
          padding: const EdgeInsets.all(Aurora.s3),
          decoration: BoxDecoration(
            color: const Color(0xFFF8E4B8), // warning container
            border: Border.all(color: Aurora.ink, width: 2),
            borderRadius: BorderRadius.circular(Aurora.rMd),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.bedtime_outlined,
                  size: 20, color: Aurora.stWarning),
              const SizedBox(width: Aurora.s2),
              Expanded(
                child: Text(DemoScenario.healthNote,
                    style: Aurora.body2
                        .copyWith(color: const Color(0xFF4A3300))),
              ),
            ],
          ),
        ),
        const SizedBox(height: Aurora.s4),
        Center(child: Text(DemoScenario.footer, style: Aurora.label)),
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
      padding: const EdgeInsets.all(Aurora.s3),
      decoration: BoxDecoration(
        color: Aurora.paper2,
        border: Border.all(color: Aurora.border, width: 2),
        borderRadius: BorderRadius.circular(Aurora.rMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Aurora.label),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: Aurora.h2.copyWith(color: Aurora.primaryLight)),
              const SizedBox(width: 4),
              Text(delta,
                  style: Aurora.label.copyWith(color: Aurora.stDone)),
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
        margin: const EdgeInsets.only(bottom: Aurora.s3),
        padding: const EdgeInsets.all(Aurora.s3),
        decoration: BoxDecoration(
          color: Aurora.paper2,
          border: Border.all(color: Aurora.ink, width: 2),
          borderRadius: BorderRadius.circular(Aurora.rMd),
          boxShadow: Aurora.elevPopSm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(project.title, style: Aurora.title),
                  const SizedBox(height: 3),
                  Text(project.highlight, style: Aurora.body2),
                  if (area != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Aurora.accentTint,
                        borderRadius: BorderRadius.circular(Aurora.rFull),
                      ),
                      child: Text('A · ${area!.title}',
                          style: Aurora.label
                              .copyWith(color: Aurora.primaryLight)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: Aurora.s2),
            // The tree this project has grown into.
            StageBonsai(stage: project.stage, size: 64),
          ],
        ),
      ),
    );
  }
}

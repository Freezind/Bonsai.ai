import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ds/aurora_tokens.dart';
import '../goals/goal.dart';
import '../onboarding/ui/widgets/growing_bonsai.dart';
import '../onboarding/ui/widgets/mascot.dart';
import 'home_tab_page.dart';
import 'resources_page.dart';
import '../state/app_prefs.dart';
import 'router.dart';

/// Native tab root. Projects/Areas list their planted goals and carry the
/// "+ seed" entry (same conversation, splash skipped); Home/Archive stay
/// quiet until the main-body work; Resources shows the connector inlets.
class TabRootPage extends StatelessWidget {
  const TabRootPage({super.key, required this.tab});
  final AppTab tab;

  bool get _plantable => tab == AppTab.projects || tab == AppTab.areas;

  GoalKind get _kind =>
      tab == AppTab.areas ? GoalKind.area : GoalKind.project;

  @override
  Widget build(BuildContext context) {
    if (tab == AppTab.home) return const HomeTabPage();
    if (tab == AppTab.resources) return const ResourcesPage();
    if (!_plantable) return _QuietRoot(tab: tab);

    return AuroraBackground(
      child: ValueListenableBuilder<List<Goal>>(
        valueListenable: AppPrefs.instance.goals,
        builder: (context, goals, _) {
          final mine = [for (final g in goals) if (g.kind == _kind) g];
          return Stack(
            children: [
              if (mine.isEmpty)
                _EmptyBed(tab: tab)
              else
                ListView(
                  padding: const EdgeInsets.fromLTRB(
                      Aurora.s4, Aurora.s4, Aurora.s4, 96),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: Aurora.s1, bottom: Aurora.s3),
                      child: Text(
                        tab == AppTab.areas
                            ? 'AREAS YOU TEND'
                            : 'PROJECTS IN FLIGHT',
                        style: Aurora.overline,
                      ),
                    ),
                    for (final g in mine) _GoalCard(goal: g, tab: tab),
                  ],
                ),
              // "+ seed": re-enters the SAME conversation, splash skipped.
              Positioned(
                right: Aurora.s4,
                bottom: Aurora.s4,
                child: _SeedFab(
                  onPressed: () =>
                      context.go('/seed?entry=${_kind.name}'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.tab});
  final Goal goal;
  final AppTab tab;

  @override
  Widget build(BuildContext context) {
    final growing = goal.status == GoalStatus.growing;
    return GestureDetector(
      onTap: () => context.go('${tab.path}/goal/${goal.slug}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: Aurora.s3),
        padding: const EdgeInsets.all(Aurora.s4),
        decoration: BoxDecoration(
          color: Aurora.paper2,
          border: Border.all(color: Aurora.ink, width: 2),
          borderRadius: BorderRadius.circular(Aurora.rMd),
          boxShadow: Aurora.elevPopSm,
        ),
        child: Row(
          children: [
            if (growing)
              const Mascot(mood: MascotMood.thirsty, size: 44)
            else
              StageBonsai(stage: goal.stage, size: 48),
            const SizedBox(width: Aurora.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(goal.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Aurora.title),
                  const SizedBox(height: 2),
                  Text(
                    growing ? 'Still growing…' : 'Ready to tend',
                    style: Aurora.body2.copyWith(
                      color: growing
                          ? Aurora.stWarning
                          : Aurora.primaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Aurora.textDisabled),
          ],
        ),
      ),
    );
  }
}

/// The signature extended FAB: secondary fill, ink outline, pop shadow.
class _SeedFab extends StatelessWidget {
  const _SeedFab({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: Aurora.s5),
        decoration: BoxDecoration(
          color: Aurora.secondary,
          border: Border.all(color: Aurora.ink, width: 2),
          borderRadius: BorderRadius.circular(Aurora.rFull),
          boxShadow: Aurora.elevPop,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Aurora.onSecondary),
            SizedBox(width: 6),
            Text('seed',
                style: TextStyle(
                  fontFamily: 'Baloo 2',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Aurora.onSecondary,
                )),
          ],
        ),
      ),
    );
  }
}

class _EmptyBed extends StatelessWidget {
  const _EmptyBed({required this.tab});
  final AppTab tab;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Mascot(mood: MascotMood.sleep, size: 140),
          const SizedBox(height: Aurora.s3),
          Text('Nothing planted here yet.', style: Aurora.body2),
          const SizedBox(height: Aurora.s1),
          Text(
            tab == AppTab.areas
                ? 'Plant a part of life you want to tend.'
                : 'Plant something you\'re working toward.',
            style: Aurora.body2.copyWith(color: Aurora.textDisabled),
          ),
        ],
      ),
    );
  }
}

class _QuietRoot extends StatelessWidget {
  const _QuietRoot({required this.tab});
  final AppTab tab;

  @override
  Widget build(BuildContext context) {
    return AuroraBackground(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(tab.icon, size: 44, color: Aurora.textDisabled),
            const SizedBox(height: Aurora.s3),
            Text(tab.label, style: Aurora.h2),
            const SizedBox(height: Aurora.s2),
            Text('This bed is still being prepared.', style: Aurora.body2),
          ],
        ),
      ),
    );
  }
}

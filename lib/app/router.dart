import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

import '../goals/goal.dart';
import '../onboarding/seed_flow_state.dart';
import '../onboarding/ui/conversation_page.dart';
import '../onboarding/ui/growing_page.dart';
import '../onboarding/ui/splash_page.dart';
import '../state/app_prefs.dart';
import 'shell_scaffold.dart';
import 'tab_root_page.dart';

/// The bottom tabs — PEERS at depth 0. Only sub-pages accumulate depth;
/// switching tabs resets the active branch to its root.
/// Type-safe: every tab is an enum value carrying its path + route name.
enum AppTab {
  home('Home', '/home', 'dashboard', Icons.home_outlined),
  projects('Projects', '/projects', 'projects', Icons.layers_outlined),
  areas('Areas', '/areas', 'areas', Icons.category_outlined),
  resources('Resources', '/resources', 'resources', Icons.menu_book_outlined),
  archive('Archive', '/archive', 'archive', Icons.inventory_2_outlined);

  const AppTab(this.label, this.path, this.route, this.icon);
  final String label;
  final String path;
  final String route; // logical route name (used by generated screens later)
  final IconData icon;
}

/// Logical route name -> tab (tab switch, NOT a push).
final Map<String, AppTab> kTabForRoute = {
  for (final t in AppTab.values) t.route: t,
};

/// The app is a CLOSED, finite artifact: at most this many levels of
/// sub-pages under a tab root. Depth-[kMaxDepth] screens are LEAVES — fully
/// interactive but nothing navigates deeper. The cap is enforced ON DEVICE.
const int kMaxDepth = 3;

/// Typed arguments for a pushed sub-page. [depth] is the page's own depth.
class SubPageArgs {
  const SubPageArgs.intent(String i, {required this.depth}) : intent = i;
  final String intent;
  final int depth;
}

/// Set by the shell builder; used to switch branches programmatically.
late StatefulNavigationShell appShell;

/// Per-tab pop-stack depth (0 = tab root). Tabs are peers and never count.
final List<ValueNotifier<int>> tabDepth = [
  for (final _ in AppTab.values) ValueNotifier<int>(0),
];

class DepthObserver extends NavigatorObserver {
  DepthObserver(this.index);
  final int index;
  int _count = 0;

  /// Navigator mutations can happen mid-frame; notify listeners frame-safely.
  void _publish() {
    final v = (_count - 1).clamp(0, 99);
    final scheduler = SchedulerBinding.instance;
    if (scheduler.schedulerPhase == SchedulerPhase.idle) {
      tabDepth[index].value = v;
    } else {
      scheduler.addPostFrameCallback((_) => tabDepth[index].value = v);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _count++;
    _publish();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _count--;
    _publish();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _count--;
    _publish();
  }
}

AppTab currentTab() => AppTab.values[appShell.currentIndex];

/// Built per app instance (tests get a fresh router each pump).
GoRouter createAppRouter() => GoRouter(
      initialLocation: AppTab.home.path,
      // First-run gate: until the first goal is classified, everything
      // funnels to the splash. The flag flips exactly once; in-flow
      // transitions are explicit context.go calls, so no refreshListenable.
      redirect: (context, state) {
        final p = state.uri.path;
        final inFlow = p.startsWith('/onboarding') || p.startsWith('/seed');
        if (!AppPrefs.instance.firstRunComplete && !inFlow) {
          return '/onboarding/splash';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/onboarding/splash',
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/seed',
          name: 'seed',
          builder: (context, state) => ConversationPage(
            entry: state.uri.queryParameters['entry'] == 'area'
                ? SeedEntry.area
                : SeedEntry.project,
          ),
          routes: [
            GoRoute(
              path: 'growing',
              name: 'growing',
              builder: (context, state) =>
                  GrowingPage(goal: state.extra! as Goal),
            ),
          ],
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) {
            appShell = shell;
            return ShellScaffold(shell: shell);
          },
          branches: [
            for (final tab in AppTab.values)
              StatefulShellBranch(
                observers: [DepthObserver(tab.index)],
                routes: [
                  GoRoute(
                    path: tab.path,
                    name: tab.name,
                    builder: (context, state) => TabRootPage(tab: tab),
                  ),
                ],
              ),
          ],
        ),
      ],
    );

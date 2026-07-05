import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:bonsai/app/router.dart';
import 'package:bonsai/goals/goal.dart';
import 'package:bonsai/main.dart';
import 'package:bonsai/onboarding/seed_flow_controller.dart';
import 'package:bonsai/rfw_pool/pool_runtime.dart';
import 'package:bonsai/screens/screen_store.dart';
import 'package:bonsai/state/app_prefs.dart';

/// A dashboard the bridge could have produced: pool widgets only.
const String kTestDashboardDsl = '''
import core.widgets;
import bonsai.widgets;

widget root = Canvas(
  child: Column(
    crossAxisAlignment: "stretch",
    children: [
      AppBar(large: true, overline: "P · PROJECT", title: "Job hunt"),
      Padding(
        padding: [16.0, 0.0, 16.0, 16.0],
        child: Column(
          crossAxisAlignment: "stretch",
          children: [
            Card(child: Txt(style: "body2", text: "Interview pipeline is warming up.")),
            SizedBox(height: 12.0),
            CheckItem(label: "Polish my portfolio"),
          ],
        ),
      ),
    ],
  ),
);
''';

void main() {
  setUp(() {
    // Fresh in-memory state per test (no disk in the test environment).
    AppPrefs.instance.firstRunComplete = false;
    AppPrefs.instance.coachMarkSeen = false;
    AppPrefs.instance.goals.value = const [];
    ScreenStore.instance.cache.clear();
    ScreenStore.instance.active.value = null;
    // Real network cannot complete under the test fake clock — force the
    // scripted spine + offline fetch (also the bridge-down behavior).
    SeedFlowController.disableLive = true;
    ScreenStore.offlineForTests = true;
  });

  test('the frozen pool parses a generated dashboard', () {
    expect(buildRuntime(kTestDashboardDsl), isNotNull);
  });

  testWidgets('first run: splash -> conversation -> reveal renders the DSL',
      (tester) async {
    // The dashboard was "generated" already (bridge cache warm).
    ScreenStore.instance.cache['goal:finding-a-staff-engineer-job'] =
        kTestDashboardDsl;

    await tester.pumpWidget(const BonsaiApp());
    await tester.pump(const Duration(milliseconds: 900));

    // S1 · splash gates everything on first run.
    expect(find.text('Apps you tend, not apps you build.'), findsOneWidget);
    await tester.tap(find.text('Plant your first seed'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));

    // S2 · opening question (project framing on first run).
    expect(find.text("What's something you're working toward right now?"),
        findsOneWidget);

    Future<void> answer(String text) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 1400));
    }

    await answer('Finding a staff engineer job');
    expect(find.text("What does 'done' look like for it?"), findsOneWidget);
    await answer('A signed offer');
    expect(find.text("What's the very next step you could take?"),
        findsOneWidget);
    await answer('Polish my portfolio');

    // Classification disclosed; goal persisted atomically with its spec.
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pump();
    expect(find.textContaining('is a Project'), findsOneWidget);
    expect(AppPrefs.instance.firstRunComplete, isTrue);
    final goal = AppPrefs.instance.goals.value.single;
    expect(goal.kind, GoalKind.project);
    expect(goal.slug, 'finding-a-staff-engineer-job');
    expect(goal.spec, contains('Polish my portfolio'));

    // S3/S4 · growing fetch hits the warm cache -> reveal renders the DSL.
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Interview pipeline is warming up.'), findsOneWidget);
    expect(find.text('Polish my portfolio'), findsOneWidget);
    // Goal flipped to ready and became the robot's edit scope.
    expect(AppPrefs.instance.goals.value.single.status, GoalStatus.ready);
    expect(ScreenStore.instance.active.value?.intent,
        'goal:finding-a-staff-engineer-job');
  });

  testWidgets('completed first run boots straight into the 5-tab shell',
      (tester) async {
    AppPrefs.instance.firstRunComplete = true;
    await tester.pumpWidget(const BonsaiApp());
    await tester.pumpAndSettle();

    for (final tab in AppTab.values) {
      expect(find.text(tab.label), findsWidgets);
    }
    await tester.tap(find.text('Areas').last);
    await tester.pumpAndSettle();
    expect(find.text('Nothing planted here yet.'), findsOneWidget);
    expect(tabDepth[AppTab.areas.index].value, 0);
  });

  testWidgets('area entry: generation unavailable still reveals, as growing',
      (tester) async {
    AppPrefs.instance.firstRunComplete = true;
    await tester.pumpWidget(const BonsaiApp());
    await tester.pumpAndSettle();

    // Deep-enter the seed flow with the area branch (the "+ seed" path).
    final ctx = tester.element(find.text('Home').last);
    ctx.go('/seed?entry=area');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
        find.text(
            "What's a part of your life you want to tend for the long run?"),
        findsOneWidget);

    Future<void> answer(String text) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 1400));
    }

    await answer('Staying healthy');
    await answer('Moving every day');
    await answer('Late nights');
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pump();
    expect(find.textContaining('is an Area'), findsOneWidget);
    expect(AppPrefs.instance.goals.value.single.kind, GoalKind.area);

    // No cache, bridge "down": the reveal still happens — the dashboard
    // tends a growing goal instead of blocking the flow.
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Still growing'), findsOneWidget);
    expect(find.text('Staying healthy'), findsOneWidget); // header title
    expect(AppPrefs.instance.goals.value.single.status, GoalStatus.growing);
  });
}

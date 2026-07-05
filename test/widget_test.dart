import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:bonsai/app/router.dart';
import 'package:bonsai/goals/goal.dart';
import 'package:bonsai/main.dart';
import 'package:bonsai/onboarding/seed_flow_controller.dart';
import 'package:bonsai/state/app_prefs.dart';

void main() {
  setUp(() {
    // Fresh in-memory prefs per test (no disk in the test environment).
    AppPrefs.instance.firstRunComplete = false;
    AppPrefs.instance.coachMarkSeen = false;
    AppPrefs.instance.goals.value = const [];
    // Real network cannot complete under the test fake clock — force the
    // scripted spine (which is also the bridge-down production behavior).
    SeedFlowController.disableLive = true;
  });

  testWidgets('first run walks splash -> conversation -> growing -> shell',
      (tester) async {
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

    // Classification disclosed; goal persisted atomically. (Scroll the
    // lazy list — the closing bubble sits below the test viewport fold.)
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pump();
    expect(find.textContaining('is a Project'), findsOneWidget);
    expect(AppPrefs.instance.firstRunComplete, isTrue);
    expect(AppPrefs.instance.goals.value, hasLength(1));
    expect(AppPrefs.instance.goals.value.first.kind, GoalKind.project);
    expect(AppPrefs.instance.goals.value.first.status, GoalStatus.growing);

    // S3 · growing screen appears after the closing pause…
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Growing your interface…'), findsOneWidget);

    // …then the flow lands on the goal's tab (stub reveal this phase).
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Nothing planted here yet.'), findsOneWidget);
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

  testWidgets('area entry classifies as an Area', (tester) async {
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

    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Nothing planted here yet.'), findsOneWidget);
  });
}

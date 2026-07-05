import 'dart:async';

import 'package:flutter/foundation.dart';

import '../bridge/bridge_client.dart';
import '../goals/goal.dart';
import '../state/app_prefs.dart';
import 'scripted_fallback.dart';
import 'seed_flow_state.dart';

/// Drives one seed conversation. Plain ValueNotifier state (same idiom as
/// the rest of the app); pages listen to [state] and read [transcript].
///
/// Turn budget is enforced HERE (exactly two follow-ups) — never by the
/// model. Questions are AI-generated through the bridge; any failed turn
/// degrades the WHOLE remaining flow to the scripted fallback (live and
/// scripted questions never mix).
class SeedFlowController {
  SeedFlowController({required this.entry}) {
    transcript.add(ChatMessage.assistant(ScriptedFallback.opening(entry)));
    state.value = const SeedAwaitingAnswer(0);
  }

  /// Tests set this to keep widget tests offline-deterministic (real
  /// network I/O cannot complete under the test framework's fake clock).
  static bool disableLive = false;

  final SeedEntry entry;
  final List<ChatMessage> transcript = [];
  final ValueNotifier<SeedFlowState> state =
      ValueNotifier<SeedFlowState>(const SeedAwaitingAnswer(0));

  /// True once any live turn failed — the flow stays scripted afterwards.
  bool scripted = false;

  static const int followUps = 2;

  bool get composerEnabled => state.value is SeedAwaitingAnswer;

  List<Map<String, String>> get _wire =>
      [for (final m in transcript) m.toJson()];

  /// The user submitted an answer for the current question.
  Future<void> submitAnswer(String text) async {
    final s = state.value;
    if (s is! SeedAwaitingAnswer) return;
    final answer = text.trim();
    if (answer.isEmpty) return;
    transcript.add(ChatMessage.user(answer));

    if (s.turn < followUps) {
      final turn = s.turn + 1;
      state.value = SeedThinking(turn);
      final question = await _nextQuestion(turn);
      transcript.add(ChatMessage.assistant(question));
      state.value = SeedAwaitingAnswer(turn);
    } else {
      state.value = const SeedConcluding();
      final (goal, closing) = await _conclude();
      transcript.add(ChatMessage.assistant(closing));
      // Atomic: first-run flag + goal registry land together, BEFORE the
      // growing screen — a kill after this point recovers to a goal card.
      if (!AppPrefs.instance.firstRunComplete) {
        await AppPrefs.instance.completeFirstRun(goal);
      } else {
        await AppPrefs.instance.addGoal(goal);
      }
      state.value = SeedClassified(goal, closing);
    }
  }

  /// Follow-up question [turn] (1-based): live through the bridge, scripted
  /// once the flow has degraded.
  Future<String> _nextQuestion(int turn) async {
    if (!scripted && !disableLive) {
      try {
        return await BridgeClient.instance.nextQuestion(
          entry: entry.name,
          transcript: _wire,
          turn: turn,
        );
      } on Object catch (e) {
        debugPrint('seed> live turn $turn failed, going scripted: $e');
        scripted = true;
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return ScriptedFallback.followUp(entry, turn);
  }

  /// Final classification: live conclude, else local fallback.
  Future<(Goal, String)> _conclude() async {
    if (!scripted && !disableLive) {
      try {
        final r = await BridgeClient.instance.conclude(
          entry: entry.name,
          transcript: _wire,
        );
        final kind = r.kind == 'area' ? GoalKind.area : GoalKind.project;
        final goal = Goal(
          slug: AppPrefs.instance.freeSlug(
              r.slug.isEmpty ? slugify(r.title) : r.slug),
          title: r.title,
          kind: kind,
          status: GoalStatus.growing,
        );
        final closing =
            r.closing.isNotEmpty ? r.closing : ScriptedFallback.closing(goal);
        return (goal, closing);
      } on Object catch (e) {
        debugPrint('seed> live conclude failed, going scripted: $e');
        scripted = true;
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final goal = ScriptedFallback.classify(
      entry,
      transcript,
      freeSlug: AppPrefs.instance.freeSlug,
    );
    return (goal, ScriptedFallback.closing(goal));
  }

  void dispose() {
    state.dispose();
  }
}

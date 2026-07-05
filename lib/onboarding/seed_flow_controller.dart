import 'dart:async';

import 'package:flutter/foundation.dart';

import '../goals/goal.dart';
import '../state/app_prefs.dart';
import 'scripted_fallback.dart';
import 'seed_flow_state.dart';

/// Drives one seed conversation. Plain ValueNotifier state (same idiom as
/// the rest of the app); pages listen to [state] and read [transcript].
///
/// Turn budget is enforced HERE (exactly two follow-ups) — never by the
/// model. In this phase every question is scripted; the AI turns arrive in
/// the next phase and degrade back to this script per the fallback chain.
class SeedFlowController {
  SeedFlowController({required this.entry}) {
    transcript.add(ChatMessage.assistant(ScriptedFallback.opening(entry)));
    state.value = const SeedAwaitingAnswer(0);
  }

  final SeedEntry entry;
  final List<ChatMessage> transcript = [];
  final ValueNotifier<SeedFlowState> state =
      ValueNotifier<SeedFlowState>(const SeedAwaitingAnswer(0));

  /// True once any live turn failed — the flow stays scripted afterwards.
  bool scripted = true; // this phase is script-only

  static const int followUps = 2;

  bool get composerEnabled => state.value is SeedAwaitingAnswer;

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

  /// Follow-up question [turn] (1-based). Scripted in this phase.
  Future<String> _nextQuestion(int turn) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return ScriptedFallback.followUp(entry, turn);
  }

  /// Final classification. Scripted in this phase.
  Future<(Goal, String)> _conclude() async {
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

import '../goals/goal.dart';
import 'seed_flow_state.dart';

/// Scripted conversation — the offline spine. Used when the bridge is
/// unreachable (and for the whole flow before the AI is wired in). Once a
/// flow degrades to script it STAYS scripted; live and scripted questions
/// never mix inside one conversation.
class ScriptedFallback {
  ScriptedFallback._();

  /// Opening question, by entry branch (teaches the PARA split in passing).
  static String opening(SeedEntry entry) => switch (entry) {
        SeedEntry.project => "What's something you're working toward right now?",
        SeedEntry.area => "What's a part of your life you want to tend for the long run?",
      };

  /// Fixed follow-ups (goal-agnostic — unlike the AI ones, these can't read
  /// the answer). turn is 1 or 2.
  static String followUp(SeedEntry entry, int turn) => switch ((entry, turn)) {
        (SeedEntry.project, 1) => "What does 'done' look like for it?",
        (SeedEntry.project, _) => "What's the very next step you could take?",
        (SeedEntry.area, 1) => "What does tending it well look like, week to week?",
        (SeedEntry.area, _) => "What usually gets in the way?",
      };

  /// Local classification: entry decides the kind, the first answer becomes
  /// the title. Good enough to keep the metaphor coherent offline.
  static Goal classify(SeedEntry entry, List<ChatMessage> transcript,
      {required String Function(String base) freeSlug}) {
    final firstAnswer = transcript
        .firstWhere((m) => m.fromUser, orElse: () => const ChatMessage.user('My goal'))
        .text
        .trim();
    var title = firstAnswer.replaceAll(RegExp(r'\s+'), ' ');
    if (title.length > 40) title = '${title.substring(0, 39).trimRight()}…';
    if (title.isEmpty) title = 'My goal';
    return Goal(
      slug: freeSlug(slugify(title)),
      title: title,
      kind: entry.kind,
      status: GoalStatus.growing,
    );
  }

  /// Fixed closing template per kind (the AI version reads more naturally,
  /// especially when correcting the entry branch).
  static String closing(Goal goal) => switch (goal.kind) {
        GoalKind.project =>
          "Got it — “${goal.title}” is a Project: something with a finish line. Planting it now…",
        GoalKind.area =>
          "Got it — “${goal.title}” is an Area: something you tend for the long run. Planting it now…",
      };
}

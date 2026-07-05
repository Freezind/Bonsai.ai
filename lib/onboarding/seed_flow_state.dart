import '../goals/goal.dart';

/// Where the seed flow was entered from — decides the opening question and
/// the default classification. First-run defaults to [SeedEntry.project].
enum SeedEntry { project, area }

extension SeedEntryKind on SeedEntry {
  GoalKind get kind =>
      this == SeedEntry.project ? GoalKind.project : GoalKind.area;
}

class ChatMessage {
  const ChatMessage.assistant(this.text) : fromUser = false;
  const ChatMessage.user(this.text) : fromUser = true;
  final bool fromUser;
  final String text;

  Map<String, String> toJson() =>
      {'role': fromUser ? 'user' : 'assistant', 'text': text};
}

/// The seed conversation state machine. The shape is FIXED client-side:
/// opening -> answer -> follow-up 1 -> answer -> follow-up 2 -> answer ->
/// conclude. Exactly two follow-ups; the model is never asked "are you done".
sealed class SeedFlowState {
  const SeedFlowState();
}

/// Question [turn] (0 = opening) is on screen; the composer is enabled.
class SeedAwaitingAnswer extends SeedFlowState {
  const SeedAwaitingAnswer(this.turn);
  final int turn;
}

/// Follow-up question [turn] is being produced; typing indicator shows.
class SeedThinking extends SeedFlowState {
  const SeedThinking(this.turn);
  final int turn;
}

/// The conclude call is in flight; typing indicator shows.
class SeedConcluding extends SeedFlowState {
  const SeedConcluding();
}

/// Classification disclosed; the closing bubble is on screen. The goal is
/// already persisted (first-run flag + registry) — the flow then moves to
/// the growing screen.
class SeedClassified extends SeedFlowState {
  const SeedClassified(this.goal, this.closing);
  final Goal goal;
  final String closing;
}

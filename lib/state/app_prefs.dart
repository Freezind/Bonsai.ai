import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../goals/goal.dart';

/// App-level persisted state: first-run flag, coach mark, and the goal
/// registry. Singleton + ValueNotifier, mirroring the store idiom used by
/// the DSL cache. Disk I/O goes through Isolate.run (see the iOS note in
/// bridge_client.dart); a JSON file is used instead of shared_preferences
/// because the file-via-isolate path is the one proven against the iOS
/// lost-continuation bug.
class AppPrefs {
  AppPrefs._();
  static final AppPrefs instance = AppPrefs._();

  /// First-run completes the moment the first goal is classified (or its
  /// failure fallback fires) — the splash screen is never shown again.
  bool firstRunComplete = false;
  bool coachMarkSeen = false;

  /// Demo timeline switch: true = the Day-90 world (fake scenario goals +
  /// weekly digest on Home). Toggled by a long-press on the Home header for
  /// before/after screen recording.
  final ValueNotifier<bool> demoDay90 = ValueNotifier<bool>(false);

  /// The planted goals, in planting order. Tab roots render these.
  final ValueNotifier<List<Goal>> goals = ValueNotifier<List<Goal>>(const []);

  /// Connected resource ids (Resources tab). Mock connections for now —
  /// the ids gate which connector cards render as linked.
  final ValueNotifier<List<String>> connectedResources =
      ValueNotifier<List<String>>(const []);

  String? _path; // documents/bonsai_state.json; null in tests -> memory only

  Future<void> init() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _path = '${dir.path}/bonsai_state.json';
      final path = _path!;
      final text = await Isolate.run(() {
        final f = File(path);
        return f.existsSync() ? f.readAsStringSync() : null;
      });
      if (text == null) return;
      final m = jsonDecode(text) as Map<String, dynamic>;
      firstRunComplete = m['firstRunComplete'] == true;
      coachMarkSeen = m['coachMarkSeen'] == true;
      demoDay90.value = m['demoDay90'] == true;
      connectedResources.value = [
        for (final r in (m['connectedResources'] as List? ?? const [])) '$r',
      ];
      goals.value = [
        for (final g in (m['goals'] as List? ?? const []))
          Goal.fromJson(g as Map<String, dynamic>),
      ];
    } on Object catch (e) {
      // Tests / first launch / unreadable file: stay with in-memory defaults.
      debugPrint('prefs> init: $e');
    }
  }

  /// Atomic first-run completion: flag + goal land in one write, so a kill
  /// during the growing screen recovers to "shell + growing goal card".
  Future<void> completeFirstRun(Goal goal) async {
    firstRunComplete = true;
    await addGoal(goal);
  }

  Future<void> addGoal(Goal goal) async {
    goals.value = [...goals.value, goal];
    await _save();
  }

  Future<void> updateGoal(Goal goal) async {
    goals.value = [
      for (final g in goals.value) g.slug == goal.slug ? goal : g,
    ];
    await _save();
  }

  /// Swap the whole goal registry + demo flag in one write (the Day-1 ⟷
  /// Day-90 recording switch).
  Future<void> applyScenario({
    required bool day90,
    required List<Goal> scenarioGoals,
  }) async {
    demoDay90.value = day90;
    firstRunComplete = true; // the demo world is past first-run by definition
    goals.value = scenarioGoals;
    await _save();
  }

  Future<void> connectResource(String id) async {
    if (!connectedResources.value.contains(id)) {
      connectedResources.value = [...connectedResources.value, id];
    }
    await _save();
  }

  Future<void> markCoachMarkSeen() async {
    coachMarkSeen = true;
    await _save();
  }

  /// A slug not yet taken by the registry ("job-hunt", "job-hunt-2", ...).
  String freeSlug(String base) {
    final taken = {for (final g in goals.value) g.slug};
    if (!taken.contains(base)) return base;
    var i = 2;
    while (taken.contains('$base-$i')) {
      i++;
    }
    return '$base-$i';
  }

  Future<void> _save() async {
    final path = _path;
    if (path == null) return; // memory-only (tests)
    final payload = jsonEncode({
      'firstRunComplete': firstRunComplete,
      'coachMarkSeen': coachMarkSeen,
      'demoDay90': demoDay90.value,
      'connectedResources': connectedResources.value,
      'goals': [for (final g in goals.value) g.toJson()],
    });
    try {
      await Isolate.run(() => File(path).writeAsStringSync(payload));
    } on Object catch (e) {
      debugPrint('prefs> save: $e');
    }
  }
}

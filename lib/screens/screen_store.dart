import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:path_provider/path_provider.dart';

import '../bridge/bridge_client.dart';
import '../rfw_pool/pool_runtime.dart';

/// A DSL screen the robot chat may edit: its cache id, the DSL currently on
/// screen, and how to swap a new DSL in.
class EditableScreen {
  const EditableScreen({required this.intent, required this.dsl, required this.apply});
  final String intent;
  final String dsl;
  final void Function(String dsl) apply;
}

/// One agent round-trip, captured for the debug log.
class DebugEntry {
  DebugEntry({
    required this.kind,
    required this.intent,
    this.dsl,
    this.error,
    this.latencyMs = 0,
  }) : time = DateTime.now();
  final DateTime time;
  final String kind; // navigate | reveal | edit | retry
  final String intent;
  final String? dsl;
  final String? error;
  final int latencyMs;
}

/// App-wide screen services: structure memory (intent -> DSL, persisted to
/// disk), in-flight dedupe, the debug log and the status line. Screens are
/// DATA (rfw DSL) — the bridge never returns executable code; rendering
/// happens on-device via the frozen pool.
class ScreenStore {
  ScreenStore._();
  static final ScreenStore instance = ScreenStore._();

  /// Tests flip this: fetch fails fast instead of touching the network
  /// (real I/O cannot complete under the test framework's fake clock).
  static bool offlineForTests = false;

  BridgeClient get agent => BridgeClient.instance;

  /// Structure memory: a screen generated once re-renders instantly forever.
  final Map<String, String> cache = {};
  final Map<String, Future<BridgeResult>> _inflight = {};

  /// The DSL screen currently on stage — the robot chat's edit scope.
  final ValueNotifier<EditableScreen?> active = ValueNotifier(null);

  /// Per-screen previous DSLs for Undo (newest last).
  final Map<String, List<String>> editHistory = {};

  /// Robot-chat edit: regenerate the active screen under [instruction],
  /// apply it in place, remember the old version for Undo.
  Future<void> editActive(String instruction) async {
    final scr = active.value;
    if (scr == null) throw BridgeException('no editable screen on stage');
    final res = await agent.edit(scr.intent, instruction, scr.dsl);
    (editHistory[scr.intent] ??= []).add(scr.dsl);
    cache[scr.intent] = res.dsl;
    _save();
    push(DebugEntry(kind: 'edit', intent: instruction, dsl: res.dsl, latencyMs: res.latencyMs));
    scr.apply(res.dsl);
  }

  /// Undo the newest edit on the active screen.
  bool undoActive() {
    final scr = active.value;
    final hist = scr == null ? null : editHistory[scr.intent];
    if (scr == null || hist == null || hist.isEmpty) return false;
    final prev = hist.removeLast();
    cache[scr.intent] = prev;
    _save();
    scr.apply(prev);
    return true;
  }

  /// Optional data.* bindings for generated screens (neutral defaults; the
  /// persona/context data axis arrives with the main-body work).
  Map<String, Object?> uiData = kMockData;

  /// Newest-first debug log (prompt <-> DSL exchanges).
  final ValueNotifier<List<DebugEntry>> log = ValueNotifier<List<DebugEntry>>([]);

  /// One-line status shown in the shell chrome.
  final ValueNotifier<String?> status = ValueNotifier<String?>(null);

  /// Frame-safe status update: navigation/build code paths may run during a
  /// frame, where notifying listeners synchronously asserts.
  void setStatus(String? s) {
    final scheduler = SchedulerBinding.instance;
    if (scheduler.schedulerPhase == SchedulerPhase.idle) {
      status.value = s;
    } else {
      scheduler.addPostFrameCallback((_) => status.value = s);
    }
  }

  File? _file;
  bool _inited = false;

  Future<void> init() async {
    if (_inited) return;
    _inited = true;
    try {
      final dir = await getApplicationDocumentsDirectory();
      _file = File('${dir.path}/dsl_cache.json');
    } on Object catch (e) {
      debugPrint('cache> no documents dir ($e)'); // tests / unsupported host
    }
    try {
      final path = _file?.path;
      if (path == null) return;
      // File I/O in a worker isolate: main-isolate dart:io completions can
      // lose their continuations on iOS (same failure family as the HTTP
      // transport — see BridgeClient).
      final raw = await Isolate.run(() {
        final f = File(path);
        return f.existsSync() ? f.readAsStringSync() : null;
      });
      if (raw == null) return;
      cache.addAll((jsonDecode(raw) as Map<String, dynamic>).cast<String, String>());
      status.value = '${cache.length} screens restored from disk';
      debugPrint('cache> restored ${cache.length} screens');
    } on Object catch (e) {
      debugPrint('cache> load failed: $e');
    }
  }

  Future<void> _save() async {
    final path = _file?.path;
    if (path == null) return;
    try {
      final data = jsonEncode(cache);
      await Isolate.run(() => File(path).writeAsStringSync(data));
      debugPrint('cache> saved ${cache.length} screens');
    } on Object catch (e) {
      debugPrint('cache> save FAILED: $e');
    }
  }

  void push(DebugEntry e) => log.value = [e, ...log.value];

  /// DSL for an intent: memory/disk cache first, else ONE shared agent call
  /// per intent (a tap racing another fetch of the same screen joins it).
  /// [spec]/[leaf] shape the FIRST generation only — the bridge cache key is
  /// the plain intent, so later fetches need no spec.
  Future<BridgeResult> fetch(
    String intent, {
    String kind = 'navigate',
    String spec = '',
    bool leaf = false,
  }) async {
    final hit = cache[intent];
    if (hit != null) {
      debugPrint('fetch> local cache hit');
      push(DebugEntry(kind: kind, intent: intent, dsl: hit));
      return BridgeResult(dsl: hit, latencyMs: 0);
    }
    if (offlineForTests) throw BridgeException('offline (test)');
    try {
      // Hand the shared future's result over via an explicit Completer with a
      // TIMER-queue hop: on iOS the plain `await sharedFuture` continuation
      // reproducibly never resumes (microtask chain loss), while timer events
      // keep firing. `.then` + Timer.run sidesteps the lost hop.
      final shared = _inflight.putIfAbsent(
        intent,
        () => agent.generate(intent, spec: spec, leaf: leaf).whenComplete(() {
          debugPrint('fetch> whenComplete fired');
          _inflight.remove(intent);
        }),
      );
      final handoff = Completer<BridgeResult>();
      shared.then(
        (r) {
          debugPrint('fetch> then fired (${r.dsl.length}ch)');
          Timer.run(() => handoff.complete(r));
        },
        onError: (Object e, StackTrace st) {
          debugPrint('fetch> then error: $e');
          Timer.run(() => handoff.completeError(e, st));
        },
      );
      final res = await handoff.future;
      debugPrint('fetch> got dsl (${res.dsl.length}ch), caching');
      cache[intent] = res.dsl;
      _save();
      push(DebugEntry(kind: kind, intent: intent, dsl: res.dsl, latencyMs: res.latencyMs));
      return res;
    } on Object catch (e) {
      push(DebugEntry(kind: kind, intent: intent, error: '$e'));
      rethrow;
    }
  }
}

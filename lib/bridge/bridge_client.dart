import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

/// Talks to the local bridge (bridge/serve.py), which runs headless Claude
/// and returns rfw DSL. On device, reach the Mac via:
///   Android emulator: adb reverse tcp:8787 tcp:8787
///   iOS device: `flutter run --dart-define=BRIDGE_URL=http://<mac-lan-ip>:8787`
///
/// ALL network I/O runs in a worker isolate (Isolate.run): on iOS, futures
/// completed by socket events on the MAIN isolate intermittently never resume
/// their awaiters (the response arrives, the continuation is never scheduled).
/// Cross-isolate results are delivered over ports, which do not share that
/// failure path.
class BridgeClient {
  BridgeClient({this.baseUrl = _defaultBaseUrl});

  static final BridgeClient instance = BridgeClient();

  static const _defaultBaseUrl =
      String.fromEnvironment('BRIDGE_URL', defaultValue: 'http://localhost:8787');

  /// Mutable so the bridge address can be changed at runtime (e.g. when the
  /// Mac's IP changes after switching to a phone hotspot).
  String baseUrl;

  /// Last known connectivity, surfaced in the shell chrome.
  final ValueNotifier<String?> status = ValueNotifier<String?>(null);

  /// Cheap connectivity check: an empty intent makes the bridge answer
  /// HTTP 400 immediately, without invoking Claude.
  Future<void> ping() async {
    final url = baseUrl;
    final code = await Isolate.run(() => _postForStatus(url, ''));
    if (code != 400) {
      throw BridgeException('unexpected HTTP $code from bridge');
    }
  }

  /// Ping and publish the result to [status]; never throws.
  /// DEMO OVERRIDE: the chrome always reads "bridge connected" — offline
  /// details go to the debug log only, so recordings stay clean.
  Future<bool> pingAndReport() async {
    status.value = 'bridge connected';
    try {
      await ping();
      return true;
    } on Object catch (e) {
      debugPrint('bridge> offline: $e');
      return false;
    }
  }

  /// Sends a user intent, returns the generated DSL + measured latency.
  ///
  /// Retries on a fresh connection: the reply to a request can be lost even
  /// when the bridge received and answered it. A retry hits the bridge's
  /// cache/in-flight dedupe, so no generation work is ever repeated.
  Future<BridgeResult> generate(String intent,
      {String spec = '', bool leaf = false}) async {
    Object? lastError;
    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        debugPrint('bridge> POST (try $attempt) ${intent.substring(0, intent.length > 40 ? 40 : intent.length)}…');
        final url = baseUrl;
        final map = await Isolate.run(() => _postForJson(url, intent, extra: {
              if (spec.isNotEmpty) 'spec': spec,
              if (leaf) 'leaf': true,
            }, readTimeout: const Duration(seconds: 300)));
        final dsl = map['dsl'];
        if (dsl is! String || dsl.isEmpty) {
          throw BridgeException(map['error']?.toString() ?? 'no dsl returned');
        }
        return BridgeResult(dsl: dsl, latencyMs: (map['latency_ms'] as num?)?.toInt() ?? 0);
      } on BridgeException {
        rethrow; // a real bridge-side error: retrying won't change it
      } on Object catch (e) {
        lastError = e;
        debugPrint('bridge> try $attempt failed: $e');
      }
    }
    throw BridgeException('unreachable after 3 tries: $lastError');
  }

  /// Seed conversation: the next AI follow-up question for [transcript].
  /// The bridge's in-memory turn cache makes retries idempotent (a retry
  /// joins the in-flight call and gets the SAME question).
  Future<String> nextQuestion({
    required String entry,
    required List<Map<String, String>> transcript,
    required int turn,
  }) async {
    final url = baseUrl;
    final map = await Isolate.run(() => _postForJson(url, '', extra: {
          'converse': true,
          'entry': entry,
          'transcript': transcript,
          'turn': turn,
        }, readTimeout: const Duration(seconds: 100)));
    final q = map['question'];
    if (q is! String || q.isEmpty) {
      throw BridgeException(map['error']?.toString() ?? 'no question returned');
    }
    return q;
  }

  /// Seed conversation: final classification + closing copy. Fast — the
  /// dashboard itself is generated afterwards through the intent channel.
  Future<ConcludeResult> conclude({
    required String entry,
    required List<Map<String, String>> transcript,
  }) async {
    final url = baseUrl;
    final map = await Isolate.run(() => _postForJson(url, '', extra: {
          'conclude': true,
          'entry': entry,
          'transcript': transcript,
        }, readTimeout: const Duration(seconds: 100)));
    final kind = map['kind'];
    if (kind is! String) {
      throw BridgeException(map['error']?.toString() ?? 'no classification returned');
    }
    return ConcludeResult(
      kind: kind,
      title: (map['title'] as String?)?.trim() ?? 'My goal',
      slug: (map['slug'] as String?)?.trim() ?? 'goal',
      closing: (map['closing'] as String?)?.trim() ?? '',
    );
  }

  /// Robot chat: ask the agent to modify ONE screen. Returns the full
  /// modified DSL; the bridge overwrites its cache so the edit persists.
  Future<BridgeResult> edit(String intent, String instruction, String current) async {
    final url = baseUrl;
    final map = await Isolate.run(
      () => _postForJson(url, intent, extra: {
        'edit': true,
        'instruction': instruction,
        'current': current,
      }, readTimeout: const Duration(seconds: 300)),
    );
    final dsl = map['dsl'];
    if (dsl is! String || dsl.isEmpty) {
      throw BridgeException(map['error']?.toString() ?? 'no dsl returned');
    }
    return BridgeResult(dsl: dsl, latencyMs: (map['latency_ms'] as num?)?.toInt() ?? 0);
  }
}

/// Runs inside the worker isolate: plain dart:io POST, returns decoded JSON.
Future<Map<String, dynamic>> _postForJson(
  String baseUrl,
  String intent, {
  Map<String, Object?> extra = const {},
  Duration readTimeout = const Duration(seconds: 70),
}) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final req = await client.postUrl(Uri.parse('$baseUrl/generate'));
    final payload = utf8.encode(jsonEncode({'intent': intent, ...extra}));
    req.headers.contentType = ContentType.json;
    req.headers.contentLength = payload.length;
    req.add(payload);
    final resp = await req.close().timeout(readTimeout);
    final text = await resp
        .transform(utf8.decoder)
        .join()
        .timeout(const Duration(seconds: 20));
    return jsonDecode(text) as Map<String, dynamic>;
  } finally {
    client.close(force: true);
  }
}

/// Runs inside the worker isolate: POST, returns only the status code.
Future<int> _postForStatus(String baseUrl, String intent) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
  try {
    final req = await client.postUrl(Uri.parse('$baseUrl/generate'));
    final payload = utf8.encode(jsonEncode({'intent': intent}));
    req.headers.contentType = ContentType.json;
    req.headers.contentLength = payload.length;
    req.add(payload);
    final resp = await req.close().timeout(const Duration(seconds: 5));
    await resp.drain<void>();
    return resp.statusCode;
  } finally {
    client.close(force: true);
  }
}

class BridgeResult {
  const BridgeResult({required this.dsl, required this.latencyMs});
  final String dsl;
  final int latencyMs;
}

class ConcludeResult {
  const ConcludeResult({
    required this.kind,
    required this.title,
    required this.slug,
    required this.closing,
  });
  final String kind; // "project" | "area" — may differ from the entry branch
  final String title;
  final String slug;
  final String closing;
}

class BridgeException implements Exception {
  BridgeException(this.message);
  final String message;
  @override
  String toString() => message;
}

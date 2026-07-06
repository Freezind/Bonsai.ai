import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import 'app/router.dart';
import 'bridge/bridge_client.dart';
import 'ds/matcha_tokens.dart';
import 'screens/screen_store.dart';
import 'state/app_prefs.dart';

/// Dev switch: `--dart-define=RESET_STATE=true` wipes persisted state at
/// boot (first-run flag, goal registry, DSL cache) — a clean-slate install
/// without uninstalling the app.
const bool kResetState = bool.fromEnvironment('RESET_STATE');

/// Dev switch: `--dart-define=SKIP_ONBOARDING=true` boots straight into the
/// shell (first-run marked complete) — for recording takes that start past
/// the seed flow.
const bool kSkipOnboarding = bool.fromEnvironment('SKIP_ONBOARDING');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kResetState) {
    try {
      final dir = await getApplicationDocumentsDirectory();
      for (final name in ['bonsai_state.json', 'dsl_cache.json']) {
        final f = File('${dir.path}/$name');
        if (f.existsSync()) f.deleteSync();
      }
      debugPrint('boot> RESET_STATE: persisted state wiped');
    } on Object catch (e) {
      debugPrint('boot> reset failed: $e');
    }
  }
  // Prefs load BEFORE runApp so the router's first-run redirect reads them
  // synchronously (same boot order as the DSL cache restore later on).
  await AppPrefs.instance.init();
  if (kSkipOnboarding) AppPrefs.instance.firstRunComplete = true;
  await ScreenStore.instance.init(); // restore the on-device DSL cache
  runApp(const BonsaiApp());
  // Fire-and-forget connectivity probe; the shell surfaces the result.
  BridgeClient.instance.pingAndReport();
}

class BonsaiApp extends StatefulWidget {
  const BonsaiApp({super.key});

  @override
  State<BonsaiApp> createState() => _BonsaiAppState();
}

class _BonsaiAppState extends State<BonsaiApp> {
  /// Event-loop keep-alive on real devices: completed futures intermittently
  /// never resume their awaiters on iOS unless the loop keeps waking up.
  /// Lives at the ROOT (not the shell) so onboarding — which runs before the
  /// shell exists — is covered too.
  Timer? _keepAlive;
  late final GoRouter _router = createAppRouter();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      _keepAlive = Timer.periodic(const Duration(seconds: 2), (_) {});
    }
  }

  @override
  void dispose() {
    _keepAlive?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Bonsai',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Matcha.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Matcha.primary,
          primary: Matcha.primary,
          secondary: Matcha.secondary,
          surface: Matcha.paper,
        ),
        fontFamily: 'Nunito',
        dividerColor: Matcha.divider,
      ),
      routerConfig: _router,
    );
  }
}

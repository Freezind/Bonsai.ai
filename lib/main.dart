import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/router.dart';
import 'bridge/bridge_client.dart';
import 'ds/aurora_tokens.dart';

void main() {
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
        scaffoldBackgroundColor: Aurora.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Aurora.primary,
          primary: Aurora.primary,
          secondary: Aurora.secondary,
          surface: Aurora.paper,
        ),
        fontFamily: 'Nunito',
        dividerColor: Aurora.divider,
      ),
      routerConfig: appRouter,
    );
  }
}

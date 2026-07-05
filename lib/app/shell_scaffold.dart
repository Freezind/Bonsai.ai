import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ds/aurora_tokens.dart';
import '../bridge/bridge_client.dart';
import 'router.dart';

/// App chrome: wordmark + robot on top, the tab shell in the middle, the
/// Aurora bottom bar STICKY at the true screen bottom (safe-area aware).
///
/// NOTE: the event-loop keep-alive Timer lives at the ROOT widget in
/// main.dart (not here) — onboarding runs before this shell exists and its
/// bridge calls need the loop awake too.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Aurora.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(shell: shell),
            const Divider(height: 1, color: Aurora.divider),
            Expanded(child: shell),
          ],
        ),
      ),
      bottomNavigationBar: _BonsaiNavBar(shell: shell),
    );
  }
}

/// Top bar: wordmark + depth status left, robot right. The robot opens the
/// scoped edit chat (wired in a later phase; the ENTRY POINT is final now).
class _TopBar extends StatelessWidget {
  const _TopBar({required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Bonsai', style: Aurora.h2.copyWith(color: Aurora.primaryLight)),
                ValueListenableBuilder<String?>(
                  valueListenable: BridgeClient.instance.status,
                  builder: (context, status, _) => ValueListenableBuilder<int>(
                    valueListenable: tabDepth[shell.currentIndex],
                    builder: (context, depth, _) {
                      if (status == null && depth == 0) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        [
                          if (status != null) status,
                          if (depth > 0) 'depth $depth',
                        ].join('  ·  '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: Aurora.textSecondary),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          IconButton.filled(
            tooltip: 'Bonsai Agent',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('The gardener arrives in a later phase.')),
            ),
            style: IconButton.styleFrom(
              backgroundColor: Aurora.accentTint,
              foregroundColor: Aurora.primaryLight,
            ),
            icon: const Icon(Icons.smart_toy_outlined),
          ),
        ],
      ),
    );
  }
}

/// The design-system bottom bar as native app chrome: sticky, safe-area
/// aware, one icon + label per tab, selected tinted green.
class _BonsaiNavBar extends StatelessWidget {
  const _BonsaiNavBar({required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Aurora.paper,
        border: Border(top: BorderSide(color: Aurora.divider)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(Aurora.rLg)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (final tab in AppTab.values)
                Expanded(
                  child: InkWell(
                    // Tabs are peers: selecting one always lands on its ROOT
                    // (depth 0), never stacking onto the pop stack.
                    onTap: () => shell.goBranch(tab.index, initialLocation: true),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tab.icon,
                          size: 23,
                          color: shell.currentIndex == tab.index
                              ? Aurora.primaryLight
                              : Aurora.textDisabled,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: shell.currentIndex == tab.index
                                ? Aurora.primaryLight
                                : Aurora.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

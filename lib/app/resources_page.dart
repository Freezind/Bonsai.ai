import 'dart:async';

import 'package:flutter/material.dart';

import '../ds/aurora_tokens.dart';
import '../onboarding/ui/widgets/mascot.dart';
import '../state/app_prefs.dart';

/// Resources: the context inlets. Tools hold data, Bonsai holds goals —
/// connected sources water the goals they belong to.
///
/// Flow: empty bed → "+ resource" → bottom sheet of common connectors →
/// tap GBrain → (mock) linking → back on the list, GBrain shows connected.
/// Connections persist through AppPrefs; the linking itself is mocked for
/// now (see TODO.md).
class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuroraBackground(
      child: ValueListenableBuilder<List<String>>(
        valueListenable: AppPrefs.instance.connectedResources,
        builder: (context, connected, _) {
          return Stack(
            children: [
              if (connected.isEmpty)
                const _EmptyInlets()
              else
                ListView(
                  padding: const EdgeInsets.fromLTRB(
                      Aurora.s4, Aurora.s4, Aurora.s4, 96),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: Aurora.s1, bottom: Aurora.s3),
                      child: Text('CONTEXT INLETS', style: Aurora.overline),
                    ),
                    for (final id in connected)
                      if (_Connector.byId(id) != null)
                        _ConnectorCard(
                            connector: _Connector.byId(id)!, live: true),
                    const SizedBox(height: Aurora.s3),
                    Text(
                      'Tools hold data. Bonsai holds goals — connected '
                      'sources water the goals they belong to.',
                      style:
                          Aurora.body2.copyWith(color: Aurora.textDisabled),
                    ),
                  ],
                ),
              Positioned(
                right: Aurora.s4,
                bottom: Aurora.s4,
                child: _AddResourceFab(
                  onPressed: () => _showConnectSheet(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---- the connector catalogue ----

class _Connector {
  const _Connector(this.id, this.name, this.detail, this.icon,
      {this.available = false});
  final String id;
  final String name;
  final String detail;
  final IconData icon;
  final bool available;

  static const all = <_Connector>[
    _Connector('gbrain', 'GBrain', 'Personal knowledge graph',
        Icons.hub_outlined, available: true),
    _Connector('healthkit', 'HealthKit', 'Movement, sleep and vitals',
        Icons.favorite_outline, available: true),
    _Connector('calendar', 'Calendar', 'Events, focus blocks and rhythms',
        Icons.calendar_month_outlined, available: true),
    _Connector('mail', 'Mail', 'Threads that carry your goals',
        Icons.mail_outline, available: true),
    _Connector('notes', 'Notes', 'Journals and captured thoughts',
        Icons.description_outlined, available: true),
  ];

  static _Connector? byId(String id) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }
}

// ---- empty state ----

class _EmptyInlets extends StatelessWidget {
  const _EmptyInlets();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Aurora.s6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Mascot(mood: MascotMood.thirsty, size: 150),
            const SizedBox(height: Aurora.s3),
            Text('Nothing feeds your garden yet', style: Aurora.h2),
            const SizedBox(height: Aurora.s2),
            const Text(
              'Connect the tools that hold your life — Bonsai reads them '
              'to water your goals with real context.',
              textAlign: TextAlign.center,
              style: Aurora.body2,
            ),
          ],
        ),
      ),
    );
  }
}

/// The signature extended FAB, matching "+ seed".
class _AddResourceFab extends StatelessWidget {
  const _AddResourceFab({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: Aurora.s5),
        decoration: BoxDecoration(
          color: Aurora.secondary,
          border: Border.all(color: Aurora.ink, width: 2),
          borderRadius: BorderRadius.circular(Aurora.rFull),
          boxShadow: Aurora.elevPop,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Aurora.onSecondary),
            SizedBox(width: 6),
            Text('resource',
                style: TextStyle(
                  fontFamily: 'Baloo 2',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Aurora.onSecondary,
                )),
          ],
        ),
      ),
    );
  }
}

// ---- connect sheet ----

Future<void> _showConnectSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ConnectSheet(),
  );
}

class _ConnectSheet extends StatefulWidget {
  const _ConnectSheet();

  @override
  State<_ConnectSheet> createState() => _ConnectSheetState();
}

class _ConnectSheetState extends State<_ConnectSheet> {
  /// null = picking · else = the connector being linked (mock).
  _Connector? _linking;
  bool _done = false;

  Future<void> _connect(_Connector c) async {
    setState(() => _linking = c);
    // Mock linking: a believable pause, then success. The real GBrain
    // handshake replaces exactly this block.
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() => _done = true);
    await AppPrefs.instance.connectResource(c.id);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final connected = AppPrefs.instance.connectedResources.value;
    return Container(
      decoration: const BoxDecoration(
        color: Aurora.paper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(Aurora.rLg)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Aurora.paper3,
              borderRadius: BorderRadius.circular(Aurora.rFull),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(children: [
              Text('Connect a resource', style: Aurora.h2),
            ]),
          ),
          const Divider(height: 1, color: Aurora.divider),
          if (_linking != null)
            _LinkingView(connector: _linking!, done: _done)
          else ...[
            for (final c in _Connector.all)
              _SheetOption(
                connector: c,
                connected: connected.contains(c.id),
                onTap: c.available && !connected.contains(c.id)
                    ? () => _connect(c)
                    : null,
              ),
            const SizedBox(height: Aurora.s3),
          ],
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption(
      {required this.connector, required this.connected, this.onTap});
  final _Connector connector;
  final bool connected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: Aurora.s4, vertical: Aurora.s3),
        child: Row(
          children: [
            Icon(connector.icon,
                size: 26,
                color: enabled ? Aurora.primaryLight : Aurora.textDisabled),
            const SizedBox(width: Aurora.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(connector.name,
                      style: Aurora.title.copyWith(
                          color: enabled
                              ? Aurora.textPrimary
                              : Aurora.textSecondary)),
                  Text(connector.detail, style: Aurora.body2),
                ],
              ),
            ),
            if (connected)
              const Icon(Icons.check_circle,
                  size: 20, color: Aurora.stDone)
            else if (!connector.available)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Aurora.paper3,
                  borderRadius: BorderRadius.circular(Aurora.rFull),
                ),
                child: Text('Coming soon', style: Aurora.label),
              )
            else
              const Icon(Icons.chevron_right, color: Aurora.textDisabled),
          ],
        ),
      ),
    );
  }
}

/// The mock handshake: spinner → check, in the sheet.
class _LinkingView extends StatelessWidget {
  const _LinkingView({required this.connector, required this.done});
  final _Connector connector;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Aurora.s6, Aurora.s6, Aurora.s6, Aurora.s6 + Aurora.s4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (done)
            const Icon(Icons.check_circle, size: 56, color: Aurora.stDone)
          else
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                  strokeWidth: 4, color: Aurora.primary),
            ),
          const SizedBox(height: Aurora.s4),
          Text(
            done
                ? '${connector.name} connected'
                : 'Linking ${connector.name}…',
            style: Aurora.title,
          ),
          const SizedBox(height: Aurora.s1),
          Text(
            done
                ? 'Your goals can drink from it now.'
                : 'Reading what it holds — a moment.',
            style: Aurora.body2,
          ),
        ],
      ),
    );
  }
}

// ---- connected card (list) ----

class _ConnectorCard extends StatelessWidget {
  const _ConnectorCard({required this.connector, required this.live});
  final _Connector connector;
  final bool live;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Aurora.s3),
      padding: const EdgeInsets.all(Aurora.s4),
      decoration: BoxDecoration(
        color: Aurora.paper2,
        border: Border.all(color: live ? Aurora.ink : Aurora.border, width: 2),
        borderRadius: BorderRadius.circular(Aurora.rMd),
        boxShadow: live ? Aurora.elevPopSm : null,
      ),
      child: Row(
        children: [
          Icon(connector.icon,
              size: 28,
              color: live ? Aurora.primaryLight : Aurora.textDisabled),
          const SizedBox(width: Aurora.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(connector.name, style: Aurora.title),
                Text(connector.detail, style: Aurora.body2),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: live ? Aurora.primaryContainer : Aurora.paper3,
              borderRadius: BorderRadius.circular(Aurora.rFull),
            ),
            child: Text(
              live ? 'Connected' : 'Coming soon',
              style: Aurora.label.copyWith(
                color: live ? Aurora.primaryLight : Aurora.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

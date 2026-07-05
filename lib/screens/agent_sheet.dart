import 'package:flutter/material.dart';

import '../ds/aurora_tokens.dart';
import 'screen_store.dart';

/// The robot's chat: a half-height bottom sheet scoped to the DSL screen on
/// stage (visible above the sheet — Airtable-Omni style: apply directly,
/// offer Undo; no diff review for visual regions).
Future<void> showAgentSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AgentSheet(),
  );
}

class _Msg {
  _Msg(this.text, {this.mine = false, this.undoable = false, this.instruction});
  final String text;
  final bool mine;
  final bool undoable;
  final String? instruction; // for "Try again"
}

class _AgentSheet extends StatefulWidget {
  const _AgentSheet();

  @override
  State<_AgentSheet> createState() => _AgentSheetState();
}

class _AgentSheetState extends State<_AgentSheet> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [];
  bool _busy = false;

  static const _quickActions = [
    'Reorder my next steps by priority',
    'Turn this into a checklist view',
    'Add an interview pipeline tracker',
    'Make the progress more visual',
  ];

  @override
  void initState() {
    super.initState();
    final scr = ScreenStore.instance.active.value;
    _msgs.add(_Msg(scr == null
        ? 'Open one of your goals and I can reshape its dashboard for you.'
        : "I'm scoped to this goal's dashboard. Tell me what to change — reorder, swap a chart, add something new."));
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final instruction = text.trim();
    if (instruction.isEmpty || _busy) return;
    _input.clear();
    setState(() {
      _msgs.add(_Msg(instruction, mine: true));
      _busy = true;
    });
    _autoscroll();
    try {
      await ScreenStore.instance.editActive(instruction);
      if (!mounted) return;
      setState(() {
        _msgs.add(_Msg('Done — applied to the screen behind me.',
            undoable: true, instruction: instruction));
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _msgs.add(_Msg('That didn\'t work: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
      _autoscroll();
    }
  }

  void _undo() {
    final ok = ScreenStore.instance.undoActive();
    setState(() => _msgs.add(_Msg(ok ? 'Reverted.' : 'Nothing to undo.')));
    _autoscroll();
  }

  void _autoscroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scr = ScreenStore.instance.active.value;
    final scope = scr == null
        ? 'no goal open'
        : scr.intent.replaceFirst('goal:', '');
    final inset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.46,
        decoration: const BoxDecoration(
          color: Aurora.paper,
          borderRadius: BorderRadius.vertical(top: Radius.circular(Aurora.rLg)),
        ),
        child: Column(
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
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: Aurora.accentTint,
                    child: Icon(Icons.smart_toy_outlined,
                        size: 17, color: Aurora.primaryLight),
                  ),
                  const SizedBox(width: 8),
                  const Text('Bonsai Gardener', style: Aurora.title),
                  const SizedBox(width: 8),
                  // Long goal slugs must ellipsize, never overflow the row.
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Aurora.accentTint,
                          borderRadius: BorderRadius.circular(Aurora.rFull),
                        ),
                        child: Text('Editing: $scope',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Aurora.label
                                .copyWith(color: Aurora.primaryLight)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Aurora.divider),
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                children: [
                  for (final m in _msgs) _bubble(m),
                  if (_busy) _thinking(),
                ],
              ),
            ),
            if (!_busy && scr != null)
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    for (final q in _quickActions)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(q,
                              style: Aurora.body2.copyWith(color: Aurora.primaryLight)),
                          backgroundColor: Aurora.paper2,
                          side: const BorderSide(color: Aurora.outline),
                          onPressed: () => _send(q),
                        ),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      style: Aurora.body,
                      enabled: scr != null && !_busy,
                      onSubmitted: _send,
                      decoration: InputDecoration(
                        hintText: scr == null
                            ? 'Open a goal first'
                            : 'Ask me to change this screen…',
                        hintStyle:
                            const TextStyle(color: Aurora.textDisabled, fontSize: 14),
                        filled: true,
                        fillColor: Aurora.bg,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Aurora.rFull),
                          borderSide: const BorderSide(color: Aurora.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Aurora.rFull),
                          borderSide: const BorderSide(color: Aurora.outline),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed:
                        scr == null || _busy ? null : () => _send(_input.text),
                    style: IconButton.styleFrom(
                      backgroundColor: Aurora.primary,
                      foregroundColor: Aurora.onPrimary,
                    ),
                    icon: const Icon(Icons.arrow_upward, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(_Msg m) {
    return Align(
      alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: m.mine ? Aurora.primary : Aurora.bg,
          borderRadius: BorderRadius.circular(Aurora.rMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(m.text,
                style: m.mine
                    ? Aurora.body.copyWith(color: Aurora.onPrimary)
                    : Aurora.body),
            if (m.undoable)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _miniAction('Undo', _undo),
                    const SizedBox(width: 12),
                    _miniAction('Try again',
                        () => m.instruction == null ? null : _send(m.instruction!)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _miniAction(String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(label,
          style: Aurora.label.copyWith(
            color: Aurora.primaryLight,
            decoration: TextDecoration.underline,
          )),
    );
  }

  Widget _thinking() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Aurora.bg,
          borderRadius: BorderRadius.circular(Aurora.rMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Aurora.primaryLight),
            ),
            const SizedBox(width: 10),
            Text('Reshaping the screen…', style: Aurora.body2),
          ],
        ),
      ),
    );
  }
}

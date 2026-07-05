import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ds/aurora_tokens.dart';
import '../../state/app_prefs.dart';
import '../seed_flow_controller.dart';
import '../seed_flow_state.dart';
import 'widgets/chat_widgets.dart';

/// S2 · The seed conversation. Chat bubbles + composer; the keyboard is the
/// only input surface (no quick-reply chips). Fixed two follow-ups, then the
/// classification closing bubble, then on to the growing screen.
class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key, required this.entry});
  final SeedEntry entry;

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late final SeedFlowController _flow = SeedFlowController(entry: widget.entry);
  final _input = TextEditingController();
  final _scroll = ScrollController();
  Timer? _toGrowing;

  /// The "+ seed" re-entry can be abandoned; the first run cannot.
  bool get _dismissible => AppPrefs.instance.firstRunComplete;

  @override
  void initState() {
    super.initState();
    _flow.state.addListener(_onState);
  }

  void _onState() {
    _autoscroll();
    final s = _flow.state.value;
    if (s is SeedClassified) {
      // Let the closing bubble land, then move to the growing screen.
      _toGrowing = Timer(const Duration(milliseconds: 2000), () {
        if (mounted) context.go('/seed/growing', extra: s.goal);
      });
    }
  }

  void _autoscroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _input.text;
    if (text.trim().isEmpty || !_flow.composerEnabled) return;
    _input.clear();
    await _flow.submitAnswer(text);
  }

  @override
  void dispose() {
    _toGrowing?.cancel();
    _flow.state.removeListener(_onState);
    _flow.dispose();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Aurora.bg,
        appBar: AppBar(
          backgroundColor: Aurora.paper,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text('Planting a seed', style: Aurora.h2),
          actions: [
            if (_dismissible)
              IconButton(
                tooltip: 'Abandon this seed',
                icon: const Icon(Icons.close, color: Aurora.textSecondary),
                onPressed: _confirmAbandon,
              ),
          ],
          shape: const Border(bottom: BorderSide(color: Aurora.divider)),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ValueListenableBuilder<SeedFlowState>(
                  valueListenable: _flow.state,
                  builder: (context, s, _) {
                    final thinking = s is SeedThinking || s is SeedConcluding;
                    return ListView(
                      controller: _scroll,
                      padding: const EdgeInsets.symmetric(vertical: Aurora.s3),
                      children: [
                        for (final m in _flow.transcript) ChatBubble(message: m),
                        if (thinking) const TypingIndicator(),
                      ],
                    );
                  },
                ),
              ),
              _Composer(flow: _flow, input: _input, onSend: _send),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAbandon() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Aurora.paper2,
        title: Text('Abandon this seed?', style: Aurora.h2),
        content: const Text('Nothing is planted until the conversation finishes.',
            style: Aurora.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Abandon'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) {
      context.go(widget.entry == SeedEntry.area ? '/areas' : '/projects');
    }
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.flow, required this.input, required this.onSend});
  final SeedFlowController flow;
  final TextEditingController input;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SeedFlowState>(
      valueListenable: flow.state,
      builder: (context, s, _) {
        final enabled = s is SeedAwaitingAnswer;
        return Container(
          padding: const EdgeInsets.fromLTRB(
              Aurora.s4, Aurora.s2, Aurora.s2, Aurora.s2),
          decoration: const BoxDecoration(
            color: Aurora.paper,
            border: Border(top: BorderSide(color: Aurora.divider)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: input,
                  enabled: enabled,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  style: Aurora.body,
                  decoration: InputDecoration(
                    hintText: enabled ? 'Type your answer…' : 'Bonsai is thinking…',
                    hintStyle: Aurora.body.copyWith(color: Aurora.textDisabled),
                    filled: true,
                    fillColor: Aurora.paper2,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: Aurora.s4, vertical: Aurora.s3),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Aurora.rMd),
                      borderSide: const BorderSide(color: Aurora.border, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Aurora.rMd),
                      borderSide: const BorderSide(color: Aurora.primary, width: 2),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Aurora.rMd),
                      borderSide: const BorderSide(color: Aurora.border, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Aurora.s2),
              IconButton.filled(
                onPressed: enabled ? onSend : null,
                style: IconButton.styleFrom(
                  backgroundColor: Aurora.primary,
                  foregroundColor: Aurora.onPrimary,
                  disabledBackgroundColor: Aurora.paper3,
                  minimumSize: const Size(48, 48),
                ),
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
            ],
          ),
        );
      },
    );
  }
}

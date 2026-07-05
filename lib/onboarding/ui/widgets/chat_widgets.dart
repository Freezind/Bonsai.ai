import 'package:flutter/material.dart';

import '../../../ds/aurora_tokens.dart';
import '../../seed_flow_state.dart';
import 'mascot.dart';

/// One conversation bubble. Assistant: left, paper surface + ink hairline,
/// mascot avatar. User: right, tinted green container.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final fromUser = message.fromUser;
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(
          horizontal: Aurora.s4, vertical: Aurora.s3),
      decoration: BoxDecoration(
        color: fromUser ? Aurora.primaryContainer : Aurora.paper2,
        border: fromUser ? null : Border.all(color: Aurora.border, width: 1.5),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(Aurora.rLg),
          topRight: const Radius.circular(Aurora.rLg),
          bottomLeft: Radius.circular(fromUser ? Aurora.rLg : Aurora.s1),
          bottomRight: Radius.circular(fromUser ? Aurora.s1 : Aurora.rLg),
        ),
      ),
      child: Text(
        message.text,
        style: Aurora.body.copyWith(
          color: fromUser ? Aurora.onPrimaryContainer : Aurora.textPrimary,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Aurora.s4, vertical: Aurora.s2),
      child: Row(
        mainAxisAlignment:
            fromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!fromUser) ...[
            const Mascot(size: 32),
            const SizedBox(width: Aurora.s2),
          ],
          Flexible(child: bubble),
        ],
      ),
    );
  }
}

/// Three-dot "the sprout is thinking" indicator, shown while a follow-up or
/// the conclusion is in flight.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Aurora.s4, vertical: Aurora.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Mascot(size: 32),
          const SizedBox(width: Aurora.s2),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Aurora.s4, vertical: Aurora.s3),
            decoration: BoxDecoration(
              color: Aurora.paper2,
              border: Border.all(color: Aurora.border, width: 1.5),
              borderRadius: BorderRadius.circular(Aurora.rLg),
            ),
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 5),
                    _dot(((_c.value * 3 - i) % 3).abs()),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(double phase) {
    final active = phase < 1;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: active ? Aurora.primary : Aurora.textDisabled,
        shape: BoxShape.circle,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../ds/matcha_tokens.dart';
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
          horizontal: Matcha.s4, vertical: Matcha.s3),
      decoration: BoxDecoration(
        color: fromUser ? Matcha.primaryContainer : Matcha.paper2,
        border: fromUser ? null : Border.all(color: Matcha.border, width: 1.5),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(Matcha.rLg),
          topRight: const Radius.circular(Matcha.rLg),
          bottomLeft: Radius.circular(fromUser ? Matcha.rLg : Matcha.s1),
          bottomRight: Radius.circular(fromUser ? Matcha.s1 : Matcha.rLg),
        ),
      ),
      child: Text(
        message.text,
        style: Matcha.body.copyWith(
          color: fromUser ? Matcha.onPrimaryContainer : Matcha.textPrimary,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Matcha.s4, vertical: Matcha.s2),
      child: Row(
        mainAxisAlignment:
            fromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!fromUser) ...[
            const Mascot(size: 32),
            const SizedBox(width: Matcha.s2),
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
          horizontal: Matcha.s4, vertical: Matcha.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Mascot(size: 32),
          const SizedBox(width: Matcha.s2),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Matcha.s4, vertical: Matcha.s3),
            decoration: BoxDecoration(
              color: Matcha.paper2,
              border: Border.all(color: Matcha.border, width: 1.5),
              borderRadius: BorderRadius.circular(Matcha.rLg),
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
        color: active ? Matcha.primary : Matcha.textDisabled,
        shape: BoxShape.circle,
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The mascot's five growth stages, drawn 1:1 from the canonical poses in
/// `design-system/mascot.html` (`#m-seed … #m-fruit`). The design system ships
/// the growth *poses* but not their Lottie animations yet (see
/// `motion-lottie.md`), so we animate the grow ourselves: cross-fade through
/// the stages with a springy pop that rises from the pot, then loop.
///
/// Fixed mascot palette (baked, theme-independent — see the palette table in
/// `motion-lottie.md`).
const _ink = '#33302B';
const _leaf = '#3FA34D';
const _pot = '#E8703A';
const _cheek = '#F6B1B1';
const _spark = '#F5C242';
const _bud = '#F2A9C4';
const _fruit = '#E25C4A';

String _svg(String body) =>
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 300">$body</svg>';

/// 1 · SEED — tiny sprout, sleepy face on the pot.
final _seed = _svg('''
<path d="M150 182 V142" fill="none" stroke="$_ink" stroke-width="6" stroke-linecap="round"/>
<path d="M150 148 C135 148 122 138 119 121 C136 122 148 133 150 148 Z" fill="$_leaf" stroke="$_ink" stroke-width="5" stroke-linejoin="round"/>
<path d="M150 139 C164 138 176 127 179 111 C163 112 151 124 150 139 Z" fill="$_leaf" stroke="$_ink" stroke-width="5" stroke-linejoin="round"/>
<path d="M104 201 L111.5 252 Q112.3 257 117.5 257 L182.5 257 Q187.7 257 188.5 252 L196 201 Z" fill="$_pot" stroke="$_ink" stroke-width="5" stroke-linejoin="round"/>
<rect x="90" y="179" width="120" height="22" rx="9" fill="$_pot" stroke="$_ink" stroke-width="5"/>
<path d="M129 225 Q135 231 141 225 M159 225 Q165 231 171 225" fill="none" stroke="$_ink" stroke-width="5" stroke-linecap="round"/>
<ellipse cx="116" cy="234" rx="7" ry="4.5" fill="$_cheek"/><ellipse cx="184" cy="234" rx="7" ry="4.5" fill="$_cheek"/>
''');

/// 2 · SPROUT — taller shoot, happy face on the pot.
final _sprout = _svg('''
<path d="M150 182 V126" fill="none" stroke="$_ink" stroke-width="6" stroke-linecap="round"/>
<path d="M150 140 C132 140 116 128 113 108 C132 109 147 121 150 140 Z" fill="$_leaf" stroke="$_ink" stroke-width="5" stroke-linejoin="round"/>
<path d="M150 128 C167 127 182 114 186 94 C167 95 152 109 150 128 Z" fill="$_leaf" stroke="$_ink" stroke-width="5" stroke-linejoin="round"/>
<path d="M104 201 L111.5 252 Q112.3 257 117.5 257 L182.5 257 Q187.7 257 188.5 252 L196 201 Z" fill="$_pot" stroke="$_ink" stroke-width="5" stroke-linejoin="round"/>
<rect x="90" y="179" width="120" height="22" rx="9" fill="$_pot" stroke="$_ink" stroke-width="5"/>
<circle cx="135" cy="226" r="4.5" fill="$_ink"/><circle cx="165" cy="226" r="4.5" fill="$_ink"/>
<path d="M142 234 C147 240 153 240 158 234" fill="none" stroke="$_ink" stroke-width="5" stroke-linecap="round"/>
<ellipse cx="119" cy="234" rx="7" ry="4.5" fill="$_cheek"/><ellipse cx="181" cy="234" rx="7" ry="4.5" fill="$_cheek"/>
''');

/// 3 · BONSAI — full crown, content closed eyes, one bud.
final _bonsai = _svg('''
<path d="M150 205 V152" fill="none" stroke="$_ink" stroke-width="7" stroke-linecap="round"/>
<path d="M150 30 C185 30 205 50 205 67.5 C230 72.5 242.5 95 232.5 115 C245 135 225 155 205 150 C195 165 165 170 150 160 C135 170 105 165 95 150 C75 155 55 135 67.5 115 C57.5 95 70 72.5 95 67.5 C95 50 115 30 150 30 Z" fill="$_leaf" stroke="$_ink" stroke-width="5" stroke-linejoin="round"/>
<path d="M125 106 Q132 98 139 106 M161 106 Q168 98 175 106" fill="none" stroke="$_ink" stroke-width="5" stroke-linecap="round"/>
<path d="M141 119 C147 126 153 126 159 119" fill="none" stroke="$_ink" stroke-width="5" stroke-linecap="round"/>
<ellipse cx="119" cy="118" rx="7.5" ry="5" fill="$_cheek"/><ellipse cx="181" cy="118" rx="7.5" ry="5" fill="$_cheek"/>
<circle cx="206" cy="60" r="6.5" fill="$_bud" stroke="$_ink" stroke-width="4"/>
<path d="M104 201 L111.5 252 Q112.3 257 117.5 257 L182.5 257 Q187.7 257 188.5 252 L196 201 Z" fill="$_pot" stroke="$_ink" stroke-width="5" stroke-linejoin="round"/>
<rect x="90" y="179" width="120" height="22" rx="9" fill="$_pot" stroke="$_ink" stroke-width="5"/>
''');

/// 4 · BLOOM — buds open along the crown top.
final _bloom = _svg('''
<path d="M150 205 V152" fill="none" stroke="$_ink" stroke-width="7" stroke-linecap="round"/>
<path d="M150 30 C185 30 205 50 205 67.5 C230 72.5 242.5 95 232.5 115 C245 135 225 155 205 150 C195 165 165 170 150 160 C135 170 105 165 95 150 C75 155 55 135 67.5 115 C57.5 95 70 72.5 95 67.5 C95 50 115 30 150 30 Z" fill="$_leaf" stroke="$_ink" stroke-width="5" stroke-linejoin="round"/>
<circle cx="112" cy="52" r="7.5" fill="$_bud" stroke="$_ink" stroke-width="4"/>
<circle cx="150" cy="27" r="7.5" fill="$_bud" stroke="$_ink" stroke-width="4"/>
<circle cx="189" cy="50" r="7.5" fill="$_bud" stroke="$_ink" stroke-width="4"/>
<path d="M125 106 Q132 98 139 106 M161 106 Q168 98 175 106" fill="none" stroke="$_ink" stroke-width="5" stroke-linecap="round"/>
<path d="M141 119 C147 126 153 126 159 119" fill="none" stroke="$_ink" stroke-width="5" stroke-linecap="round"/>
<ellipse cx="119" cy="118" rx="7.5" ry="5" fill="$_cheek"/><ellipse cx="181" cy="118" rx="7.5" ry="5" fill="$_cheek"/>
<path d="M104 201 L111.5 252 Q112.3 257 117.5 257 L182.5 257 Q187.7 257 188.5 252 L196 201 Z" fill="$_pot" stroke="$_ink" stroke-width="5" stroke-linejoin="round"/>
<rect x="90" y="179" width="120" height="22" rx="9" fill="$_pot" stroke="$_ink" stroke-width="5"/>
''');

/// 5 · FRUIT — open eyes, berries in the crown.
final _fruitStage = _svg('''
<path d="M150 205 V152" fill="none" stroke="$_ink" stroke-width="7" stroke-linecap="round"/>
<path d="M150 30 C185 30 205 50 205 67.5 C230 72.5 242.5 95 232.5 115 C245 135 225 155 205 150 C195 165 165 170 150 160 C135 170 105 165 95 150 C75 155 55 135 67.5 115 C57.5 95 70 72.5 95 67.5 C95 50 115 30 150 30 Z" fill="$_leaf" stroke="$_ink" stroke-width="5" stroke-linejoin="round"/>
<circle cx="103" cy="88" r="8" fill="$_fruit" stroke="$_ink" stroke-width="4"/>
<circle cx="196" cy="76" r="8" fill="$_fruit" stroke="$_ink" stroke-width="4"/>
<circle cx="212" cy="114" r="6.5" fill="$_spark" stroke="$_ink" stroke-width="4"/>
<circle cx="132" cy="105" r="4.5" fill="$_ink"/><circle cx="168" cy="105" r="4.5" fill="$_ink"/>
<path d="M139 120 C146 129 154 129 161 120" fill="none" stroke="$_ink" stroke-width="5" stroke-linecap="round"/>
<ellipse cx="119" cy="119" rx="7.5" ry="5" fill="$_cheek"/><ellipse cx="181" cy="119" rx="7.5" ry="5" fill="$_cheek"/>
<path d="M104 201 L111.5 252 Q112.3 257 117.5 257 L182.5 257 Q187.7 257 188.5 252 L196 201 Z" fill="$_pot" stroke="$_ink" stroke-width="5" stroke-linejoin="round"/>
<rect x="90" y="179" width="120" height="22" rx="9" fill="$_pot" stroke="$_ink" stroke-width="5"/>
''');

/// All five stage SVGs, seed → fruit, for static per-stage rendering.
final List<String> kBonsaiStageSvgs = <String>[
  _seed, _sprout, _bonsai, _bloom, _fruitStage,
];

/// One FIXED growth stage of the mascot (0 = seed … 4 = fruit) — the tree a
/// goal has grown into. Later stages carry happier faces by design.
class StageBonsai extends StatelessWidget {
  const StageBonsai({super.key, required this.stage, this.size = 44});
  final int stage;
  final double size;

  @override
  Widget build(BuildContext context) {
    final svg = kBonsaiStageSvgs[stage.clamp(0, kBonsaiStageSvgs.length - 1)];
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.string(
        svg,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => Icon(
          Icons.spa_outlined,
          size: size * 0.6,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// A looping bonsai that grows through its five stages — seed → sprout →
/// bonsai → bloom → fruit — then starts over. Each stage pops in from the pot
/// with an overshoot-and-settle, echoing the mascot's motion signature.
class GrowingBonsai extends StatefulWidget {
  const GrowingBonsai({
    super.key,
    this.size = 220,
    this.stageDuration = const Duration(milliseconds: 950),
  });

  final double size;

  /// How long each growth stage holds before advancing to the next.
  final Duration stageDuration;

  @override
  State<GrowingBonsai> createState() => _GrowingBonsaiState();
}

class _GrowingBonsaiState extends State<GrowingBonsai> {
  static final _stages = <String>[_seed, _sprout, _bonsai, _bloom, _fruitStage];
  Timer? _timer;
  int _stage = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.stageDuration, (_) {
      if (mounted) setState(() => _stage = (_stage + 1) % _stages.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 650),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        // Grow up from the pot base — the plant's anchor point.
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween(begin: 0.82, end: 1.0).animate(anim),
            alignment: const Alignment(0, 0.62),
            child: child,
          ),
        ),
        child: SvgPicture.string(
          _stages[_stage],
          key: ValueKey(_stage),
          fit: BoxFit.contain,
          placeholderBuilder: (_) => Icon(
            Icons.spa_outlined,
            size: widget.size * 0.6,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

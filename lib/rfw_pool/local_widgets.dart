import 'package:flutter/material.dart';
import 'package:rfw/rfw.dart';

import '../ds/matcha_tokens.dart';

/// The frozen component pool, exposed to the agent's DSL as `bonsai.*` local
/// widgets. The agent (L2.5) may only compose these + core layout primitives;
/// it can never invent a new component. Adding one = a new build.
LocalWidgetLibrary createBonsaiWidgets() => LocalWidgetLibrary(_widgets);

// ---- small read helpers ----
String _s(DataSource s, String k, [String def = '']) => s.v<String>([k]) ?? def;
double _d(DataSource s, String k, [double def = 0]) => s.v<double>([k]) ?? def;
bool _b(DataSource s, String k, [bool def = false]) => s.v<bool>([k]) ?? def;

const _icons = <String, IconData>{
  'layers': Icons.layers_outlined,
  'graph': Icons.hub_outlined,
  'inbox': Icons.inbox_outlined,
  'distill': Icons.filter_alt_outlined,
  'sparkle': Icons.auto_awesome_outlined,
  'target': Icons.track_changes_outlined,
  'flag': Icons.outlined_flag,
  'git-branch': Icons.account_tree_outlined,
  'code': Icons.code,
  'archive': Icons.archive_outlined,
  'folder': Icons.folder_outlined,
  'search': Icons.search,
  'plus': Icons.add,
  'settings': Icons.settings_outlined,
  'bell': Icons.notifications_outlined,
  'user': Icons.person_outline,
  'check': Icons.check,
  'more-v': Icons.more_vert,
  'back': Icons.arrow_back,
  'chevron-right': Icons.chevron_right,
  'chevron-left': Icons.chevron_left,
  'chevron-down': Icons.expand_more,
  'calendar': Icons.calendar_today_outlined,
  'clock': Icons.schedule,
  'star': Icons.star_outline,
  'heart': Icons.favorite_outline,
  'edit': Icons.edit_outlined,
  'trash': Icons.delete_outline,
  'share': Icons.ios_share,
  'chart': Icons.bar_chart,
  'book': Icons.menu_book_outlined,
  'home': Icons.home_outlined,
  'refresh': Icons.refresh,
  'filter': Icons.tune,
  'link': Icons.link,
  'mail': Icons.mail_outline,
  'map': Icons.map_outlined,
  'play': Icons.play_arrow,
  'close': Icons.close,
  'info': Icons.info_outline,
  'lock': Icons.lock_outline,
  'eye': Icons.visibility_outlined,
  'sun': Icons.wb_sunny_outlined,
  'moon': Icons.nightlight_outlined,
  'fire': Icons.local_fire_department_outlined,
  'trophy': Icons.emoji_events_outlined,
  'leaf': Icons.eco_outlined,
  'water': Icons.water_drop_outlined,
  'walk': Icons.directions_walk,
  'sleep': Icons.bedtime_outlined,
};

/// Wrap [w] in a tap target when the DSL supplied a handler; otherwise leave
/// it untouched. Keeps every pool component tappable without dead wrappers.
Widget _tappable(Widget w, VoidCallback? onTap) =>
    onTap == null ? w : GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: w);

final Map<String, LocalWidgetBuilder> _widgets = {
  // ---- the living canvas ----
  'Canvas': (context, source) => MatchaBackground(child: source.child(['child'])),

  'Gap': (context, source) => const Spacer(),

  // ---- typed text ----
  'Txt': (context, source) {
    final style = switch (_s(source, 'style', 'body')) {
      'display' => Matcha.display,
      'h2' => Matcha.h2,
      'title' => Matcha.title,
      'body2' => Matcha.body2,
      'label' => Matcha.label,
      'overline' => Matcha.overline,
      _ => Matcha.body,
    };
    return Text(_s(source, 'text'), style: style);
  },

  'Ico': (context, source) => _tappable(
        Icon(
          _icons[_s(source, 'name', 'sparkle')] ?? Icons.circle_outlined,
          size: _d(source, 'size', 22),
          color: Matcha.textSecondary,
        ),
        source.handler(['onTap'], (VoidCallback t) => t),
      ),

  // ---- inputs ----
  'Button': (context, source) {
    final variant = _s(source, 'variant', 'contained');
    final label = _s(source, 'label', 'Button');
    final onTap = source.handler(['onPressed'], (VoidCallback t) => t);
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: Matcha.s5, vertical: 12),
      child: Text(label,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: variant == 'contained' ? Matcha.onPrimary : Matcha.primaryLight)),
    );
    final deco = switch (variant) {
      'outlined' => BoxDecoration(
          borderRadius: BorderRadius.circular(Matcha.rFull),
          border: Border.all(color: Matcha.primary, width: 1.5)),
      'text' => const BoxDecoration(),
      _ => BoxDecoration(color: Matcha.primary, borderRadius: BorderRadius.circular(Matcha.rFull)),
    };
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(decoration: deco, child: child),
    );
  },

  'Chip': (context, source) {
    final selected = _b(source, 'selected');
    final onTap = source.handler(['onTap'], (VoidCallback t) => t);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: Matcha.s3),
        decoration: BoxDecoration(
          color: selected ? Matcha.accentTint : Matcha.paper2,
          borderRadius: BorderRadius.circular(Matcha.rFull),
          border: Border.all(color: selected ? Matcha.primary : Matcha.outline),
        ),
        alignment: Alignment.center,
        child: Text(_s(source, 'label'),
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Matcha.primaryLight : Matcha.textSecondary)),
      ),
    );
  },

  'TextField': (context, source) {
    final onTap = source.handler(['onTap'], (VoidCallback t) => t);
    return _tappable(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (_s(source, 'label').isNotEmpty)
        Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(_s(source, 'label'), style: Matcha.label)),
      Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: Matcha.s3),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Matcha.paper,
          borderRadius: BorderRadius.circular(Matcha.rSm),
          border: Border.all(color: Matcha.outline, width: 1.5),
        ),
        child: Text(_s(source, 'placeholder'), style: const TextStyle(color: Matcha.textDisabled, fontSize: 15)),
      ),
    ]), onTap);
  },

  // ---- surfaces ----
  'Card': (context, source) => _tappable(
        Container(
          padding: const EdgeInsets.all(Matcha.s4),
          decoration: BoxDecoration(
            color: Matcha.paper,
            borderRadius: BorderRadius.circular(Matcha.rLg),
            border: Border.all(color: Matcha.divider),
          ),
          child: source.child(['child']),
        ),
        source.handler(['onTap'], (VoidCallback t) => t),
      ),

  'AppBar': (context, source) {
    final large = _b(source, 'large');
    final overline = _s(source, 'overline');
    final title = _s(source, 'title');
    final onBack = source.handler(['onBack'], (VoidCallback t) => t);
    final actionIcon = _s(source, 'actionIcon');
    final onAction = source.handler(['onAction'], (VoidCallback t) => t);
    final back = onBack == null
        ? null
        : _tappable(const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.arrow_back, color: Matcha.textSecondary)), onBack);
    final action = actionIcon.isEmpty
        ? null
        : _tappable(Padding(padding: const EdgeInsets.all(4), child: Icon(_icons[actionIcon] ?? Icons.more_vert, color: Matcha.textSecondary)), onAction);
    if (large) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(Matcha.s4, Matcha.s5, Matcha.s4, Matcha.s3),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (back != null || action != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [if (back != null) back, const Spacer(), if (action != null) action]),
            ),
          if (overline.isNotEmpty) Text(overline, style: Matcha.overline),
          const SizedBox(height: 8),
          Text(title, style: Matcha.display),
        ]),
      );
    }
    return SizedBox(
      height: 56,
      child: Row(children: [
        const SizedBox(width: Matcha.s2),
        if (back != null) Padding(padding: const EdgeInsets.only(right: 8), child: back),
        Expanded(child: Text(title, style: Matcha.title)),
        if (action != null) Padding(padding: const EdgeInsets.only(right: Matcha.s3), child: action),
      ]),
    );
  },

  // ---- navigation ----
  // Tabs are APP CHROME now (the GoRouter shell owns the sticky bottom bar);
  // a DSL-emitted BottomNav renders nothing so legacy/agent output can't
  // draw a second, non-functional bar inside the scroll content.
  'BottomNav': (context, source) => const SizedBox.shrink(),

  'Fab': (context, source) {
    final onTap = source.handler(['onPressed'], (VoidCallback t) => t);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(color: Matcha.primary, borderRadius: BorderRadius.circular(Matcha.rLg)),
        child: const Icon(Icons.add, color: Matcha.onPrimary),
      ),
    );
  },

  'ListItem': (context, source) {
    final onTap = source.handler(['onTap'], (VoidCallback t) => t);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Matcha.s3, horizontal: Matcha.s2),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_s(source, 'title'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Matcha.textPrimary)),
              if (_s(source, 'subtitle').isNotEmpty)
                Padding(padding: const EdgeInsets.only(top: 2), child: Text(_s(source, 'subtitle'), style: Matcha.body2)),
            ]),
          ),
          if (source.v<String>(['status']) != null) _statusBadge(_s(source, 'status'), _s(source, 'status')),
        ]),
      ),
    );
  },

  'Rule': (context, source) => Container(height: 1, color: Matcha.divider),

  // ---- signature: PARA / status ----
  'CatTag': (context, source) {
    final label = _s(source, 'label', 'Category');
    final archive = _b(source, 'archive');
    final c = archive ? Matcha.catArchive : Matcha.catNeutral;
    return _tappable(Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(Matcha.rFull),
        border: Border.all(color: c.withValues(alpha: 0.40)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c)),
      ]),
    ), source.handler(['onTap'], (VoidCallback t) => t));
  },

  'StatusBadge': (context, source) => _statusBadge(_s(source, 'status', 'blocked'), _s(source, 'label', _s(source, 'status', 'blocked'))),

  'ProjectCard': (context, source) {
    final progress = _d(source, 'progress').clamp(0.0, 1.0);
    final onTap = source.handler(['onTap'], (VoidCallback t) => t);
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(Matcha.s4),
      decoration: BoxDecoration(
        color: Matcha.paper,
        borderRadius: BorderRadius.circular(Matcha.rLg),
        border: Border.all(color: Matcha.divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _catTag(_s(source, 'category', 'Project'), false),
          _statusBadge(_s(source, 'status', 'actionable'), _s(source, 'status', 'actionable')),
        ]),
        const SizedBox(height: 10),
        Text(_s(source, 'title'), style: Matcha.title),
        if (_s(source, 'subtitle').isNotEmpty)
          Padding(padding: const EdgeInsets.only(top: 4), child: Text(_s(source, 'subtitle'), style: Matcha.body2)),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(Matcha.rFull),
          child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: Matcha.paper3, color: Matcha.primary),
        ),
      ]),
      ),
    );
  },

  'StatusTable': (context, source) => Column(children: source.childList(['children'])),

  'StatusRow': (context, source) => _tappable(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: Matcha.s3),
          child: Row(children: [
            Expanded(child: Text(_s(source, 'item'), style: const TextStyle(fontSize: 14, color: Matcha.textPrimary))),
            _statusBadge(_s(source, 'status', 'blocked'), _s(source, 'status', 'blocked')),
          ]),
        ),
        source.handler(['onTap'], (VoidCallback t) => t),
      ),

  // ---- signature hero: dependency graph (nodes; edges as simple guides) ----
  'DependencyGraph': (context, source) => Container(
        padding: const EdgeInsets.all(Matcha.s5),
        decoration: BoxDecoration(
          color: Matcha.paper,
          borderRadius: BorderRadius.circular(Matcha.rLg),
          border: Border.all(color: Matcha.divider),
        ),
        child: Wrap(spacing: 14, runSpacing: 14, children: source.childList(['nodes'])),
      ),

  'DepNode': (context, source) {
    final c = Matcha.status(_s(source, 'status', 'blocked'));
    final onTap = source.handler(['onTap'], (VoidCallback t) => t);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Matcha.paper2,
          borderRadius: BorderRadius.circular(Matcha.rFull),
          border: Border.all(color: c.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(_s(source, 'label'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Matcha.textPrimary)),
        ]),
      ),
    );
  },

  // ======== expanded pool: common components ========
  'Tabs': (context, source) => Container(
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Matcha.divider))),
        child: Row(children: source.childList(['children'])),
      ),
  'Tab': (context, source) {
    final sel = _b(source, 'selected');
    final onTap = source.handler(['onTap'], (VoidCallback t) => t);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: sel ? Matcha.primary : Colors.transparent, width: 2))),
        child: Text(_s(source, 'label'),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: sel ? Matcha.primaryLight : Matcha.textSecondary)),
      ),
    );
  },
  'Switch': (context, source) => _LocalSwitch(
        initial: _b(source, 'value'),
        onChanged: source.handler(['onChanged'], (VoidCallback t) => t),
      ),
  'Avatar': (context, source) => _tappable(
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: Matcha.accentTint, shape: BoxShape.circle),
          child: Text(_s(source, 'initials', '•'), style: const TextStyle(color: Matcha.primaryLight, fontWeight: FontWeight.w600, fontSize: 14)),
        ),
        source.handler(['onTap'], (VoidCallback t) => t),
      ),
  'Alert': (context, source) {
    final c = switch (_s(source, 'severity', 'info')) {
      'success' => Matcha.stDone,
      'warning' => Matcha.stWarning,
      'error' => Matcha.stBlocker,
      _ => Matcha.primary,
    };
    return _tappable(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: Matcha.s4, vertical: Matcha.s3),
        decoration: BoxDecoration(color: Matcha.paper2, borderRadius: BorderRadius.circular(Matcha.rSm), border: Border(left: BorderSide(color: c, width: 3))),
        child: Text(_s(source, 'text'), style: Matcha.body),
      ),
      source.handler(['onTap'], (VoidCallback t) => t),
    );
  },
  // Horizontally scrollable: the agent freely adds steps, so a bare Row
  // overflows narrow screens.
  'Stepper': (context, source) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: source.childList(['children'])),
      ),
  'Step': (context, source) {
    final st = _s(source, 'state', 'upcoming');
    final c = switch (st) { 'done' => Matcha.stDone, 'active' => Matcha.primary, _ => Matcha.paper3 };
    return _tappable(Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          child: st == 'done'
              ? const Icon(Icons.check, size: 14, color: Matcha.onPrimary)
              : Text(_s(source, 'n', '•'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: st == 'active' ? Matcha.onPrimary : Matcha.textSecondary)),
        ),
        const SizedBox(width: 6),
        Text(_s(source, 'label'), style: const TextStyle(fontSize: 13, color: Matcha.textSecondary, fontWeight: FontWeight.w600)),
      ]),
    ), source.handler(['onTap'], (VoidCallback t) => t));
  },
  'Sheet': (context, source) => Container(
        padding: const EdgeInsets.fromLTRB(Matcha.s4, Matcha.s3, Matcha.s4, Matcha.s5),
        decoration: const BoxDecoration(color: Matcha.paper2, borderRadius: BorderRadius.vertical(top: Radius.circular(Matcha.rXl))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 5, margin: const EdgeInsets.only(bottom: 14), decoration: BoxDecoration(color: Matcha.outline, borderRadius: BorderRadius.circular(3)))),
          source.child(['child']),
        ]),
      ),
  'Menu': (context, source) => Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: Matcha.paper2, borderRadius: BorderRadius.circular(Matcha.rSm), border: Border.all(color: Matcha.outline)),
        child: Column(mainAxisSize: MainAxisSize.min, children: source.childList(['children'])),
      ),
  'MenuItem': (context, source) {
    final onTap = source.handler(['onTap'], (VoidCallback t) => t);
    return GestureDetector(
      onTap: onTap,
      child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: Matcha.s3, vertical: 10), child: Text(_s(source, 'label'), style: Matcha.body)),
    );
  },
  'Slider': (context, source) {
    final v = _d(source, 'value', 0.5).clamp(0.0, 1.0);
    return _tappable(SizedBox(
      height: 24,
      child: LayoutBuilder(
        builder: (c, bc) => Stack(alignment: Alignment.centerLeft, children: [
          Container(height: 6, decoration: BoxDecoration(color: Matcha.paper3, borderRadius: BorderRadius.circular(Matcha.rFull))),
          Container(height: 6, width: bc.maxWidth * v, decoration: BoxDecoration(color: Matcha.primary, borderRadius: BorderRadius.circular(Matcha.rFull))),
          Positioned(left: (bc.maxWidth - 18) * v, child: Container(width: 18, height: 18, decoration: const BoxDecoration(color: Matcha.primaryLight, shape: BoxShape.circle))),
        ]),
      ),
    ), source.handler(['onTap'], (VoidCallback t) => t));
  },
  'HabitHeatmap': (context, source) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: source.childList(['rows'])),
  'HeatRow': (context, source) {
    final days = _s(source, 'days').split(',').where((x) => x.isNotEmpty);
    Color cell(String s) => switch (s.trim()) { 'd' || 't' => Matcha.stDone, 'm' => const Color(0x66CF7A66), _ => Matcha.paper3 };
    return _tappable(Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 96, child: Text(_s(source, 'label'), style: Matcha.body2)),
        ...days.map((s) => Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(color: cell(s), borderRadius: BorderRadius.circular(5), border: s.trim() == 't' ? Border.all(color: Matcha.primary, width: 2) : null),
            )),
      ]),
    ), source.handler(['onTap'], (VoidCallback t) => t));
  },

  // ======== expanded pool: metrics / content / signature (round 2) ========
  'ProgressRing': (context, source) {
    final v = _d(source, 'value').clamp(0.0, 1.0);
    final size = _d(source, 'size', 72);
    final label = _s(source, 'label', '${(v * 100).round()}%');
    return _tappable(
      SizedBox(
        width: size,
        height: size,
        child: Stack(fit: StackFit.expand, children: [
          const CircularProgressIndicator(value: 1, strokeWidth: 6, color: Matcha.paper3),
          CircularProgressIndicator(value: v, strokeWidth: 6, color: Matcha.primary, strokeCap: StrokeCap.round),
          Center(child: Text(label, style: TextStyle(fontSize: size * 0.2, fontWeight: FontWeight.w700, color: Matcha.textPrimary))),
        ]),
      ),
      source.handler(['onTap'], (VoidCallback t) => t),
    );
  },
  'Stat': (context, source) {
    final delta = _s(source, 'delta');
    final up = !delta.startsWith('-');
    return _tappable(
      Container(
        padding: const EdgeInsets.all(Matcha.s4),
        decoration: BoxDecoration(color: Matcha.paper, borderRadius: BorderRadius.circular(Matcha.rLg), border: Border.all(color: Matcha.divider)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_s(source, 'label'), style: Matcha.label),
          const SizedBox(height: 6),
          Text(_s(source, 'value'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Matcha.textPrimary)),
          if (delta.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(delta, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: up ? Matcha.stDone : Matcha.stBlocker)),
            ),
        ]),
      ),
      source.handler(['onTap'], (VoidCallback t) => t),
    );
  },
  'SearchBar': (context, source) => _tappable(
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: Matcha.s3),
          decoration: BoxDecoration(color: Matcha.paper2, borderRadius: BorderRadius.circular(Matcha.rFull), border: Border.all(color: Matcha.outline)),
          child: Row(children: [
            const Icon(Icons.search, size: 18, color: Matcha.textDisabled),
            const SizedBox(width: 8),
            Text(_s(source, 'placeholder', 'Search'), style: const TextStyle(color: Matcha.textDisabled, fontSize: 14)),
          ]),
        ),
        source.handler(['onTap'], (VoidCallback t) => t),
      ),
  'SectionHeader': (context, source) {
    final action = _s(source, 'action');
    return Row(children: [
      Expanded(child: Text(_s(source, 'title').toUpperCase(), style: Matcha.overline)),
      if (action.isNotEmpty)
        _tappable(
          Text(action, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Matcha.primaryLight)),
          source.handler(['onAction'], (VoidCallback t) => t),
        ),
    ]);
  },
  'EmptyState': (context, source) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(children: [
          Icon(_icons[_s(source, 'icon', 'inbox')] ?? Icons.inbox_outlined, size: 40, color: Matcha.textDisabled),
          const SizedBox(height: 10),
          Text(_s(source, 'text', 'Nothing here yet'), style: Matcha.body2, textAlign: TextAlign.center),
        ]),
      ),
  'Timeline': (context, source) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: source.childList(['children'])),
  'TimeItem': (context, source) {
    final c = Matcha.status(_s(source, 'status', 'foundation'));
    return _tappable(
      IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Column(children: [
            Container(width: 10, height: 10, margin: const EdgeInsets.only(top: 4), decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
            Expanded(child: Container(width: 2, color: Matcha.divider)),
          ]),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(_s(source, 'title'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Matcha.textPrimary))),
                  if (_s(source, 'time').isNotEmpty) Text(_s(source, 'time'), style: const TextStyle(fontSize: 11, color: Matcha.textDisabled)),
                ]),
                if (_s(source, 'subtitle').isNotEmpty)
                  Padding(padding: const EdgeInsets.only(top: 2), child: Text(_s(source, 'subtitle'), style: Matcha.body2)),
              ]),
            ),
          ),
        ]),
      ),
      source.handler(['onTap'], (VoidCallback t) => t),
    );
  },
  'BarChart': (context, source) {
    final vals = _s(source, 'values').split(',').map((e) => double.tryParse(e.trim()) ?? 0.0).toList();
    final labels = _s(source, 'labels').split(',').map((e) => e.trim()).toList();
    final h = _d(source, 'height', 96);
    final maxV = vals.fold(0.0, (a, b) => a > b ? a : b);
    return SizedBox(
      height: h + 18,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (var i = 0; i < vals.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                  height: maxV <= 0 ? 0 : (vals[i] / maxV) * h,
                  decoration: BoxDecoration(color: Matcha.primary.withValues(alpha: 0.85), borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                ),
                const SizedBox(height: 4),
                Text(i < labels.length ? labels[i] : '', style: const TextStyle(fontSize: 10, color: Matcha.textSecondary)),
              ]),
            ),
          ),
      ]),
    );
  },
  'CheckItem': (context, source) => _LocalCheckItem(
        label: _s(source, 'label'),
        initial: _b(source, 'checked'),
        onTap: source.handler(['onTap'], (VoidCallback t) => t),
      ),
  'KeyValue': (context, source) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 120, child: Text(_s(source, 'label'), style: Matcha.body2)),
          Expanded(child: Text(_s(source, 'value'), style: const TextStyle(fontSize: 14, color: Matcha.textPrimary))),
        ]),
      ),
  'MoodPicker': (context, source) => Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: source.childList(['options'])),
  'MoodOption': (context, source) => _LocalMoodOption(
        emoji: _s(source, 'emoji', '🙂'),
        label: _s(source, 'label'),
        initial: _b(source, 'selected'),
        onTap: source.handler(['onTap'], (VoidCallback t) => t),
      ),
  'Banner': (context, source) => _tappable(
        Container(
          padding: const EdgeInsets.all(Matcha.s5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Matcha.bannerA, Matcha.bannerB], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(Matcha.rXl),
            border: Border.all(color: Matcha.outline),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_s(source, 'title'), style: Matcha.title),
                if (_s(source, 'subtitle').isNotEmpty)
                  Padding(padding: const EdgeInsets.only(top: 6), child: Text(_s(source, 'subtitle'), style: Matcha.body2)),
              ]),
            ),
            if (_s(source, 'icon').isNotEmpty)
              Icon(_icons[_s(source, 'icon')] ?? Icons.auto_awesome_outlined, size: 32, color: Matcha.primaryLight),
          ]),
        ),
        source.handler(['onTap'], (VoidCallback t) => t),
      ),
};

// ---- shared builders reused across components ----
Widget _statusBadge(String status, String label) {
  final c = Matcha.status(status);
  return Container(
    height: 24,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(color: c.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(Matcha.rFull)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 7, height: 7, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c)),
    ]),
  );
}

// ---- state controls: toggle locally on tap (a checkbox must check, not
// call the agent). The DSL handler (e.g. event "toggle") still fires so the
// app can record/save, but it never drives the visual state.
class _LocalCheckItem extends StatefulWidget {
  const _LocalCheckItem({required this.label, required this.initial, this.onTap});
  final String label;
  final bool initial;
  final VoidCallback? onTap;
  @override
  State<_LocalCheckItem> createState() => _LocalCheckItemState();
}

class _LocalCheckItemState extends State<_LocalCheckItem> {
  late bool checked = widget.initial;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => checked = !checked);
        widget.onTap?.call();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: checked ? Matcha.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: checked ? Matcha.primary : Matcha.outline, width: 1.5),
            ),
            child: checked ? const Icon(Icons.check, size: 15, color: Matcha.onPrimary) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                color: checked ? Matcha.textSecondary : Matcha.textPrimary,
                decoration: checked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _LocalSwitch extends StatefulWidget {
  const _LocalSwitch({required this.initial, this.onChanged});
  final bool initial;
  final VoidCallback? onChanged;
  @override
  State<_LocalSwitch> createState() => _LocalSwitchState();
}

class _LocalSwitchState extends State<_LocalSwitch> {
  late bool on = widget.initial;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => on = !on);
        widget.onChanged?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 46,
        height: 26,
        padding: const EdgeInsets.all(3),
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: on ? Matcha.primaryDark : Matcha.paper3,
          borderRadius: BorderRadius.circular(Matcha.rFull),
          border: Border.all(color: on ? Matcha.primary : Matcha.outline),
        ),
        child: Container(width: 18, height: 18, decoration: BoxDecoration(color: on ? Matcha.primaryLight : Matcha.textSecondary, shape: BoxShape.circle)),
      ),
    );
  }
}

class _LocalMoodOption extends StatefulWidget {
  const _LocalMoodOption({required this.emoji, required this.label, required this.initial, this.onTap});
  final String emoji;
  final String label;
  final bool initial;
  final VoidCallback? onTap;
  @override
  State<_LocalMoodOption> createState() => _LocalMoodOptionState();
}

class _LocalMoodOptionState extends State<_LocalMoodOption> {
  late bool sel = widget.initial;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => sel = !sel);
        widget.onTap?.call();
      },
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: sel ? Matcha.accentTint : Colors.transparent,
            border: Border.all(color: sel ? Matcha.primary : Colors.transparent, width: 1.5),
          ),
          child: Text(widget.emoji, style: const TextStyle(fontSize: 26)),
        ),
        if (widget.label.isNotEmpty)
          Padding(padding: const EdgeInsets.only(top: 4), child: Text(widget.label, style: const TextStyle(fontSize: 11, color: Matcha.textSecondary))),
      ]),
    );
  }
}

Widget _catTag(String label, bool archive) {
  final c = archive ? Matcha.catArchive : Matcha.catNeutral;
  return Container(
    height: 26,
    padding: const EdgeInsets.symmetric(horizontal: 11),
    decoration: BoxDecoration(
      color: c.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(Matcha.rFull),
      border: Border.all(color: c.withValues(alpha: 0.40)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 7, height: 7, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c)),
    ]),
  );
}

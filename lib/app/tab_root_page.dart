import 'package:flutter/material.dart';

import '../ds/aurora_tokens.dart';
import 'router.dart';

/// Native blank tab root. Projects/Areas grow "+ seed" and goal cards in
/// later phases; Home/Resources/Archive stay quiet placeholders until the
/// main-body work.
class TabRootPage extends StatelessWidget {
  const TabRootPage({super.key, required this.tab});
  final AppTab tab;

  bool get _plantable => tab == AppTab.projects || tab == AppTab.areas;

  @override
  Widget build(BuildContext context) {
    return AuroraBackground(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(tab.icon, size: 44, color: Aurora.textDisabled),
            const SizedBox(height: Aurora.s3),
            Text(tab.label, style: Aurora.h2),
            const SizedBox(height: Aurora.s2),
            Text(
              _plantable
                  ? 'Nothing planted here yet.'
                  : 'This bed is still being prepared.',
              style: Aurora.body2,
            ),
          ],
        ),
      ),
    );
  }
}

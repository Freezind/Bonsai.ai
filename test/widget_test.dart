import 'package:flutter_test/flutter_test.dart';

import 'package:bonsai/app/router.dart';
import 'package:bonsai/main.dart';

void main() {
  testWidgets('shell renders 5 tabs and switching lands on tab roots',
      (tester) async {
    await tester.pumpWidget(const BonsaiApp());
    await tester.pumpAndSettle();

    // All five tabs are present in the bottom bar.
    for (final tab in AppTab.values) {
      expect(find.text(tab.label), findsWidgets);
    }

    // Switch to Projects: its root (empty state) shows, depth stays 0.
    await tester.tap(find.text('Projects').last);
    await tester.pumpAndSettle();
    expect(find.text('Nothing planted here yet.'), findsOneWidget);
    expect(tabDepth[AppTab.projects.index].value, 0);

    // Switch to Areas: peer tab, same depth-0 behavior.
    await tester.tap(find.text('Areas').last);
    await tester.pumpAndSettle();
    expect(find.text('Nothing planted here yet.'), findsOneWidget);
    expect(tabDepth[AppTab.areas.index].value, 0);
  });
}

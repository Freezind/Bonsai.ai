import 'package:flutter_test/flutter_test.dart';

import 'package:bonsai/main.dart';

void main() {
  testWidgets('app boots', (tester) async {
    await tester.pumpWidget(const BonsaiApp());
    expect(find.text('Bonsai'), findsOneWidget);
  });
}

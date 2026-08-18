import 'package:flutter_test/flutter_test.dart';

import 'package:mino/main.dart';

void main() {
  testWidgets('Application renders the button showcase', (tester) async {
    await tester.pumpWidget(const Application());
    await tester.pumpAndSettle();

    expect(find.text('Buttons'), findsWidgets);
    expect(find.text('Primary'), findsOneWidget);
  });
}

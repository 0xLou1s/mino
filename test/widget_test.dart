import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'package:mino/main.dart';
import 'package:mino/widgets/period_picker/period_picker.dart';

void main() {
  testWidgets('Application renders the period picker', (tester) async {
    await tester.pumpWidget(const Application());
    await tester.pumpAndSettle();

    expect(find.byType(PeriodPicker), findsOneWidget);
    for (final period in Period.values) {
      expect(find.text(period.label), findsOneWidget);
    }
    await tester.tap(find.text(Period.month.label));
    await tester.pumpAndSettle();
    expect(find.byType(FCalendar), findsOneWidget);
  });
}

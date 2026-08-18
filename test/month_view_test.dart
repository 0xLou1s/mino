import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'package:mino/theme/theme.dart';
import 'package:mino/widgets/period_picker/period_picker.dart';

Widget _app({Set<DateTime> events = const {}, ValueChanged<DateTime?>? onSelect}) =>
    MaterialApp(
      localizationsDelegates: const [...FLocalizations.localizationsDelegates],
      supportedLocales: FLocalizations.supportedLocales,
      builder: (context, child) => FTheme(data: lightTheme, child: child!),
      home: FScaffold(
        child: PeriodPicker(eventDates: events, onSelect: onSelect),
      ),
    );

Future<void> _openMonth(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(find.text(Period.month.label));
  await tester.pumpAndSettle();
}

void main() {
  for (final (name, size) in [
    ('narrow phone', Size(320, 640)),
    ('phone', Size(390, 844)),
    ('tablet', Size(1024, 1366)),
  ]) {
    testWidgets('renders without overflow on $name', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app());
      await _openMonth(tester);

      expect(find.byType(FCalendar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('renders with a large text scale', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: _app(),
      ),
    );
    await _openMonth(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets('event dates built from local DateTimes are matched', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Callers build dates locally; the grid supplies UTC ones. Both must
    // normalise to the same key or the event outline silently never renders.
    final now = DateTime.now();
    await tester.pumpWidget(
      _app(events: {DateUtils.dateOnly(DateTime(now.year, now.month, now.day))}),
    );
    await _openMonth(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(FCalendar), findsOneWidget);
  });

  testWidgets('selecting a day reports it', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    DateTime? picked;
    await tester.pumpWidget(_app(onSelect: (d) => picked = d));
    await _openMonth(tester);
    await tester.tap(find.text('15').first);
    await tester.pumpAndSettle();

    expect(picked?.day, 15);
  });

  testWidgets('non-month periods render empty', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    for (final period in [Period.day, Period.week, Period.year]) {
      await tester.tap(find.text(period.label));
      await tester.pumpAndSettle();
      expect(find.byType(FCalendar), findsNothing, reason: period.label);
      expect(tester.takeException(), isNull);
    }
  });
}

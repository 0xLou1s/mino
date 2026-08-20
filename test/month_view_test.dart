import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';

import 'package:mino/theme/theme.dart';
import 'package:mino/widgets/period_picker/period_picker.dart';

const _phone = Size(390, 844);

Widget _app({
  Set<DateTime> events = const {},
  ValueChanged<DateTime?>? onSelect,
}) => MaterialApp(
  localizationsDelegates: const [...FLocalizations.localizationsDelegates],
  supportedLocales: FLocalizations.supportedLocales,
  builder: (context, child) => FTheme(data: lightTheme, child: child!),
  home: FScaffold(child: PeriodPicker(eventDates: events, onSelect: onSelect)),
);

/// Pumps [_app] at [size] and settles it, ready to interact with.
Future<void> _pump(
  WidgetTester tester, {
  Size size = _phone,
  Set<DateTime> events = const {},
  ValueChanged<DateTime?>? onSelect,
  TextScaler? textScaler,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final app = _app(events: events, onSelect: onSelect);
  await tester.pumpWidget(
    textScaler == null
        ? app
        : MediaQuery(data: MediaQueryData(textScaler: textScaler), child: app),
  );
  await tester.pumpAndSettle();
}

/// The month the grid is currently showing.
String _shownMonth() => DateFormat.MMMM().format(DateTime.now());

/// Opens the header's month/year sheet.
Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.text(_shownMonth()));
  await tester.pumpAndSettle();
}

void main() {
  for (final (name, size) in [
    ('narrow phone', Size(320, 640)),
    ('phone', _phone),
    ('tablet', Size(1024, 1366)),
  ]) {
    testWidgets('renders without overflow on $name', (tester) async {
      await _pump(tester, size: size);

      expect(find.byType(FCalendar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('renders with a large text scale', (tester) async {
    await _pump(
      tester,
      size: const Size(320, 640),
      textScaler: const TextScaler.linear(2.0),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('event dates built from local DateTimes are matched', (
    tester,
  ) async {
    // Callers build dates locally; the grid supplies UTC ones. Both must
    // normalise to the same key or the event outline silently never renders.
    final now = DateTime.now();
    await _pump(
      tester,
      events: {DateUtils.dateOnly(DateTime(now.year, now.month, now.day))},
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(FCalendar), findsOneWidget);
  });

  testWidgets('selecting a day reports it', (tester) async {
    DateTime? picked;
    await _pump(tester, onSelect: (d) => picked = d);

    await tester.tap(find.text('15').first);
    await tester.pumpAndSettle();

    expect(picked?.day, 15);
  });

  testWidgets('header shows the month and year, and pages both ways', (
    tester,
  ) async {
    await _pump(tester);

    final month = _shownMonth();
    expect(find.text(month), findsOneWidget);
    expect(find.text(DateFormat.y().format(DateTime.now())), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Next month'));
    await tester.pumpAndSettle();
    expect(find.text(month), findsNothing);

    await tester.tap(find.bySemanticsLabel('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text(month), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the header label opens the month/year sheet', (tester) async {
    await _pump(tester);
    await _openSheet(tester);

    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Done'), findsNothing);
    expect(find.byType(FCalendar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelling the sheet leaves the month unchanged', (
    tester,
  ) async {
    await _pump(tester);

    final month = _shownMonth();
    await _openSheet(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text(month), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('scrolling the month wheel moves the grid', (tester) async {
    await _pump(tester);

    final month = _shownMonth();
    await _openSheet(tester);

    // Spin the month wheel forward, then accept whatever it landed on.
    await tester.drag(
      find.bySemanticsLabel('Month'),
      const Offset(0, -80),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text(month), findsNothing);
    expect(find.byType(FCalendar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';

/// Asks the user for a month and year with side-by-side wheels in a sheet.
///
/// Returns the chosen month, or null if the sheet was dismissed. [start] and
/// [end] bound the years offered.
Future<DateTime?> showMonthYearSheet({
  required BuildContext context,
  required DateTime initial,
  required DateTime start,
  required DateTime end,
}) => showFSheet<DateTime>(
  context: context,
  side: FLayout.btt,
  useSafeArea: true,
  builder: (context) =>
      _MonthYearSheet(initial: initial, start: start, end: end),
);

class _MonthYearSheet extends StatefulWidget {
  final DateTime initial;
  final DateTime start;
  final DateTime end;

  const _MonthYearSheet({
    required this.initial,
    required this.start,
    required this.end,
  });

  @override
  State<_MonthYearSheet> createState() => _MonthYearSheetState();
}

/// The wheels' positions in [FPicker], which indexes its controller by them.
const _monthWheel = 0;
const _yearWheel = 1;

/// Month names are the same in any year, so formatting borrows an arbitrary
/// one. It is never shown.
const _nameSourceYear = 2000;

class _MonthYearSheetState extends State<_MonthYearSheet> {
  late final List<int> _years = [
    for (var y = widget.start.year; y <= widget.end.year; y++) y,
  ];
  late final FPickerController _controller = FPickerController(
    indexes: [
      widget.initial.month - 1,
      _years.indexOf(widget.initial.year).clamp(0, _years.length - 1),
    ],
  );

  /// The months' names, in the picker's order.
  List<String> _monthNames(String? locale) => [
    for (var m = 1; m <= DateTime.monthsPerYear; m++)
      DateFormat.MMMM(locale).format(DateTime(_nameSourceYear, m)),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The month the wheels currently rest on, clamped into range.
  ///
  /// The wheels turn independently, so a valid year can be paired with a month
  /// outside the calendar's range -- December of its final year, say, when the
  /// range ends in June. The pair is pulled back to the nearest valid month.
  DateTime get _selected {
    final month = DateTime.utc(
      _years[_controller.value[_yearWheel]],
      _controller.value[_monthWheel] + 1,
    );
    final first = DateTime.utc(widget.start.year, widget.start.month);
    final last = DateTime.utc(widget.end.year, widget.end.month);

    if (month.isBefore(first)) {
      return first;
    }
    return month.isAfter(last) ? last : month;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final locale = FLocalizations.of(context)?.localeName;

    // The sheet route paints no surface of its own, so the content carries the
    // background and the rounded top edge.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.only(
          topLeft: theme.style.borderRadius.xl2.topLeft,
          topRight: theme.style.borderRadius.xl2.topRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: .min,
          children: [
            Row(
              children: [
                FButton(
                  variant: .ghost,
                  onPress: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                FButton(
                  onPress: () => Navigator.of(context).pop(_selected),
                  child: const Text('Done'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: 200,
              child: FPicker(
                control: .managed(controller: _controller),
                children: [
                  // The month wheel is wider: its names outrun four digits.
                  FPickerWheel(
                    flex: 3,
                    semanticsLabel: 'Month',
                    children: [
                      for (final name in _monthNames(locale)) Text(name),
                    ],
                  ),
                  FPickerWheel(
                    flex: 2,
                    semanticsLabel: 'Year',
                    children: [for (final y in _years) Text('$y')],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

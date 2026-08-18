import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:mino/theme/styles/tabs_style.dart';
import 'package:mino/widgets/period_picker/month_view.dart';

enum Period {
  day('Day'),
  week('Week'),
  month('Month'),
  year('Year');

  final String label;

  const Period(this.label);
}

/// Lets the user browse dates across day, week, month and year views.
///
/// Only [Period.month] is implemented; the rest are placeholders.
class PeriodPicker extends StatelessWidget {
  final Set<DateTime> eventDates;
  final ValueChanged<DateTime?>? onSelect;

  const PeriodPicker({super.key, this.eventDates = const {}, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return FTabs(
      expands: true,
      style: underlineTabsStyle(
        colors: theme.colors,
        typography: theme.typography,
        style: theme.style,
      ),
      children: [
        for (final period in Period.values)
          FTabEntry(label: Text(period.label), child: _view(period)),
      ],
    );
  }

  Widget _view(Period period) => switch (period) {
    Period.month => MonthView(eventDates: eventDates, onSelect: onSelect),
    _ => const SizedBox.expand(),
  };
}

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:mino/theme/styles/calendar_style.dart';

/// A month grid of days, filling the available width.
class MonthView extends StatelessWidget {
  static const maxDayHeight = 52.0;

  final Set<DateTime> eventDates;
  final ValueChanged<DateTime?>? onSelect;

  const MonthView({super.key, this.eventDates = const {}, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // FCalendar sizes itself to 7 * daySize.width, so filling the width
        // means deriving the day size from it. The height is capped so six
        // rows still fit on wide layouts.
        final width = constraints.maxWidth / DateTime.daysPerWeek;
        final height = width.clamp(0.0, maxDayHeight);

        return Align(
          alignment: Alignment.topCenter,
          child: FCalendar.grid(
            selectionControl: FDateSelectionControl.managedSingle(
              onChange: onSelect,
            ),
            headerBuilder: (_, _, _, _) => const SizedBox.shrink(),
            dayBuilder: dayBuilder(
              colors: theme.colors,
              style: theme.style,
              eventDates: eventDates,
            ),
            style: calendarStyle(
              colors: theme.colors,
              typography: theme.typography,
              icons: theme.icons,
              style: theme.style,
              hapticFeedback: theme.hapticFeedback,
              touch: true,
              daySize: Size(width, height),
            ),
          ),
        );
      },
    );
  }
}

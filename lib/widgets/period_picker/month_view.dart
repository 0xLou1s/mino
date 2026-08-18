import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:mino/theme/styles/calendar_style.dart';

/// A month grid of days, filling the available width.
class MonthView extends StatefulWidget {
  static const maxDayHeight = 52.0;

  final Set<DateTime> eventDates;
  final ValueChanged<DateTime?>? onSelect;

  const MonthView({super.key, this.eventDates = const {}, this.onSelect});

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  // Building the style resolves a variant entry per day state, so it is kept
  // off the layout path and rebuilt only when the theme changes.
  FThemeData? _theme;
  late FCalendarStyle _style;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final theme = FTheme.of(context);
    if (theme != _theme) {
      _theme = theme;
      _style = calendarStyle(
        colors: theme.colors,
        typography: theme.typography,
        icons: theme.icons,
        style: theme.style,
        hapticFeedback: theme.hapticFeedback,
        touch: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _theme!;

    return LayoutBuilder(
      builder: (context, constraints) {
        // FCalendar sizes itself to 7 * daySize.width, so filling the width
        // means deriving the day size from it. The height is capped so six
        // rows still fit on wide layouts.
        final width = constraints.maxWidth / DateTime.daysPerWeek;
        final size = Size(width, width.clamp(0.0, MonthView.maxDayHeight));

        return Align(
          alignment: Alignment.topCenter,
          child: FCalendar.grid(
            selectionControl: FDateSelectionControl.managedSingle(
              onChange: widget.onSelect,
            ),
            headerBuilder: (_, _, _, _) => const SizedBox.shrink(),
            dayBuilder: dayBuilder(
              colors: theme.colors,
              style: theme.style,
              eventDates: widget.eventDates,
              daySize: size,
            ),
            style: _style.copyWith(
              dayPickerStyle: _style.dayPickerStyle.copyWith(daySize: size),
            ),
          ),
        );
      },
    );
  }
}

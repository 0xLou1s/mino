import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:mino/widgets/period_picker/month_year_sheet.dart';

/// The calendar's header: the shown month above its year, with a button on
/// either side that pages the grid.
///
/// Pressing the label opens a sheet that picks a month and year together.
class MonthHeader extends StatelessWidget {
  final FGridCalendarController controller;

  const MonthHeader({super.key, required this.controller});

  /// [date] as a first-of-month, the granularity the grid pages at.
  static DateTime _monthOf(DateTime date) => DateTime.utc(date.year, date.month);

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final month = controller.currentMonth;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            _PageButton(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              semanticsLabel: 'Previous month',
              controller: controller,
              target: DateTime.utc(month.year, month.month - 1),
            ),

            Expanded(child: _Label(controller: controller, month: month)),

            _PageButton(
              icon: HugeIcons.strokeRoundedArrowRight01,
              semanticsLabel: 'Next month',
              controller: controller,
              target: DateTime.utc(month.year, month.month + 1),
            ),
          ],
        ),
      );
    },
  );
}

/// Pages the grid to [target], or is disabled if that lies outside the
/// calendar's range -- paging there would clamp back to where it started.
class _PageButton extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String semanticsLabel;
  final FGridCalendarController controller;
  final DateTime target;

  const _PageButton({
    required this.icon,
    required this.semanticsLabel,
    required this.controller,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final inRange =
        !target.isBefore(MonthHeader._monthOf(controller.start)) &&
        !target.isAfter(MonthHeader._monthOf(controller.end));

    return FButton.icon(
      size: .sm,
      semanticsLabel: semanticsLabel,
      onPress: inRange ? () => controller.animateToDayPicker(target) : null,
      // Drawn a little heavier than the theme's icons so it stays legible at
      // this size.
      child: HugeIcon(icon: icon, size: null, strokeWidth: 2.4),
    );
  }
}

/// The month over its year, opening the month/year sheet when pressed.
class _Label extends StatelessWidget {
  final FGridCalendarController controller;
  final DateTime month;

  const _Label({required this.controller, required this.month});

  Future<void> _choose(BuildContext context) async {
    final picked = await showMonthYearSheet(
      context: context,
      initial: month,
      start: controller.start,
      end: controller.end,
    );

    if (picked != null) {
      await controller.animateToDayPicker(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final locale = FLocalizations.of(context)?.localeName;

    return FTappable(
      semanticsLabel: 'Choose month and year',
      onPress: () => _choose(context),
      // At large text scales the stacked labels outgrow the buttons beside
      // them, so they shrink to fit rather than force the calendar to overflow.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: .min,
          children: [
            Text(
              DateFormat.MMMM(locale).format(month),
              style: theme.typography.display.xl.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colors.foreground,
                // The display face carries a roomy line height, which would
                // otherwise leave a gap below the month.
                height: 1.1,
              ),
            ),
            Text(
              DateFormat.y(locale).format(month),
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

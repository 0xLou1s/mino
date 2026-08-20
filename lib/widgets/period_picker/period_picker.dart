import 'package:flutter/widgets.dart';
import 'package:mino/widgets/period_picker/month_view.dart';

/// Lets the user browse dates in a month view.
class PeriodPicker extends StatelessWidget {
  final Set<DateTime> eventDates;
  final ValueChanged<DateTime?>? onSelect;

  const PeriodPicker({super.key, this.eventDates = const {}, this.onSelect});

  @override
  Widget build(BuildContext context) =>
      MonthView(eventDates: eventDates, onSelect: onSelect);
}

import 'package:flutter/material.dart';
import 'package:mino/widgets/layout/app_scaffold.dart';
import 'package:mino/widgets/period_picker/period_picker.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static void _noop() {}

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Mino',
      onAddEvent: _noop,
      child: PeriodPicker(),
    );
  }
}

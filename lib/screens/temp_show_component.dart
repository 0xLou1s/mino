import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:mino/screens/home_screen.dart';

class TempShowComponent extends StatelessWidget {
  const TempShowComponent({super.key});

  static void _noop() {}

  @override
  Widget build(BuildContext context) => FScaffold(
    header: const FHeader(title: Text('Buttons')),
    child: ListView(
      children: [
        _Section(
          title: 'Variants',
          children: [
            FButton(
              mainAxisSize: .min,
              onPress: _noop,
              child: const Text('Button'),
            ),
            FButton(
              mainAxisSize: .min,
              onPress: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              ),
              child: const Text('Open Home'),
            ),
          ],
        ),
        _Section(
          title: 'Variants',
          children: [
            FLineCalendar(
              style: const .delta(itemSpacing: 10),
              scrollCacheExtent: null,
              keyboardDismissBehavior: .manual,
              physics: null,
              selectable: (date) => true,
              builder: (context, data, child) => child!,
            ),
          ],
        ),
      ],
    ),
  );
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      crossAxisAlignment: .start,
      children: [
        Text(title, style: context.theme.typography.body.lg),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    ),
  );
}

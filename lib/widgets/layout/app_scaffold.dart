import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final VoidCallback? onAddEvent;

  const AppScaffold({super.key, required this.child, this.onAddEvent});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      // Without a header there is nothing holding content clear of the status
      // bar and dynamic island.
      child: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(bottom: false, child: child),

          if (onAddEvent != null) _BottomActionLayer(onAddEvent: onAddEvent!),
        ],
      ),
    );
  }
}

class _BottomActionLayer extends StatelessWidget {
  final VoidCallback onAddEvent;

  const _BottomActionLayer({required this.onAddEvent});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [_AddEventButton(onPress: onAddEvent)],
        ),
      ),
    );
  }
}

class _AddEventButton extends StatelessWidget {
  final VoidCallback onPress;

  const _AddEventButton({required this.onPress});

  @override
  Widget build(BuildContext context) {
    return FButton(
      onPress: onPress,
      prefix: const Icon(Icons.add, size: 18),
      child: const Text('Add Event'),
    );
  }
}

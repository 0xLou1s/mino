import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'package:mino/theme/theme.dart';
import 'package:mino/theme/styles/calendar_style.dart';

void main() {
  for (final (name, theme) in [('light', lightTheme), ('dark', darkTheme)]) {
    group('$name day tiles', () {
      final colors = theme.colors;
      final styles = calendarStyle(
        colors: colors,
        typography: theme.typography,
        icons: theme.icons,
        style: theme.style,
        hapticFeedback: theme.hapticFeedback,
        touch: true,
      ).dayPickerStyle.dayStyles;

      FCalendarDayStyle resolve(Set<FCalendarDayVariant> v) => styles.resolve(v);
      Color? fill(Set<FCalendarDayVariant> v) =>
          (resolve(v).foreground as ShapeDecoration).color;

      // Interaction states Forui defines a compound entry for. Each must keep
      // the look of its base state rather than falling back to the inherited
      // Forui styling.
      const interactions = <FCalendarDayVariant>[
        FCalendarDayVariant.hovered,
        FCalendarDayVariant.pressed,
        FCalendarDayVariant.focused,
      ];

      test('in-month days keep the muted tile', () {
        expect(fill({}), colors.muted);
        for (final i in interactions) {
          expect(fill({i}), colors.muted, reason: 'plain + $i');
        }
      });

      test('today keeps the muted tile and drops the underline', () {
        for (final extra in [<FCalendarDayVariant>{}, ...interactions.map((i) => {i})]) {
          final v = {FCalendarDayVariant.today, ...extra};
          expect(fill(v), colors.muted, reason: 'today + $extra');
          expect(
            resolve(v).textStyle.decoration,
            isNot(TextDecoration.underline),
            reason: 'today + $extra must not be underlined',
          );
        }
      });

      test('adjacent days stay bare', () {
        for (final extra in [<FCalendarDayVariant>{}, ...interactions.map((i) => {i})]) {
          final v = {FCalendarDayVariant.adjacent, ...extra};
          expect(fill(v), Colors.transparent, reason: 'adjacent + $extra');
        }
      });

      test('the selected day fills the whole tile', () {
        for (final extra in [<FCalendarDayVariant>{}, ...interactions.map((i) => {i})]) {
          final v = {FCalendarDayVariant.single, ...extra};
          expect(fill(v), colors.foreground, reason: 'single + $extra');
          expect(resolve(v).foreground, isA<ShapeDecoration>()
              .having((d) => d.shape, 'shape', isA<RoundedSuperellipseBorder>()));
        }
        // Selecting today must not fall back to today's unfilled tile.
        expect(
          fill({FCalendarDayVariant.single, FCalendarDayVariant.today}),
          colors.foreground,
        );
      });

      test('disabled days keep a tile', () {
        expect(fill({FCalendarDayVariant.disabled}), colors.muted);
      });
    });
  }
}

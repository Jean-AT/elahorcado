import 'package:ahorcado_hoja/src/hangman_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const List<double> responsiveWidths = <double>[320, 375, 414, 768];

  for (final double width in responsiveWidths) {
    testWidgets('renders without layout errors at ${width.toInt()} px', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const HangmanApp());
      await tester.pumpAndSettle();

      expect(find.text('AHORCADO'), findsOneWidget);
      expect(find.text('PISTA'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('accepts a letter and starts a new word', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const HangmanApp());
    await tester.tap(find.text('Q'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining(RegExp(r'(Bien|no está)')),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Nueva palabra'));
    await tester.pumpAndSettle();

    expect(find.text('Nueva palabra. ¡Tú puedes!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

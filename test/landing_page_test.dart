import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperwork_assistant/app/paperwork_assistant_app.dart';

void main() {
  testWidgets('Landingpage erklärt Ablauf und Beratungsausschluss', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const PaperworkAssistantApp());

    expect(find.text('Weniger Papierkram.\nMehr Klarheit.'), findsOneWidget);
    expect(find.text('Upload'), findsOneWidget);
    expect(find.text('Analyse'), findsOneWidget);
    expect(find.text('Fristen'), findsOneWidget);
    expect(find.text('Antwortvorbereitung'), findsOneWidget);
    expect(
      find.textContaining('ersetzt keine Rechts-, Steuer-'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Landingpage bleibt auf Smartphonebreite fehlerfrei', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const PaperworkAssistantApp());

    expect(find.text('Demo öffnen'), findsOneWidget);
    expect(find.text('Weniger Papierkram.\nMehr Klarheit.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

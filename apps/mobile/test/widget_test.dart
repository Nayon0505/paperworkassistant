import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperworkassistant/main.dart';

void main() {
  testWidgets('shows the English empty inbox and import actions', (
    tester,
  ) async {
    await tester.pumpWidget(const PaperworkAssistantApp(locale: Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Your inbox is empty'), findsOneWidget);
    expect(find.text('Import with camera'), findsOneWidget);
    expect(find.text('Import file'), findsOneWidget);
    expect(find.byKey(const Key('camera-import')), findsOneWidget);
    expect(find.byKey(const Key('file-import')), findsOneWidget);
  });

  testWidgets('shows the German empty inbox and import actions', (
    tester,
  ) async {
    await tester.pumpWidget(const PaperworkAssistantApp(locale: Locale('de')));
    await tester.pumpAndSettle();

    expect(find.text('Dein Posteingang ist leer'), findsOneWidget);
    expect(find.text('Mit Kamera importieren'), findsOneWidget);
    expect(find.text('Datei importieren'), findsOneWidget);
  });

  testWidgets('falls back to English for an unsupported locale', (
    tester,
  ) async {
    await tester.pumpWidget(const PaperworkAssistantApp(locale: Locale('fr')));
    await tester.pumpAndSettle();

    expect(find.text('Your inbox is empty'), findsOneWidget);
    expect(find.text('Dein Posteingang ist leer'), findsNothing);
  });
}

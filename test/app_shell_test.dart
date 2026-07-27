import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperwork_assistant/app/paperwork_assistant_app.dart';
import 'package:paperwork_assistant/app/routes/app_routes.dart';

void main() {
  testWidgets('Desktop zeigt alle deutschen Navigationsziele', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const PaperworkAssistantApp(initialRoute: AppRoutes.overview),
    );

    expect(find.byType(NavigationRail), findsOneWidget);
    for (final destination in AppRoutes.destinations) {
      expect(find.text(destination.label), findsWidgets);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Smartphone verwendet mobile Navigation', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const PaperworkAssistantApp(initialRoute: AppRoutes.overview),
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Dokumente'), findsOneWidget);
    expect(find.text('Aufgaben und Fristen'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final destination in AppRoutes.destinations) {
    testWidgets('${destination.label} ist als Route erreichbar', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        PaperworkAssistantApp(initialRoute: destination.path),
      );

      expect(find.text('${destination.label}: Seitengerüst'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

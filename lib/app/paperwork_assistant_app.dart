import 'package:flutter/material.dart';

import 'routes/app_router.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

class PaperworkAssistantApp extends StatelessWidget {
  const PaperworkAssistantApp({
    super.key,
    this.initialRoute = AppRoutes.landing,
  });

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paperwork Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}

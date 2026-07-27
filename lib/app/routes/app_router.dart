import 'package:flutter/material.dart';

import '../../features/landing/landing_page.dart';
import '../../features/shell/app_shell.dart';
import '../theme/app_spacing.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static Route<void> onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? AppRoutes.landing;

    if (routeName == AppRoutes.landing) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const LandingPage(),
      );
    }

    if (AppRoutes.isAppRoute(routeName)) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => AppShell(currentPath: routeName),
      );
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const _UnknownRoutePage(),
    );
  }
}

class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.explore_off_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Diese Seite gibt es noch nicht.',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.landing),
                child: const Text('Zur Startseite'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

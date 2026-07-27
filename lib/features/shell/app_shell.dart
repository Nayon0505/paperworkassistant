import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/widgets/brand_mark.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.currentPath});

  final String currentPath;

  int get _selectedIndex {
    final index = AppRoutes.destinations.indexWhere(
      (destination) => destination.path == currentPath,
    );
    return index < 0 ? 0 : index;
  }

  void _selectDestination(BuildContext context, int index) {
    final destination = AppRoutes.destinations[index];
    if (destination.path != currentPath) {
      Navigator.pushReplacementNamed(context, destination.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 840;
        final extended = constraints.maxWidth >= 1120;
        final destination = AppRoutes.destinations[_selectedIndex];

        return Scaffold(
          backgroundColor: AppColors.canvas,
          body: SafeArea(
            child: desktop
                ? Row(
                    children: [
                      NavigationRail(
                        extended: extended,
                        minExtendedWidth: 256,
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (index) =>
                            _selectDestination(context, index),
                        leading: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.xl,
                          ),
                          child: BrandMark(showWordmark: extended),
                        ),
                        trailing: Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.lg),
                          child: IconButton(
                            tooltip: 'Zur öffentlichen Startseite',
                            onPressed: () => Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.landing,
                            ),
                            icon: const Icon(Icons.logout_rounded),
                          ),
                        ),
                        destinations: [
                          for (final item in AppRoutes.destinations)
                            NavigationRailDestination(
                              icon: Icon(item.icon),
                              selectedIcon: Icon(item.selectedIcon),
                              label: Text(item.label),
                            ),
                        ],
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: _RouteContent(destination: destination)),
                    ],
                  )
                : _RouteContent(destination: destination, mobile: true),
          ),
          bottomNavigationBar: desktop
              ? null
              : NavigationBar(
                  selectedIndex: _selectedIndex,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  onDestinationSelected: (index) =>
                      _selectDestination(context, index),
                  destinations: [
                    for (final item in AppRoutes.destinations)
                      NavigationDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: item.label,
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class _RouteContent extends StatelessWidget {
  const _RouteContent({required this.destination, this.mobile = false});

  final AppDestination destination;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final copy = _RouteCopy.forPath(destination.path);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            color: AppColors.white,
            padding: EdgeInsets.fromLTRB(
              mobile ? AppSpacing.md : AppSpacing.xl,
              AppSpacing.md,
              mobile ? AppSpacing.md : AppSpacing.xl,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                if (mobile) ...[
                  const BrandMark(showWordmark: false),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Text(
                    destination.label,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const CircleAvatar(
                  backgroundColor: AppColors.green100,
                  foregroundColor: AppColors.green700,
                  child: Text(
                    'NN',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.all(mobile ? AppSpacing.md : AppSpacing.xl),
          sliver: SliverList.list(
            children: [
              Text(
                copy.eyebrow,
                style: const TextStyle(
                  color: AppColors.green700,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                copy.heading,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Text(
                  copy.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.green100,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        child: Icon(
                          destination.selectedIcon,
                          color: AppColors.green700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        '${destination.label}: Seitengerüst',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        copy.placeholder,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.navy50,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        child: const Text(
                          'MVP-Vorschau · Noch ohne Echtdaten',
                          style: TextStyle(
                            color: AppColors.navy800,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RouteCopy {
  const _RouteCopy({
    required this.eyebrow,
    required this.heading,
    required this.description,
    required this.placeholder,
  });

  final String eyebrow;
  final String heading;
  final String description;
  final String placeholder;

  static _RouteCopy forPath(String path) {
    return switch (path) {
      AppRoutes.documents => const _RouteCopy(
        eyebrow: 'DOKUMENTE',
        heading: 'Deine Schreiben an einem Ort.',
        description:
            'Hier werden künftig hochgeladene Dokumente und ihr Bearbeitungsstand übersichtlich dargestellt.',
        placeholder:
            'Dokumentenliste, Upload und Detailansicht werden in späteren Verträgen ergänzt.',
      ),
      AppRoutes.tasks => const _RouteCopy(
        eyebrow: 'AUFGABEN UND FRISTEN',
        heading: 'Wissen, was als Nächstes zählt.',
        description:
            'Anstehende Aufgaben und erkannte Fristen erhalten hier eine gemeinsame, verständliche Übersicht.',
        placeholder:
            'Fristenliste, Erinnerungen und Aufgabenstatus folgen in späteren Verträgen.',
      ),
      AppRoutes.profile => const _RouteCopy(
        eyebrow: 'PROFIL',
        heading: 'Deine Angaben im Blick.',
        description:
            'Dieser Bereich ist für persönliche Angaben und die Verwaltung des Kontos vorgesehen.',
        placeholder:
            'Profildaten und echte Kontofunktionen folgen zusammen mit der Authentifizierung.',
      ),
      AppRoutes.settings => const _RouteCopy(
        eyebrow: 'EINSTELLUNGEN',
        heading: 'Die Anwendung passend einstellen.',
        description:
            'Hier entstehen später Einstellungen für Darstellung, Benachrichtigungen und Datenschutz.',
        placeholder:
            'Einstellungsoptionen werden ergänzt, sobald die zugehörigen Funktionen umgesetzt sind.',
      ),
      _ => const _RouteCopy(
        eyebrow: 'ÜBERSICHT',
        heading: 'Guten Tag. Was liegt heute an?',
        description:
            'Die Übersicht wird zum Ausgangspunkt für Dokumente, offene Aufgaben und wichtige Fristen.',
        placeholder:
            'Zusammenfassungen und Schnellaktionen werden mit den jeweiligen Fachfunktionen ergänzt.',
      ),
    };
  }
}

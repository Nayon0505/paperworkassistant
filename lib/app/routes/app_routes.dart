import 'package:flutter/material.dart';

class AppDestination {
  const AppDestination({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

abstract final class AppRoutes {
  static const landing = '/';
  static const overview = '/app/overview';
  static const documents = '/app/documents';
  static const tasks = '/app/tasks';
  static const profile = '/app/profile';
  static const settings = '/app/settings';

  static const destinations = <AppDestination>[
    AppDestination(
      path: overview,
      label: 'Übersicht',
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded,
    ),
    AppDestination(
      path: documents,
      label: 'Dokumente',
      icon: Icons.description_outlined,
      selectedIcon: Icons.description_rounded,
    ),
    AppDestination(
      path: tasks,
      label: 'Aufgaben und Fristen',
      icon: Icons.event_note_outlined,
      selectedIcon: Icons.event_note_rounded,
    ),
    AppDestination(
      path: profile,
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
    AppDestination(
      path: settings,
      label: 'Einstellungen',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
    ),
  ];

  static bool isAppRoute(String? path) {
    return destinations.any((destination) => destination.path == path);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_mode_provider.dart';

/// Bottom navigation shell que muestra diferentes tabs segun el modo activo.
///
/// Modo Cliente:  Inicio, Buscar, Servicios, Avisos, Perfil  (branches 0,1,2,6,7)
/// Modo Proveedor: Dashboard, Mis Servicios, Solicitudes, Avisos, Perfil (branches 3,4,5,6,7)
class ScaffoldWithNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  // Branch indices for each mode
  static const _clientBranches = [0, 1, 2, 6, 7];
  static const _providerBranches = [3, 4, 5, 6, 7];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isProvider = ref.watch(isProviderModeProvider);
    final branches = isProvider ? _providerBranches : _clientBranches;

    // Map the actual branch index to visible tab index
    final currentBranch = navigationShell.currentIndex;
    var tabIndex = branches.indexOf(currentBranch);
    if (tabIndex < 0) tabIndex = 0; // fallback to first tab

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabIndex,
        onTap: (index) {
          final branchIndex = branches[index];
          navigationShell.goBranch(
            branchIndex,
            initialLocation: branchIndex != navigationShell.currentIndex,
          );
        },
        items: isProvider ? _providerItems : _clientItems,
      ),
    );
  }

  static const _clientItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Inicio',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search_outlined),
      activeIcon: Icon(Icons.search),
      label: 'Buscar',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today_outlined),
      activeIcon: Icon(Icons.calendar_today),
      label: 'Servicios',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.notifications_outlined),
      activeIcon: Icon(Icons.notifications),
      label: 'Avisos',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Perfil',
    ),
  ];

  static const _providerItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_outlined),
      activeIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.handyman_outlined),
      activeIcon: Icon(Icons.handyman),
      label: 'Servicios',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.inbox_outlined),
      activeIcon: Icon(Icons.inbox),
      label: 'Solicitudes',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.notifications_outlined),
      activeIcon: Icon(Icons.notifications),
      label: 'Avisos',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Perfil',
    ),
  ];
}

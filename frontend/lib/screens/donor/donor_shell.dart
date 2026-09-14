import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DonorShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const DonorShell({
    super.key,
    required this.navigationShell,
  });

  void _onDestinationSelected(
      int index,
      ) {
    navigationShell.goBranch(
      index,
      initialLocation:
      index ==
          navigationShell.currentIndex,
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar:
      NavigationBar(
        selectedIndex:
        navigationShell.currentIndex,
        onDestinationSelected:
        _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.inventory_2_outlined,
            ),
            selectedIcon: Icon(
              Icons.inventory_2,
            ),
            label: 'Donations',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon: Icon(
              Icons.person,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
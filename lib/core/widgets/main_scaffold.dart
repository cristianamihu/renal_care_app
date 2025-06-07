import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({required this.child, super.key});

  static const _tabs = <_TabItem>[
    _TabItem(label: 'Appointments', icon: Icons.event, path: '/appointments'),
    _TabItem(label: 'Medication', icon: Icons.medication, path: '/medications'),
    _TabItem(label: 'Home', icon: Icons.home, path: '/home'),
    _TabItem(label: 'Journal', icon: Icons.note_alt, path: '/journal'),
    //_TabItem(label: 'Aliments', icon: Icons.restaurant, path: '/aliments'),
    _TabItem(label: 'Profile', icon: Icons.account_circle, path: '/profile'),
  ];

  int _locationToIndex(String location) {
    if (location.startsWith('/emergency')) return -1;
    final idx = _tabs.indexWhere((t) => location.startsWith(t.path));
    return idx < 0 ? 2 : idx; // default Home daca nu găsește
  }

  @override
  Widget build(BuildContext context) {
    final String loc = GoRouter.of(context).state.uri.path;
    final currentIndex = _locationToIndex(loc);

    return Scaffold(
      body: child,
      bottomNavigationBar:
          currentIndex < 0
              ? null
              : BottomNavigationBar(
                backgroundColor: AppColors.backgroundColor,
                selectedItemColor: AppColors.gradient3,
                unselectedItemColor: AppColors.whiteColor.withValues(
                  alpha: 0.6,
                ),
                currentIndex: currentIndex,
                onTap: (i) {
                  if (i != currentIndex) {
                    context.go(_tabs[i].path);
                  }
                },
                items:
                    _tabs
                        .map(
                          (t) => BottomNavigationBarItem(
                            icon: Icon(t.icon),
                            label: t.label,
                          ),
                        )
                        .toList(),
              ),
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  final String path;
  const _TabItem({required this.label, required this.icon, required this.path});
}

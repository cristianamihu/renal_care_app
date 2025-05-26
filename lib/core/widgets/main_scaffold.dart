import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({required this.child, super.key});

  static const _tabs = <_TabItem>[
    _TabItem(label: 'Today', icon: Icons.today, path: '/today'),
    _TabItem(label: 'History', icon: Icons.bar_chart, path: '/history'),
    _TabItem(label: 'Home', icon: Icons.home, path: '/home'),
    _TabItem(label: 'Cabinet', icon: Icons.medical_services, path: '/cabinet'),
    _TabItem(label: 'More', icon: Icons.more_horiz, path: '/more'),
  ];

  int _locationToIndex(String location) {
    final idx = _tabs.indexWhere((t) => location.startsWith(t.path));
    return idx < 0 ? 2 : idx; // default Home daca nu găsește
  }

  @override
  Widget build(BuildContext context) {
    final String loc = GoRouter.of(context).state.uri.path;
    final currentIndex = _locationToIndex(loc);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.backgroundColor,
        selectedItemColor: AppColors.gradient1,
        unselectedItemColor: AppColors.whiteColor.withValues(alpha: 0.6),
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

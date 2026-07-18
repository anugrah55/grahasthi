import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import 'home/home_screen.dart';
import 'trackers/trackers_list_screen.dart';
import 'reports/reports_screen.dart';
import 'settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TrackersListScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Listen to language changes to rebuild
    context.watch<LanguageProvider>();
    final t = AppLocalizations.t;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: GrahasthiTheme.cardBorder, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              activeIcon: const Icon(Icons.home_rounded),
              label: t('nav_home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.grid_view_rounded),
              activeIcon: const Icon(Icons.grid_view_rounded),
              label: t('nav_trackers'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart_rounded),
              activeIcon: const Icon(Icons.bar_chart_rounded),
              label: t('nav_reports'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_rounded),
              activeIcon: const Icon(Icons.settings_rounded),
              label: t('nav_settings'),
            ),
          ],
        ),
      ),
    );
  }
}

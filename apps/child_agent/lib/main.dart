import 'package:flutter/material.dart';

import 'screens/activity_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/child_home_screen.dart';
import 'screens/my_apps_screen.dart';
import 'screens/pairing_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'theme.dart';

void main() {
  runApp(const GuardianLensChildApp());
}

class GuardianLensChildApp extends StatelessWidget {
  const GuardianLensChildApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeMode.notifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'GuardianLens',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: const ChildAppRoot(),
        );
      },
    );
  }
}

class ChildAppRoot extends StatefulWidget {
  const ChildAppRoot({super.key});

  @override
  State<ChildAppRoot> createState() => _ChildAppRootState();
}

class _ChildAppRootState extends State<ChildAppRoot> {
  int _currentIndex = 0;

  bool _paired = false;

  void _goTo(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _completePairing() {
    setState(() {
      _paired = true;
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ------------------------------------------------------------
    // FIRST-TIME EXPERIENCE
    // ------------------------------------------------------------
    if (!_paired) {
      return PairingScreen(
        onPaired: _completePairing,
      );
    }

    // ------------------------------------------------------------
    // NORMAL CHILD APP
    // ------------------------------------------------------------
    final colors = context.colors;

    Widget screen;

    switch (_currentIndex) {
      case 0:
        screen = ChildHomeScreen(
          onApps: () => _goTo(1),
          onActivity: () => _goTo(2),
          onAlerts: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AlertsScreen(
                  onBack: () => Navigator.pop(context),
                ),
              ),
            );
          },
          onProfile: () => _goTo(3),
        );
        break;

      case 1:
        screen = MyAppsScreen(
          onBack: () => _goTo(0),
        );
        break;

      case 2:
        screen = ActivityScreen(
          onBack: () => _goTo(0),
        );
        break;

      case 3:
        screen = ChildProfileScreen(
          onBack: () => _goTo(0),
          onSettings: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChildSettingsScreen(
                  onBack: () => Navigator.pop(context),
                ),
              ),
            );
          },
        );
        break;

      default:
        screen = const SizedBox();
    }

    return Scaffold(
      body: screen,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _goTo,
        backgroundColor: colors.cardBackground,
        indicatorColor: colors.paleBlueSurface,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.apps_outlined),
            selectedIcon: Icon(Icons.apps),
            label: 'Apps',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
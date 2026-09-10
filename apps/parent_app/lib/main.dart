import 'package:flutter/material.dart';

import 'models.dart';
import 'screens/alerts_screen.dart';
import 'screens/alert_detail_screen.dart';
import 'screens/app_detail_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/devices_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/history_screen.dart';
import 'screens/legal_screen.dart';
import 'screens/login_screen.dart';
import 'screens/monitoring_screen.dart';
import 'screens/pairing_result_screens.dart';
import 'screens/pairing_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/security_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/settings_sub_screens.dart';
import 'screens/signup_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme.dart';

void main() {
  runApp(const GuardianLensApp());
}

class GuardianLensApp extends StatelessWidget {
  const GuardianLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeMode.notifier,
      builder: (context, mode, _) => MaterialApp(
        title: 'GuardianLens',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode,
        home: const AppRoot(),
      ),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

enum _Screen {
  welcome,
  login,
  signup,
  devices,
  dashboard,
  monitoring,
  appDetail,
  alerts,
  alertDetail,
  history,
  settings,
  settingsDevices,
  settingsNotifications,
  settingsPrivacy,
  pairing,
  pairingSuccess,
  pairingFailed,
  forgotPassword,
  legalPrivacyPolicy,
  legalTermsOfService,
  profile,
  security,
}

class _AppRootState extends State<AppRoot> {
  _Screen _screen = _Screen.welcome;
  _Screen _referrer = _Screen.settings;

  bool _paired = false;
  List<MonitoredApp> _apps = initialApps();
  String _selectedAppName = 'YouTube';
  String _selectedAlertId = 'youtube';

  List<AlertItem> get _alerts => initialAlerts();
  List<HistoryEntry> get _history => initialHistory();

  void _go(_Screen screen) => setState(() => _screen = screen);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.pageBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 500;
          Widget content = AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: _screenTransition,
            child: KeyedSubtree(
              key: ValueKey(_screen),
              child: _buildScreen(),
            ),
          );
          if (!wide) return content;
          return Center(
            child: Container(
              width: 390,
              height: constraints.maxHeight - 48,
              margin: const EdgeInsets.symmetric(vertical: 24),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: context.colors.cardBackground,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [AppShadows.phoneFrame],
              ),
              child: content,
            ),
          );
        },
      ),
    );
  }

  Widget _screenTransition(Widget child, Animation<double> animation) {
    final offset = Tween<Offset>(
      begin: const Offset(0.05, 0.07),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: offset, child: child),
    );
  }

  Widget _buildScreen() {
    switch (_screen) {
      case _Screen.welcome:
        return WelcomeScreen(
          onGetStarted: () => _go(_Screen.signup),
          onLogin: () => _go(_Screen.login),
        );

      case _Screen.login:
        return _SimpleBackShell(
          onBack: () => _go(_Screen.welcome),
          child: LoginScreen(
            onSubmit: () => _go(_Screen.devices),
            onSignUp: () => _go(_Screen.signup),
            onForgotPassword: () => _go(_Screen.forgotPassword),
          ),
        );

      case _Screen.signup:
        return _SimpleBackShell(
          onBack: () => _go(_Screen.welcome),
          child: SignupScreen(
            onSubmit: () => _go(_Screen.devices),
            onLogin: () => _go(_Screen.login),
            onTerms: () { _referrer = _Screen.signup; _go(_Screen.legalTermsOfService); },
            onPrivacy: () { _referrer = _Screen.signup; _go(_Screen.legalPrivacyPolicy); },
          ),
        );

      case _Screen.devices:
        return DevicesScreen(
          paired: _paired,
          onAddDevice: () => _go(_Screen.pairing),
          onDashboard: () => _go(_Screen.dashboard),
          onBack: () {
            setState(() {
              _paired = false;
              _apps = initialApps();
            });
            _go(_Screen.welcome);
          },
        );

      case _Screen.dashboard:
        return DashboardScreen(
          paired: _paired,
          onAddDevice: () => _go(_Screen.pairing),
          onDevices: () => _go(_Screen.devices),
          onMonitoring: () => _go(_Screen.monitoring),
          onAlerts: () => _go(_Screen.alerts),
          onHistory: () => _go(_Screen.history),
          onSettings: () => _go(_Screen.settings),
        );

      case _Screen.alerts:
        return AlertsScreen(
          alerts: _alerts,
          onSelectAlert: (id) {
            _selectedAlertId = id;
            _go(_Screen.alertDetail);
          },
          onBack: () => _go(_Screen.dashboard),
        );

      case _Screen.alertDetail:
        return AlertDetailScreen(
          alert: _alerts.firstWhere((a) => a.id == _selectedAlertId, orElse: () => _alerts.first),
          onBack: () => _go(_Screen.alerts),
        );

      case _Screen.history:
        return HistoryScreen(
          history: _history,
          onSelectAlert: (id) {
            _selectedAlertId = id;
            _go(_Screen.alertDetail);
          },
          onBack: () => _go(_Screen.dashboard),
        );

      case _Screen.monitoring:
        return MonitoringScreen(
          apps: _apps,
          onAppsChange: (updated) => setState(() => _apps = updated),
          onSelectApp: (name) {
            _selectedAppName = name;
            _go(_Screen.appDetail);
          },
          onBack: () => _go(_Screen.dashboard),
        );

      case _Screen.appDetail:
        final app = _apps.firstWhere((a) => a.name == _selectedAppName, orElse: () => _apps.first);
        return AppDetailScreen(
          app: app,
          onChange: (updated) => setState(() {
            _apps = _apps.map((a) => a.name == updated.name ? updated : a).toList();
          }),
          onBack: () => _go(_Screen.monitoring),
        );

      case _Screen.settings:
        return SettingsScreen(
          paired: _paired,
          onDevices: () => _go(_Screen.settingsDevices),
          onNotifications: () => _go(_Screen.settingsNotifications),
          onPrivacy: () => _go(_Screen.settingsPrivacy),
          onProfile: () => _go(_Screen.profile),
          onTerms: () => _go(_Screen.legalTermsOfService),
          onPrivacyPolicy: () => _go(_Screen.legalPrivacyPolicy),
          onSecurity: () => _go(_Screen.security),
          onSignOut: () {
            setState(() {
              _paired = false;
              _apps = initialApps();
            });
            _go(_Screen.welcome);
          },
          onBack: () => _go(_Screen.dashboard),
        );

      case _Screen.settingsDevices:
        return SettingsDevicesScreen(
          paired: _paired,
          onAddDevice: () => _go(_Screen.pairing),
          onBack: () => _go(_Screen.settings),
        );

      case _Screen.settingsNotifications:
        return NotificationSettingsScreen(
          onBack: () => _go(_Screen.settings),
        );

      case _Screen.settingsPrivacy:
        return PrivacySettingsScreen(
          onBack: () => _go(_Screen.settings),
        );

      case _Screen.pairing:
        return PairingScreen(
          onSuccess: () => _go(_Screen.pairingSuccess),
          onExpired: () => _go(_Screen.pairingFailed),
          onGenerate: (_) {},
        );

      case _Screen.pairingSuccess:
        return PairingSuccessScreen(
          onDashboard: () {
            setState(() => _paired = true);
            _go(_Screen.dashboard);
          },
        );

      case _Screen.pairingFailed:
        return PairingFailedScreen(
          onTryAgain: () => _go(_Screen.pairing),
          onDevices: () => _go(_Screen.devices),
        );

      case _Screen.forgotPassword:
        return _SimpleBackShell(
          onBack: () => _go(_Screen.login),
          child: ForgotPasswordScreen(onBack: () => _go(_Screen.login)),
        );

      case _Screen.legalPrivacyPolicy:
        return _SimpleBackShell(
          onBack: () => _go(_referrer),
          child: LegalScreen(
            title: 'Privacy Policy',
            updated: 'September 2026',
            sections: privacyPolicySections,
            onBack: () => _go(_referrer),
          ),
        );

      case _Screen.legalTermsOfService:
        return _SimpleBackShell(
          onBack: () => _go(_referrer),
          child: LegalScreen(
            title: 'Terms of Service',
            updated: 'September 2026',
            sections: termsOfServiceSections,
            onBack: () => _go(_referrer),
          ),
        );

      case _Screen.profile:
        return ProfileScreen(onBack: () => _go(_Screen.settings));

      case _Screen.security:
        return SecurityScreen(onBack: () => _go(_Screen.settings));
    }
  }
}

class _SimpleBackShell extends StatelessWidget {
  const _SimpleBackShell({required this.onBack, required this.child});

  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 24,
          left: 24,
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(Icons.arrow_back, size: 20, color: context.colors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}
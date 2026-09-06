import 'package:flutter/material.dart';

import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({
    super.key,
    required this.paired,
    required this.onDevices,
    required this.onNotifications,
    required this.onPrivacy,
    required this.onBack,
  });

  final bool paired;
  final VoidCallback onDevices;
  final VoidCallback onNotifications;
  final VoidCallback onPrivacy;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _BackButton(onTap: onBack),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GuardianLens',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: context.colors.textFaint),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.04,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.blueSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person_outline, size: 20, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Menhya Joshua',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'menhya.joshua@example.com',
                          style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _SettingsSection(
              title: 'Account',
              children: [
                _SettingsRow(icon: Icons.person_outline, title: 'Profile information', detail: 'Name and email address'),
                _SettingsRow(icon: Icons.lock_outline, title: 'Password & security', detail: 'Keep your account secure'),
              ],
            ),
            _SettingsSection(
              title: 'Device management',
              children: [
                _SettingsRow(
                  icon: Icons.smartphone,
                  title: 'Paired devices',
                  detail: paired ? "Alex's iPhone \u00b7 Connected" : 'No devices connected',
                  onTap: onDevices,
                ),
              ],
            ),
            _SettingsSection(
              title: 'Notifications',
              children: [
                _SettingsRow(
                  icon: Icons.notifications_none,
                  title: 'Notification preferences',
                  detail: 'Alerts and weekly summaries',
                  onTap: onNotifications,
                ),
              ],
            ),
            _SettingsSection(
              title: 'Appearance',
              children: const [
                _ThemeRow(),
              ],
            ),
            _SettingsSection(
              title: 'Privacy & legal',
              children: [
                _SettingsRow(
                  icon: Icons.shield_outlined,
                  title: 'Data & privacy',
                  detail: 'Manage data and monitoring',
                  onTap: onPrivacy,
                ),
                _SettingsRow(
                  icon: Icons.article_outlined,
                  title: 'Terms of Service',
                ),
                _SettingsRow(
                  icon: Icons.lock_outline,
                  title: 'Privacy Policy',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.primaryBlueLight,
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: context.colors.cardBackground,
              border: Border.all(color: context.colors.borderSubtle),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    Divider(height: 1, color: context.colors.borderSubtle),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  _SettingsRow({
    required this.icon,
    required this.title,
    this.detail,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: context.colors.paleBlueSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 15,
                color: AppColors.primaryBlueLight,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  if (detail != null) ...[
                    SizedBox(height: 2),
                    Text(
                      detail!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10, color: context.colors.textFaint),
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, size: 15, color: context.colors.chevronGrey),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(Icons.arrow_back, size: 20, color: context.colors.textSecondary),
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeMode.notifier,
      builder: (context, mode, _) {
        final detail = switch (mode) {
          ThemeMode.system => 'Follows your device setting',
          ThemeMode.light => 'Always light',
          ThemeMode.dark => 'Always dark',
        };
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: context.colors.paleBlueSurface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                      size: 15,
                      color: AppColors.primaryBlueLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Theme',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10, color: context.colors.textFaint),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, label: Text('System', style: TextStyle(fontSize: 11))),
                    ButtonSegment(value: ThemeMode.light, label: Text('Light', style: TextStyle(fontSize: 11))),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark', style: TextStyle(fontSize: 11))),
                  ],
                  selected: {mode},
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 11)),
                    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 8, horizontal: 10)),
                  ),
                  onSelectionChanged: (selection) => AppThemeMode.notifier.value = selection.first,
                ),
              ),
            ],
          ),
);
      },
    );
  }
}

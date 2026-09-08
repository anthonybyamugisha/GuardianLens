import 'package:flutter/material.dart';

import 'theme.dart';

enum Sensitivity { low, balanced, strict }

extension SensitivityLabel on Sensitivity {
  String get label => switch (this) {
        Sensitivity.low => 'Low',
        Sensitivity.balanced => 'Balanced',
        Sensitivity.strict => 'Strict',
      };

  String get description => switch (this) {
        Sensitivity.low => 'Only clearly risky content is flagged.',
        Sensitivity.balanced => 'Recommended - catches most risky content.',
        Sensitivity.strict => 'Flags anything that might be risky.',
      };
}

enum Severity { high, medium, low }

extension SeverityColors on Severity {
  Color get color => switch (this) {
        Severity.high => AppColors.dangerRed,
        Severity.medium => AppColors.warningOrange,
        Severity.low => AppColors.primaryBlueLight,
      };

  Color background(AppPalette palette) => switch (this) {
        Severity.high => palette.paleRedSurface,
        Severity.medium => palette.paleOrangeSurface,
        Severity.low => palette.paleBlueSurface,
      };
}

enum HistoryCategory { alert, activity }

class MonitoredApp {
  final String name;
  final String description;
  final bool enabled;
  final Sensitivity sensitivity;
  final Color accentColor;
  final IconData icon;

  const MonitoredApp({
    required this.name,
    required this.description,
    required this.enabled,
    required this.sensitivity,
    required this.accentColor,
    required this.icon,
  });

  MonitoredApp copyWith({
    String? name,
    String? description,
    bool? enabled,
    Sensitivity? sensitivity,
  }) {
    return MonitoredApp(
      name: name ?? this.name,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
      sensitivity: sensitivity ?? this.sensitivity,
      accentColor: accentColor,
      icon: icon,
    );
  }
}

class AlertItem {
  final String id;
  final String app;
  final String title;
  final String detail;
  final String time;
  final Severity severity;
  final IconData icon;
  final Color accentColor;

  const AlertItem({
    required this.id,
    required this.app,
    required this.title,
    required this.detail,
    required this.time,
    required this.severity,
    required this.icon,
    required this.accentColor,
  });
}

class HistoryEntry {
  final String id;
  final String app;
  final String event;
  final String detail;
  final String time;
  final String date;
  final HistoryCategory category;
  final IconData icon;
  final Color accentColor;
  final String? alertId;

  const HistoryEntry({
    required this.id,
    required this.app,
    required this.event,
    required this.detail,
    required this.time,
    required this.date,
    required this.category,
    required this.icon,
    required this.accentColor,
    this.alertId,
  });
}

List<MonitoredApp> initialApps() => const [
      MonitoredApp(
        name: 'YouTube',
        description: 'Video and content platform',
        enabled: true,
        sensitivity: Sensitivity.balanced,
        accentColor: AppColors.dangerRed,
        icon: Icons.play_circle_fill,
      ),
      MonitoredApp(
        name: 'TikTok',
        description: 'Short-form video platform',
        enabled: true,
        sensitivity: Sensitivity.balanced,
        accentColor: AppColors.purpleAccent,
        icon: Icons.music_note,
      ),
      MonitoredApp(
        name: 'Instagram',
        description: 'Photos, reels, and messages',
        enabled: false,
        sensitivity: Sensitivity.balanced,
        accentColor: AppColors.warningOrange,
        icon: Icons.photo_camera,
      ),
      MonitoredApp(
        name: 'Browser',
        description: 'Web browsing activity',
        enabled: true,
        sensitivity: Sensitivity.balanced,
        accentColor: AppColors.primaryBlueLight,
        icon: Icons.public,
      ),
      MonitoredApp(
        name: 'Discord',
        description: 'Chat and communities',
        enabled: false,
        sensitivity: Sensitivity.balanced,
        accentColor: AppColors.successGreen,
        icon: Icons.chat_bubble,
      ),
    ];

List<AlertItem> initialAlerts() => const [
      AlertItem(
        id: 'youtube',
        app: 'YouTube',
        title: 'Adult Content Detected',
        detail:
            'Automated scan flagged a video title and description attempting to bypass content filters.',
        time: 'Today, 3:45 PM',
        severity: Severity.high,
        icon: Icons.visibility,
        accentColor: AppColors.dangerRed,
      ),
      AlertItem(
        id: 'discord',
        app: 'Discord',
        title: 'Harsh Language',
        detail:
            'Elevated use of profanity detected in a direct message. No direct threats identified.',
        time: 'Today, 1:15 PM',
        severity: Severity.medium,
        icon: Icons.chat_bubble,
        accentColor: AppColors.purpleAccent,
      ),
      AlertItem(
        id: 'browser',
        app: 'Browser',
        title: 'Late Night Browsing',
        detail: 'Device usage detected 50 minutes past the scheduled bedtime.',
        time: 'Yesterday, 8:30 PM',
        severity: Severity.low,
        icon: Icons.public,
        accentColor: AppColors.primaryBlueLight,
      ),
    ];

List<HistoryEntry> initialHistory() => const [
      HistoryEntry(
        id: 'history-youtube',
        app: 'YouTube',
        event: 'Harsh Language',
        detail: 'Automated flag based on captions detected in a video.',
        time: '3:42 PM',
        date: 'Today',
        category: HistoryCategory.alert,
        icon: Icons.visibility,
        accentColor: AppColors.dangerRed,
        alertId: 'discord',
      ),
      HistoryEntry(
        id: 'history-safari',
        app: 'Safari',
        event: 'Late Access',
        detail: 'Browsing outside usual scheduled hours.',
        time: '8:30 PM',
        date: 'Yesterday',
        category: HistoryCategory.activity,
        icon: Icons.public,
        accentColor: AppColors.successGreen,
      ),
    ];
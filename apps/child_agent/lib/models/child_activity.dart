import 'package:flutter/material.dart';
import '../theme.dart';

enum ActivityType {
  safe,
  warning,
  alert,
}

class ChildActivity {
  final String app;
  final String title;
  final String detail;
  final String time;
  final ActivityType type;
  final IconData icon;

  const ChildActivity({
    required this.app,
    required this.title,
    required this.detail,
    required this.time,
    required this.type,
    required this.icon,
  });

  Color get color {
    switch (type) {
      case ActivityType.safe:
        return AppColors.successGreen;
      case ActivityType.warning:
        return AppColors.warningOrange;
      case ActivityType.alert:
        return AppColors.dangerRed;
    }
  }
}

final List<ChildActivity> childActivities = [
  ChildActivity(
    app: 'YouTube',
    title: 'Content checked',
    detail: 'Your activity was checked by GuardianLens.',
    time: '3:45 PM',
    type: ActivityType.warning,
    icon: Icons.visibility,
  ),
  ChildActivity(
    app: 'Browser',
    title: 'Safe browsing',
    detail: 'No problems detected.',
    time: '2:30 PM',
    type: ActivityType.safe,
    icon: Icons.check_circle,
  ),
  ChildActivity(
    app: 'TikTok',
    title: 'Activity checked',
    detail: 'Your recent activity was reviewed.',
    time: '1:15 PM',
    type: ActivityType.safe,
    icon: Icons.music_note,
  ),
  ChildActivity(
    app: 'Instagram',
    title: 'Safety reminder',
    detail: 'Remember to keep your account private.',
    time: 'Yesterday',
    type: ActivityType.warning,
    icon: Icons.security,
  ),
];
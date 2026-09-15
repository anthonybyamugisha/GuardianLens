import 'package:flutter/material.dart';
import '../theme.dart';

class ChildApp {
  final String name;
  final String description;
  final bool monitored;
  final Color accentColor;
  final IconData icon;

  const ChildApp({
    required this.name,
    required this.description,
    required this.monitored,
    required this.accentColor,
    required this.icon,
  });
}

final List<ChildApp> childApps = [
  ChildApp(
    name: 'YouTube',
    description: 'Videos and entertainment',
    monitored: true,
    accentColor: AppColors.dangerRed,
    icon: Icons.play_circle_fill,
  ),
  ChildApp(
    name: 'TikTok',
    description: 'Short videos',
    monitored: true,
    accentColor: AppColors.purpleAccent,
    icon: Icons.music_note,
  ),
  ChildApp(
    name: 'Instagram',
    description: 'Photos and messages',
    monitored: true,
    accentColor: AppColors.warningOrange,
    icon: Icons.camera_alt,
  ),
  ChildApp(
    name: 'Browser',
    description: 'Web browsing',
    monitored: true,
    accentColor: AppColors.primaryBlueLight,
    icon: Icons.public,
  ),
  ChildApp(
    name: 'Discord',
    description: 'Chat and communities',
    monitored: false,
    accentColor: AppColors.successGreen,
    icon: Icons.chat_bubble,
  ),
];
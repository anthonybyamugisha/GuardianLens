import 'package:flutter/material.dart';
import '../theme.dart';

class ChildProfileScreen extends StatelessWidget {
  const ChildProfileScreen({
    super.key,
    required this.onBack,
    required this.onSettings,
  });

  final VoidCallback onBack;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: Icon(
                      Icons.arrow_back,
                      color: colors.textSecondary,
                    ),
                  ),
                  Text(
                    'My Profile',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            CircleAvatar(
              radius: 46,
              backgroundColor: AppColors.primaryBlue,
              child: const Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Alex',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'GuardianLens child account',
              style: TextStyle(
                color: colors.textSecondary,
              ),
            ),

            const SizedBox(height: 35),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ProfileItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: onSettings,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colors.borderSubtle,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colors.chevronGrey,
            ),
          ],
        ),
      ),
    );
  }
}
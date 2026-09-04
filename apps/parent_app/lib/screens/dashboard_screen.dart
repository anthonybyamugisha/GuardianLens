import 'package:flutter/material.dart';

import '../theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.paired,
    required this.onAddDevice,
    required this.onDevices,
    required this.onMonitoring,
    required this.onAlerts,
    required this.onHistory,
    required this.onSettings,
  });

  final bool paired;
  final VoidCallback onAddDevice;
  final VoidCallback onDevices;
  final VoidCallback onMonitoring;
  final VoidCallback onAlerts;
  final VoidCallback onHistory;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'GuardianLens',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textFaint),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.04,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onAlerts,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceFill,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Icon(Icons.notifications_none, size: 17, color: AppColors.textSecondary),
                      ),
                      const Positioned(
                        top: -2,
                        right: -2,
                        child: CircleAvatar(radius: 4, backgroundColor: AppColors.dangerRedLight),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline, size: 17, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: paired ? const _DashboardData() : _DashboardEmpty(onAddDevice: onAddDevice),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: Row(
                children: [
                  _DashboardNavItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    active: true,
                    onTap: () {},
                  ),
                  _DashboardNavItem(icon: Icons.notifications_none, label: 'Alerts', onTap: onAlerts),
                  _DashboardNavItem(icon: Icons.history, label: 'History', onTap: onHistory),
                  _DashboardNavItem(icon: Icons.tune, label: 'Monitoring', onTap: onMonitoring),
                  _DashboardNavItem(icon: Icons.settings_outlined, label: 'Settings', onTap: onSettings),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardNavItem extends StatelessWidget {
  const _DashboardNavItem({
    required this.icon,
    required this.label,
    this.active = false,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: active ? AppColors.primaryBlue : AppColors.textFaint),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.primaryBlue : AppColors.textFaint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardEmpty extends StatelessWidget {
  const _DashboardEmpty({required this.onAddDevice});

  final VoidCallback onAddDevice;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.paleBlueSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.people_outline, color: AppColors.primaryBlueLight, size: 30),
          ),
          const SizedBox(height: 24),
          const Text(
            'No devices yet',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.035,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Connect your child\u2019s device to see monitoring status and activity here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onAddDevice,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: const Icon(Icons.add, size: 17),
            label: const Text('Add a child device', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _DashboardData extends StatelessWidget {
  const _DashboardData();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -40,
                right: -32,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: const BoxDecoration(
                    color: Color(0x1AFFFFFF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All Clear',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xBFFFFFFF)),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Monitoring is active and quiet.',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0x26FFFFFF),
                        child: Icon(Icons.shield_outlined, size: 19, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Happy Monitoring Bro',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications_none, size: 17, color: AppColors.successGreen),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.paleGreenBadge,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Today',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.successGreen),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '0',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const Text(
                      'New Alerts',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Nothing flagged.',
                      style: TextStyle(fontSize: 10, color: AppColors.textFaint),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.smartphone, size: 17, color: AppColors.primaryBlueLight),
                        Spacer(),
                        Text(
                          '● Online',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.successGreen),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Alex\u2019s iPhone',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Last synced: 2m ago',
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [AppShadows.card],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Activity Summary',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ),
                  Text(
                    'View all \u203a',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const _ActivityRow(
                icon: Icons.schedule,
                title: 'Screen time update',
                detail: '2h 15m used today. Well within limits.',
                time: '10:30 AM',
              ),
              const SizedBox(height: 12),
              const _ActivityRow(
                icon: Icons.check_circle_outline,
                title: 'Safety check complete',
                detail: 'No risky content found in the last scan.',
                time: '9:15 AM',
              ),
              const SizedBox(height: 12),
              const _ActivityRow(
                icon: Icons.visibility_outlined,
                title: 'Content approval',
                detail: 'Approved a YouTube video requested by Alex.',
                time: '8:02 AM',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.time,
  });

  final IconData icon;
  final String title;
  final String detail;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.paleBlueSurface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: AppColors.primaryBlueLight),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: const TextStyle(fontSize: 10, height: 1.6, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(fontSize: 10, color: AppColors.textFaint),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
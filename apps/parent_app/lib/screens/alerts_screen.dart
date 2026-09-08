import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';

class AlertsScreen extends StatelessWidget {
  AlertsScreen({
    super.key,
    required this.alerts,
    required this.onSelectAlert,
    required this.onBack,
  });

  final List<AlertItem> alerts;
  final ValueChanged<String> onSelectAlert;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _BackButton(onTap: onBack),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GuardianLens',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: context.colors.textFaint),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Alerts',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.04,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.colors.surfaceFill,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Icon(Icons.notifications_none, size: 17, color: context.colors.textSecondary),
                    ),
                    Positioned(
                      top: -2,
                      right: -2,
                      child: CircleAvatar(radius: 4, backgroundColor: AppColors.dangerRedLight),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: alerts.length,
              separatorBuilder: (_, _) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return _AlertCard(
                  alert: alert,
                  onTap: () => onSelectAlert(alert.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  _AlertCard({required this.alert, required this.onTap});

  final AlertItem alert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.cardBackground,
          border: Border.all(color: context.colors.borderSubtle),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.surfaceFill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(alert.icon, size: 18, color: alert.accentColor),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.app,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                        ),
                      ),
                      Text(
                        alert.time,
                        style: TextStyle(fontSize: 10, color: context.colors.textFaint),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    alert.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    alert.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                  ),
                  SizedBox(height: 8),
                  SeverityBadge(severity: alert.severity),
                ],
              ),
            ),
            SizedBox(width: 8),
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(Icons.chevron_right, size: 16, color: context.colors.textPlaceholder),
            ),
          ],
        ),
      ),
    );
  }
}

class SeverityBadge extends StatelessWidget {
  SeverityBadge({super.key, required this.severity});

  final Severity severity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: severity.background(context.colors),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        severity.name[0].toUpperCase() + severity.name.substring(1),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: severity.color,
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  _BackButton({required this.onTap});

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

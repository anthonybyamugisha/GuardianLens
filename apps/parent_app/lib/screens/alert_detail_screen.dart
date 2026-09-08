import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import 'alerts_screen.dart' show SeverityBadge;

class AlertDetailScreen extends StatefulWidget {
  AlertDetailScreen({
    super.key,
    required this.alert,
    required this.onBack,
  });

  final AlertItem alert;
  final VoidCallback onBack;

  @override
  State<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends State<AlertDetailScreen> {
  bool _resolved = false;

  @override
  Widget build(BuildContext context) {
    final alert = widget.alert;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _BackButton(onTap: widget.onBack),
                SizedBox(width: 12),
                Text(
                  'Alert details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.03,
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surfaceFill,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.colors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(alert.icon, size: 24, color: alert.accentColor),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.app,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                      ),
                      SizedBox(height: 2),
                      Text(
                        alert.time,
                        style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.cardBackground,
                border: Border.all(color: context.colors.borderSubtle),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, size: 17, color: alert.accentColor),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          alert.title,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    alert.detail,
                    style: TextStyle(fontSize: 14, height: 1.6, color: context.colors.textSecondary),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      SeverityBadge(severity: alert.severity),
                      SizedBox(width: 8),
                      Text(
                        'Detected automatically',
                        style: TextStyle(fontSize: 11, color: context.colors.textFaint),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.blueSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended actions',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                  ),
                  SizedBox(height: 12),
                  _ActionRow(icon: Icons.chat_bubble_outline, text: 'Talk with Alex about what they saw'),
                  SizedBox(height: 12),
                  _ActionRow(icon: Icons.tune, text: 'Review ${alert.app} monitoring sensitivity'),
                  SizedBox(height: 12),
                  _ActionRow(icon: Icons.shield_outlined, text: 'Block similar content automatically'),
                ],
              ),
            ),
            Spacer(),
            if (_resolved)
              Container(
                padding: EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: context.colors.softGreenSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, size: 18, color: AppColors.successGreen),
                    SizedBox(width: 8),
                    Text(
                      'Alert resolved',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.successGreen),
                    ),
                  ],
                ),
              )
            else ...[
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text('Talk to Alex', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
              SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => setState(() => _resolved = true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.textSecondary,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: context.colors.borderInput),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Mark as resolved', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  _ActionRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: context.colors.cardBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 15, color: AppColors.primaryBlueLight),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
          ),
        ),
      ],
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

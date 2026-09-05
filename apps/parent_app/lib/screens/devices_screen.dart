import 'package:flutter/material.dart';

import '../theme.dart';

class DevicesScreen extends StatelessWidget {
  DevicesScreen({
    super.key,
    required this.paired,
    required this.onAddDevice,
    required this.onDashboard,
    required this.onBack,
  });

  final bool paired;
  final VoidCallback onAddDevice;
  final VoidCallback onDashboard;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GuardianLens',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: context.colors.textFaint),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your devices',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.04,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onBack,
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.textSecondary,
                    padding: EdgeInsets.zero,
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('Sign out', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            SizedBox(height: 32),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.blueSurface,
                border: Border.all(color: context.colors.blueSurfaceBorder),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: context.colors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.smartphone, color: AppColors.primaryBlueLight, size: 22),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.colors.softGreenSurface,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          paired ? '1 connected' : 'No devices',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.successGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    paired ? 'Alex\u2019s phone' : 'Connect a child device',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                  ),
                  SizedBox(height: 8),
                  Text(
                    paired
                        ? 'Monitoring is active and running quietly.'
                        : 'Pair a device to start seeing safety alerts here.',
                    style: TextStyle(fontSize: 14, height: 1.6, color: context.colors.textSecondary),
                  ),
                ],
              ),
            ),
            if (paired) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.cardBackground,
                  border: Border.all(color: context.colors.calloutBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.colors.softGreenSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.check_circle_outline, color: AppColors.successGreen, size: 18),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alex\u2019s phone',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Connected just now',
                          style: TextStyle(fontSize: 12, color: context.colors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onDashboard,
                style: OutlinedButton.styleFrom(
                  backgroundColor: context.colors.cardBackground,
                  foregroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: context.colors.blueChipBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.dashboard_outlined, size: 17),
                    SizedBox(width: 8),
                    Text('View dashboard', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAddDevice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: Icon(Icons.add, size: 18),
                label: Text('Add a child device', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'You can connect more than one device.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: context.colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

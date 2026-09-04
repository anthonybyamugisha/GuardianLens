import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/fields.dart';

class PairingSuccessScreen extends StatelessWidget {
  const PairingSuccessScreen({super.key, required this.onDashboard});

  final VoidCallback onDashboard;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 72, 28, 32),
        child: Column(
          children: [
            const SizedBox(height: 56),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.softGreenSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppColors.successGreen, size: 34),
            ),
            const SizedBox(height: 28),
            const Text(
              'Devices connected!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.04,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Alex\u2019s phone is now linked to your dashboard. Monitoring is active and quiet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.textSecondary),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Go to dashboard',
              icon: Icons.arrow_forward,
              onPressed: onDashboard,
            ),
            const SizedBox(height: 16),
            const Text(
              'Privacy settings are on by default',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class PairingFailedScreen extends StatelessWidget {
  const PairingFailedScreen({
    super.key,
    required this.onTryAgain,
    required this.onDevices,
  });

  final VoidCallback onTryAgain;
  final VoidCallback onDevices;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 72, 28, 32),
        child: Column(
          children: [
            const SizedBox(height: 56),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.redSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cancel, color: AppColors.dangerRedLight, size: 34),
            ),
            const SizedBox(height: 28),
            const Text(
              'Pairing didn\u2019t finish',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.04,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This code has expired or wasn\u2019t recognized. Generate a new one and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.textSecondary),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Try again',
              icon: Icons.refresh,
              onPressed: onTryAgain,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onDevices,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.buttonGrey,
                  foregroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back to devices', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
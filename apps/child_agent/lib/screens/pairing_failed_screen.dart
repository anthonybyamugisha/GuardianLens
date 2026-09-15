import 'package:flutter/material.dart';
import '../theme.dart';

class PairingFailedScreen extends StatelessWidget {
  const PairingFailedScreen({
    super.key,
    required this.onTryAgain,
  });

  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: colors.paleRedSurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.link_off_rounded,
                    size: 42,
                    color: AppColors.dangerRed,
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  'Couldn’t connect',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  'That pairing code doesn’t seem to be correct. Check the code with your parent or guardian and try again.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onTryAgain,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Back',
                    style: TextStyle(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/fields.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
    required this.onLogin,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 80, 28, 32),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Image.asset(
                      'assets/images/guardianlens_logo.png',
                      width: 208,
                      height: 208,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.045,
                      color: AppColors.textPrimary,
                    ),
                    children: [
                      TextSpan(text: 'Guardian'),
                      TextSpan(text: 'Lens', style: TextStyle(color: AppColors.primaryBlueLight)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Protecting their digital journey with care.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          PrimaryButton(
            label: 'Get Started',
            icon: Icons.arrow_forward,
            onPressed: onGetStarted,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onLogin,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.buttonGrey,
                foregroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Log In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
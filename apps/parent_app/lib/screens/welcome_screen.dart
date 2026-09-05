import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/fields.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({
    super.key,
    required this.onGetStarted,
    required this.onLogin,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(28, 80, 28, 32),
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
                SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.045,
                      color: context.colors.textPrimary,
                    ),
                    children: [
                      TextSpan(text: 'Guardian'),
                      TextSpan(text: 'Lens', style: TextStyle(color: AppColors.primaryBlueLight)),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Protecting their digital journey with care.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: context.colors.textSecondary,
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
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onLogin,
              style: TextButton.styleFrom(
                backgroundColor: context.colors.buttonGrey,
                foregroundColor: AppColors.primaryBlue,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Log In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

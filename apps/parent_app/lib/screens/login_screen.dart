import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/fields.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    required this.onSubmit,
    required this.onSignUp,
  });

  final VoidCallback onSubmit;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Welcome\nBack',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 31,
              height: 1.1,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.045,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Sign in to continue protecting what matters.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [AppShadows.form],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GLField(
                  label: 'Email address',
                  icon: Icons.mail_outline,
                  type: TextInputType.emailAddress,
                  placeholder: 'hello@guardianlens.com',
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Password',
                      style: TextStyle(color: AppColors.textLightBlue, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryBlueLight,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Forgot Password?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GLField(
                  icon: Icons.lock_outline,
                  obscure: true,
                  placeholder: 'Password',
                ),
                const SizedBox(height: 20),
                PrimaryButton(label: 'Log In', onPressed: onSubmit),
              ],
            ),
          ),
          const Spacer(),
          Text.rich(
            TextSpan(
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              text: "Don't have an account? ",
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: onSignUp,
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
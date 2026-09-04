import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/fields.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({
    super.key,
    required this.onSubmit,
    required this.onLogin,
  });

  final VoidCallback onSubmit;
  final VoidCallback onLogin;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _agreed = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_agreed) widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            'assets/images/guardianlens_logo.png',
            width: 48,
            height: 48,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 28),
          const Text(
            'Create Account',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.045,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Join GuardianLens to keep your child\u2019s digital world safe.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          GLField(
            label: 'Full Name',
            icon: Icons.person_outline,
            placeholder: 'menhya joshua',
            controller: _nameController,
          ),
          const SizedBox(height: 12),
          GLField(
            label: 'Email Address',
            icon: Icons.mail_outline,
            type: TextInputType.emailAddress,
            placeholder: 'menhyajoshua@gmail.com',
            controller: _emailController,
          ),
          const SizedBox(height: 12),
          GLField(
            label: 'Create Password',
            icon: Icons.key,
            obscure: true,
            placeholder: 'Password',
            controller: _passwordController,
          ),
          const SizedBox(height: 12),
          GLField(
            label: 'Confirm Password',
            icon: Icons.key,
            obscure: true,
            placeholder: 'Password',
            controller: _confirmController,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _agreed = !_agreed),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.paleAmberSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: _agreed ? AppColors.primaryBlueLight : Colors.white,
                      border: Border.all(color: _agreed ? AppColors.primaryBlueLight : AppColors.borderInput),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _agreed
                        ? const Icon(Icons.check, size: 11, color: Colors.white, weight: 800)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      const TextSpan(
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.6),
                        children: [
                          TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(color: AppColors.primaryBlueLight, fontWeight: FontWeight.w500),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(color: AppColors.primaryBlueLight, fontWeight: FontWeight.w500),
                          ),
                          TextSpan(text: '.'),
                        ],
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Create Account',
            icon: Icons.arrow_forward,
            onPressed: _submit,
            disabled: !_agreed,
          ),
          const SizedBox(height: 20),
          Text.rich(
            TextSpan(
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              text: 'Already have an account? ',
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: widget.onLogin,
                    child: const Text(
                      'Log in',
                      style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
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
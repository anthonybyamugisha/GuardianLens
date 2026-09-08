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
  bool _loading = false;
  String? _error;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  static final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty) {
      setState(() => _error = 'Please enter your full name.');
      return;
    }
    if (!_emailRegExp.hasMatch(email)) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }
    if (password.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    if (!_agreed) {
      setState(() => _error = 'Please accept the Terms of Service and Privacy Policy.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _loading = false);
    widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            'assets/images/guardianlens_logo.png',
            width: 48,
            height: 48,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 28),
          Text(
            'Create Account',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.045,
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Join GuardianLens to keep your child\u2019s digital world safe.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.6, color: context.colors.textSecondary),
          ),
          SizedBox(height: 28),
          GLField(
            label: 'Full Name',
            icon: Icons.person_outline,
            placeholder: 'menhya joshua',
            controller: _nameController,
          ),
          SizedBox(height: 12),
          GLField(
            label: 'Email Address',
            icon: Icons.mail_outline,
            type: TextInputType.emailAddress,
            placeholder: 'menhyajoshua@gmail.com',
            controller: _emailController,
          ),
          SizedBox(height: 12),
          GLField(
            label: 'Create Password',
            icon: Icons.key,
            obscure: true,
            placeholder: 'Password',
            controller: _passwordController,
          ),
          SizedBox(height: 12),
          GLField(
            label: 'Confirm Password',
            icon: Icons.key,
            obscure: true,
            placeholder: 'Password',
            controller: _confirmController,
          ),
          SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _agreed = !_agreed),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.paleAmberSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    margin: EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: _agreed ? AppColors.primaryBlueLight : context.colors.cardBackground,
                      border: Border.all(color: _agreed ? AppColors.primaryBlueLight : context.colors.borderInput),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _agreed
                        ? Icon(Icons.check, size: 11, color: Colors.white, weight: 800)
                        : null,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(color: context.colors.textSecondary, fontSize: 11, height: 1.6),
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
          if (_error != null) ...[
            const SizedBox(height: 16),
            ErrorBanner(message: _error!),
          ],
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Create Account',
            icon: Icons.arrow_forward,
            onPressed: _submit,
            loading: _loading,
          ),
          SizedBox(height: 20),
          Text.rich(
            TextSpan(
              style: TextStyle(color: context.colors.textSecondary, fontSize: 14),
              text: 'Already have an account? ',
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: widget.onLogin,
                    child: Text(
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

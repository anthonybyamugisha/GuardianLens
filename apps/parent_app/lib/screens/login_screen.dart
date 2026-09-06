import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/fields.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onSubmit,
    required this.onSignUp,
  });

  final VoidCallback onSubmit;
  final VoidCallback onSignUp;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  static final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!_emailRegExp.hasMatch(email)) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _error = 'Please enter your password.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _loading = false);
    widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome\nBack',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 31,
              height: 1.1,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.045,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sign in to continue protecting what matters.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: context.colors.textSecondary),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.colors.cardBackground,
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
                  controller: _emailController,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Password',
                      style: TextStyle(color: context.colors.textLightBlue, fontSize: 12, fontWeight: FontWeight.w500),
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
                  controller: _passwordController,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  ErrorBanner(message: _error!),
                ],
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Log In',
                  onPressed: _submit,
                  loading: _loading,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text.rich(
            TextSpan(
              style: TextStyle(color: context.colors.textSecondary, fontSize: 14),
              text: "Don't have an account? ",
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: widget.onSignUp,
                    child: Text(
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
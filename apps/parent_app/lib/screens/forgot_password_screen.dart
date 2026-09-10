import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/fields.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  static final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _emailController.text.trim();
    if (!_emailRegExp.hasMatch(email)) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Forgot\npassword?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                height: 1.15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.045,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _sent
                  ? 'Check your inbox. We sent you instructions to reset your password.'
                  : 'Enter the email linked to your account and we\u2019ll send you a reset link.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.6, color: context.colors.textSecondary),
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
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    ErrorBanner(message: _error!),
                  ],
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: _sent ? 'Send again' : 'Send reset link',
                    icon: Icons.mail_outlined,
                    onPressed: _send,
                    loading: _loading,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: widget.onBack,
              style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlueLight),
              child: const Text('Back to log in', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
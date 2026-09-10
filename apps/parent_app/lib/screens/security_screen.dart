import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/fields.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _changed = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final current = _currentController.text;
    final next = _newController.text;
    final confirm = _confirmController.text;
    if (current.isEmpty) {
      setState(() => _error = 'Enter your current password.');
      return;
    }
    if (next.length < 6) {
      setState(() => _error = 'New password must be at least 6 characters.');
      return;
    }
    if (next != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _changed = true;
      _currentController.clear();
      _newController.clear();
      _confirmController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: widget.onBack,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.colors.cardBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.arrow_back, size: 20, color: context.colors.textPrimary),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'Password & security',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.02,
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Choose a strong password you don\u2019t use anywhere else.',
              style: TextStyle(fontSize: 13.5, height: 1.6, color: context.colors.textSecondary),
            ),
            const SizedBox(height: 24),
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
                    label: 'Current password',
                    icon: Icons.lock_outline,
                    obscure: true,
                    placeholder: 'Current password',
                    controller: _currentController,
                  ),
                  const SizedBox(height: 14),
                  GLField(
                    label: 'New password',
                    icon: Icons.key,
                    obscure: true,
                    placeholder: 'New password',
                    controller: _newController,
                  ),
                  const SizedBox(height: 14),
                  GLField(
                    label: 'Confirm new password',
                    icon: Icons.key,
                    obscure: true,
                    placeholder: 'Confirm new password',
                    controller: _confirmController,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    ErrorBanner(message: _error!),
                  ],
                  if (_changed) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.softGreenSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 16, color: AppColors.successGreen),
                          const SizedBox(width: 8),
                          Text(
                            'Password updated',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Update password',
                    icon: Icons.check,
                    onPressed: _save,
                    loading: _loading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
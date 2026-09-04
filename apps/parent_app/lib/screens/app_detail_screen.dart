import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/toggle.dart';

class AppDetailScreen extends StatefulWidget {
  const AppDetailScreen({
    super.key,
    required this.app,
    required this.onChange,
    required this.onBack,
  });

  final MonitoredApp app;
  final ValueChanged<MonitoredApp> onChange;
  final VoidCallback onBack;

  @override
  State<AppDetailScreen> createState() => _AppDetailScreenState();
}

class _AppDetailScreenState extends State<AppDetailScreen> {
  late Sensitivity _sensitivity;
  late bool _enabled;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _sensitivity = widget.app.sensitivity;
    _enabled = widget.app.enabled;
  }

  void _handleSave() {
    widget.onChange(widget.app.copyWith(sensitivity: _sensitivity, enabled: _enabled));
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _BackButton(onTap: widget.onBack),
                const SizedBox(width: 12),
                const Text(
                  'App settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.03,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceFill,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.app.icon, size: 24, color: widget.app.accentColor),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.app.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.app.description,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.borderSubtle),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Monitor this app',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'When on, GuardianLens watches for risky content.',
                          style: TextStyle(fontSize: 12, color: AppColors.textFaint),
                        ),
                      ],
                    ),
                  ),
                  Toggle(on: _enabled, onChanged: () => setState(() => _enabled = !_enabled)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.blueSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tune, size: 16, color: AppColors.primaryBlueLight),
                      SizedBox(width: 8),
                      Text(
                        'Sensitivity override',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _sensitivity.description,
                    style: const TextStyle(fontSize: 12, height: 1.6, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: Sensitivity.values.map((level) {
                      final selected = _sensitivity == level;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: GestureDetector(
                            onTap: () => setState(() => _sensitivity = level),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: selected ? AppColors.primaryBlue : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                level.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: selected ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This overrides the global sensitivity for ${widget.app.name} only.',
                    style: const TextStyle(fontSize: 11, color: AppColors.textFaint),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (_saved)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.softGreenSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, size: 18, color: AppColors.successGreen),
                    SizedBox(width: 8),
                    Text(
                      'Settings saved',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.successGreen),
                    ),
                  ],
                ),
              )
            else
              ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  shadowColor: AppColors.primaryBlue,
                ),
                child: const Text('Save changes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: const SizedBox(
        width: 36,
        height: 36,
        child: Icon(Icons.arrow_back, size: 20, color: AppColors.textSecondary),
      ),
    );
  }
}
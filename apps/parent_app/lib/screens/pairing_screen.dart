import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/fields.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({
    super.key,
    required this.onSuccess,
    required this.onExpired,
    required this.onGenerate,
  });

  final VoidCallback onSuccess;
  final VoidCallback onExpired;
  final void Function(String) onGenerate;

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  int _seconds = 506;
  String _code = 'GL-8294';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _seconds > 0) {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _generateNewCode() {
    final newCode = _code == 'GL-8294' ? 'GL-4107' : 'GL-8294';
    setState(() {
      _code = newCode;
      _seconds = 506;
    });
    widget.onGenerate(newCode);
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final remaining = (_seconds % 60).toString().padLeft(2, '0');
    final expired = _seconds == 0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.paleBlueSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.smartphone, color: AppColors.primaryBlueLight, size: 27),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pair a new device',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.04,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use this code on your child\u2019s device to connect it securely.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.blueSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'YOUR PAIRING CODE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                      color: AppColors.primaryBlueLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _code,
                          style: const TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceFill,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.copy, size: 15, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.schedule, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        expired ? 'Code expired' : 'Expires in $minutes:$remaining',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: expired ? AppColors.dangerRedLight : AppColors.amber,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'How to connect',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            const _Step(
              number: '1',
              title: 'Open GuardianLens',
              text: 'Download and open the app on your child\u2019s phone.',
            ),
            const SizedBox(height: 16),
            const _Step(
              number: '2',
              title: 'Enter the code',
              text: 'Type the code above when prompted on their device.',
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Simulate device connected',
              icon: Icons.share_outlined,
              onPressed: widget.onSuccess,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: widget.onExpired,
              style: TextButton.styleFrom(foregroundColor: AppColors.dangerRedLight),
              child: const Text('Test expired code', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _generateNewCode,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.blueChipBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, size: 17),
                    SizedBox(width: 8),
                    Text('Generate new code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.title, required this.text});

  final String number;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.stepBlue,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryBlueLight),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(fontSize: 12, height: 1.6, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';

/// Full-screen warning shown to the child when a frame is classified unsafe.
class UnsafeWarningDialog extends StatelessWidget {
  const UnsafeWarningDialog({super.key, required this.score});

  /// P(unsafe) that triggered the warning, for display.
  final double score;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: const Color(0xFFB91C1C),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.white, size: 96),
              const SizedBox(height: 24),
              const Text(
                'Stop for a moment',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'GuardianLens spotted content that may not be safe for you. '
                'Please close this screen and talk to a trusted adult.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 28),
              Text(
                'Confidence: ${(score * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 28),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFB91C1C),
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('I understand'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows the [UnsafeWarningDialog] and completes when it is dismissed.
Future<void> showUnsafeWarning(BuildContext context, {required double score}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => UnsafeWarningDialog(score: score),
  );
}

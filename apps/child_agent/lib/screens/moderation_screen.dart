import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../config/moderation_config.dart';
import '../services/moderator.dart';
import '../widgets/unsafe_warning.dart';

/// Status + harness screen for the on-device moderator.
///
/// Loads the bundled model and lets a frame be classified. This is the surface
/// the screen-capture pipeline will feed once it is wired in.
class ModerationScreen extends StatefulWidget {
  const ModerationScreen({super.key});

  @override
  State<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends State<ModerationScreen> {
  ModeratorClassifier? _classifier;
  ModerationResult? _lastResult;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _classifier?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final classifier = await ModeratorClassifier.load();
      if (!mounted) return;
      setState(() => _classifier = classifier);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    }
  }

  Future<void> _scanTestFrame() async {
    final classifier = _classifier;
    if (classifier == null) return;
    setState(() => _busy = true);
    final result = classifier.classify(_syntheticFrame());
    if (!mounted) return;
    setState(() {
      _lastResult = result;
      _busy = false;
    });
    if (result.isUnsafe) {
      await showUnsafeWarning(context, score: result.unsafeProbability);
    }
  }

  img.Image _syntheticFrame() {
    const size = ModerationConfig.imageSize;
    final image = img.Image(width: size, height: size, numChannels: 3);
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        image.setPixelRgb(x, y, x * 2, y * 2, 128);
      }
    }
    return image;
  }

  @override
  Widget build(BuildContext context) {
    final ready = _classifier != null;
    return Scaffold(
      appBar: AppBar(title: const Text('GuardianLens')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _StatusCard(
            ready: ready,
            error: _error,
            labels: _classifier?.labels ?? const [],
          ),
          const SizedBox(height: 16),
          const _ConfigCard(),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: ready && !_busy ? _scanTestFrame : null,
            icon: const Icon(Icons.shield_outlined),
            label: const Text('Run test scan'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () =>
                showUnsafeWarning(context, score: 0.93),
            icon: const Icon(Icons.warning_amber_rounded),
            label: const Text('Preview warning'),
          ),
          const SizedBox(height: 20),
          if (_busy) const LinearProgressIndicator(),
          if (_lastResult != null) _ResultCard(result: _lastResult!),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.ready, this.error, required this.labels});

  final bool ready;
  final String? error;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color color;
    final String title;
    final String subtitle;
    if (error != null) {
      icon = Icons.error_outline;
      color = const Color(0xFFB91C1C);
      title = 'Model failed to load';
      subtitle = error!;
    } else if (ready) {
      icon = Icons.verified_user;
      color = const Color(0xFF15803D);
      title = 'Protection ready';
      subtitle = 'Classes: ${labels.join(", ")}';
    } else {
      icon = Icons.hourglass_top;
      color = const Color(0xFFB45309);
      title = 'Starting up';
      subtitle = 'Loading the on-device model…';
    }
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: 36),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class _ConfigCard extends StatelessWidget {
  const _ConfigCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Configuration',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Input size: '
                '${ModerationConfig.imageSize}×${ModerationConfig.imageSize}'),
            Text('Threshold: ${ModerationConfig.unsafeThreshold}'),
            Text('Sample interval: '
                '${ModerationConfig.sampleInterval.inSeconds}s'),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final ModerationResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      color:
          result.isUnsafe ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last result: ${result.label}',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('P(unsafe) = ${result.unsafeProbability.toStringAsFixed(3)}'),
            Text('Inference: ${result.elapsed.inMilliseconds} ms'),
          ],
        ),
      ),
    );
  }
}

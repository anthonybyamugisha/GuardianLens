import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../config/moderation_config.dart';
import '../services/moderator.dart';
import '../services/monitor_controller.dart';
import '../widgets/unsafe_warning.dart';

/// Status + control screen for the on-device moderator.
///
/// Loads the bundled model, then samples the screen on a timer, classifies each
/// new frame locally, and warns the child when unsafe content is detected.
class ModerationScreen extends StatefulWidget {
  const ModerationScreen({super.key});

  @override
  State<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends State<ModerationScreen> {
  ModeratorClassifier? _classifier;
  MonitorController? _controller;

  String? _error;
  bool _monitoring = false;
  ModerationResult? _lastResult;
  Uint8List? _lastFrame;
  int _warnings = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller?.stop();
    _classifier?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final classifier = await ModeratorClassifier.load();
      final controller = MonitorController(classifier: classifier)
        ..onResult = _handleResult
        ..onWarning = _handleWarning
        ..onError = _handleError;
      if (!mounted) return;
      setState(() {
        _classifier = classifier;
        _controller = controller;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    }
  }

  void _handleResult(ModerationResult result, Uint8List frame) {
    if (!mounted) return;
    setState(() {
      _lastResult = result;
      _lastFrame = frame;
    });
  }

  void _handleWarning(ModerationResult result) {
    if (!mounted) return;
    setState(() => _warnings++);
    showUnsafeWarning(context, score: result.unsafeProbability);
  }

  void _handleError(Object error) {
    if (!mounted) return;
    setState(() => _error = '$error');
  }

  Future<void> _toggleMonitoring() async {
    final controller = _controller;
    if (controller == null) return;
    if (_monitoring) {
      await controller.stop();
      if (!mounted) return;
      setState(() => _monitoring = false);
      return;
    }
    final started = await controller.start();
    if (!mounted) return;
    setState(() => _monitoring = started);
    if (!started) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Screen-capture permission was denied.')),
      );
    }
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
            monitoring: _monitoring,
            error: _error,
            labels: _classifier?.labels ?? const [],
          ),
          const SizedBox(height: 16),
          const _ConfigCard(),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: ready ? _toggleMonitoring : null,
            icon: Icon(_monitoring ? Icons.stop : Icons.play_arrow),
            label: Text(_monitoring ? 'Stop protection' : 'Start protection'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => showUnsafeWarning(context, score: 0.93),
            icon: const Icon(Icons.warning_amber_rounded),
            label: const Text('Preview warning'),
          ),
          if (_lastFrame != null) ...[
            const SizedBox(height: 20),
            const Text('Last sampled frame',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(_lastFrame!, height: 180, fit: BoxFit.contain),
            ),
          ],
          const SizedBox(height: 20),
          if (_lastResult != null) _ResultCard(result: _lastResult!),
          if (_warnings > 0) ...[
            const SizedBox(height: 8),
            Text('Warnings shown: $_warnings',
                style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.ready,
    required this.monitoring,
    this.error,
    required this.labels,
  });

  final bool ready;
  final bool monitoring;
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
      title = 'Something went wrong';
      subtitle = error!;
    } else if (monitoring) {
      icon = Icons.shield;
      color = const Color(0xFF15803D);
      title = 'Protection active';
      subtitle = 'Sampling the screen every '
          '${ModerationConfig.sampleInterval.inSeconds}s';
    } else if (ready) {
      icon = Icons.verified_user_outlined;
      color = const Color(0xFF2563EB);
      title = 'Ready';
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
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
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

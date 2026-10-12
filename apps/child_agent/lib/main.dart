import 'package:flutter/material.dart';

import 'screens/moderation_screen.dart';

void main() {
  runApp(const GuardianLensChildApp());
}

class GuardianLensChildApp extends StatelessWidget {
  const GuardianLensChildApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GuardianLens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2563EB),
        useMaterial3: true,
      ),
      home: const ModerationScreen(),
    );
  }
}

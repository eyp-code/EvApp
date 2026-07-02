import 'package:flutter/material.dart';

import 'theme.dart';
import '../features/shell/presentation/main_shell.dart';

class EvApp extends StatelessWidget {
  const EvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EvApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainShell(),
    );
  }
}

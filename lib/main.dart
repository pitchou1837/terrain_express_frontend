import 'package:flutter/material.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'features/home_shell.dart';

void main() {
  runApp(const TerrainExpressApp());
}

class TerrainExpressApp extends StatelessWidget {
  const TerrainExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Temporary: goes straight to the player home.
      // Later: Login screen → PlayerShell or OwnerShell depending on role.
      home: const PlayerShell(),
    );
  }
}
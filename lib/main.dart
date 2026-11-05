import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/sentinel_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: SentinelXApp(),
    ),
  );
}

class SentinelXApp extends StatelessWidget {
  const SentinelXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SentinelX – Personal Cybersecurity Center',
      debugShowCheckedModeBanner: false,
      theme: SentinelTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/projects_provider.dart';
import 'screens/home_screen.dart';
import 'widgets/animated_yarn_background.dart';
import 'widgets/yarn_cat_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final provider = ProjectsProvider();
  await provider.load();

  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const TejidoApp(),
    ),
  );
}

class TejidoApp extends StatelessWidget {
  const TejidoApp({super.key});

  static const _lightBg = Color(0xFFF5F0FF);
  static const _darkBg = Color(0xFF18122B);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tejido Counter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B5EA7),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B5EA7),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Stack(
          children: [
            ColoredBox(
              color: isDark ? _darkBg : _lightBg,
              child: const SizedBox.expand(),
            ),
            const Positioned.fill(child: AnimatedYarnBackground()),
            YarnCatOverlay(child: child!),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/core/app/app_scope.dart';
import 'package:shop/core/services/firebase_bootstrap.dart';
import 'package:shop/entry_point.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/route/router.dart' as router;
import 'package:shop/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.initialize();
  runApp(const AppScope(child: MyApp()));
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PawCare Store',
      theme: AppTheme.lightTheme(context),
      themeMode: ThemeMode.light,
      onGenerateRoute: router.generateRoute,
      home: const AppLaunchGate(),
    );
  }
}

class AppLaunchGate extends StatelessWidget {
  const AppLaunchGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authProvider.isAuthenticated) {
      return const EntryPoint();
    }

    return const OnBordingScreen();
  }
}

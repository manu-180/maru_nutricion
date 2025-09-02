import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:maru_nutricion/config/env.dart';
import 'package:maru_nutricion/config/router/app_router.dart';
import 'package:maru_nutricion/config/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnon);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = const AppTheme(isDarkMode: false).theme();
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: appRouter,
    );
  }
}

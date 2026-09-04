import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'widgets/nav_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  runApp(const NokeApp());
}

class NokeApp extends StatelessWidget {
  const NokeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NOKE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      locale: const Locale('pt', 'BR'),
      home: const NavShell(),
    );
  }
}

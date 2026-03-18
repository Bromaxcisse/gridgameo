import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_theme.dart';
import 'screens/boot_sequence.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF05050A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const OxygenGridApp());
}

class OxygenGridApp extends StatelessWidget {
  const OxygenGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Oxygen Grid',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const BootSequence(),
    );
  }
}

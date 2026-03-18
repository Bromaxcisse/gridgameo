import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_theme.dart';
import 'screens/boot_sequence.dart';

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Unhandled platform error: $error\n$stack');
      return true;
    };

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
  }, (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
  });
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

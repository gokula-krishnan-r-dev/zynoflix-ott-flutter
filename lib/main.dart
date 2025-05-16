import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:io' show Platform;

// Import our separated components
import 'config/app_config.dart';
import 'services/asset_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppConfig.primaryColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp(title: AppConfig.appName));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConfig.primaryColor,
          brightness: Brightness.dark,
          background: AppConfig.backgroundColor,
          primary: AppConfig.primaryColor,
          secondary: AppConfig.secondaryColor,
        ),
        scaffoldBackgroundColor: AppConfig.backgroundColor,
        appBarTheme: const AppBarTheme(
          elevation: 2,
          centerTitle: false,
          backgroundColor: AppConfig.backgroundColor,
          foregroundColor: AppConfig.textColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConfig.secondaryColor,
            foregroundColor: AppConfig.textColor,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConfig.primaryColor,
          brightness: Brightness.dark,
          background: AppConfig.backgroundColor,
          primary: AppConfig.primaryColor,
          secondary: AppConfig.secondaryColor,
        ),
        scaffoldBackgroundColor: AppConfig.backgroundColor,
        appBarTheme: const AppBarTheme(
          elevation: 2,
          centerTitle: false,
          backgroundColor: AppConfig.backgroundColor,
          foregroundColor: AppConfig.textColor,
        ),
      ),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<ui.Image?>(
        future: AssetService.loadLogoImage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Pass the preloaded image to the splash screen
            return SplashScreen(title: title, logoImage: snapshot.data);
          }
          // Show a simple loading screen while loading the logo
          return Scaffold(
            backgroundColor: AppConfig.primaryColor,
            body: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}

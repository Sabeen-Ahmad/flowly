import 'package:flowly/provider/auth_provider.dart';
import 'package:flowly/provider/task_provider.dart';
import 'package:flowly/provider/theme_provider.dart';
import 'package:flowly/screens/welcome_screen.dart';
import 'package:flowly/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child:Consumer<ThemeProvider>(
        builder: (_, themeProvider, __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme:     AppTheme.lightTheme,   // ← light
          darkTheme: AppTheme.darkTheme,    // ← dark (this was missing!)
          themeMode: themeProvider.themeMode,

          home: const WelcomeScreen(),
        ),
      ),
    );
  }
}
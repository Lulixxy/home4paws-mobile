// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'screens/register_page.dart';
import 'screens/login_page.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const Home4PawsApp());
}

class Home4PawsApp extends StatelessWidget {
  const Home4PawsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home4Paws',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
          secondary: AppColors.accentCopper,
          surface: AppColors.bgCream,
          onSurface: AppColors.textDarkGreen,
          error: AppColors.errorRed,
        ),
        scaffoldBackgroundColor: AppColors.bgCream,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bgCream,
          foregroundColor: AppColors.textDarkGreen,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          labelStyle: TextStyle(
            color: AppColors.textDarkGreen.withOpacity(0.6),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: AppColors.primaryGreen,
              width: 2,
            ),
          ),
        ),
      ),
      // กำหนดหน้าแรกที่จะแสดงเมื่อแอปเริ่มต้น
      home: const MainScreen(isGuest: true),
      routes: {
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MainScreen(),
      },
    );
  }
}

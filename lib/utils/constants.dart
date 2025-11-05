import 'package:flutter/material.dart';

class AppColors {
  // Tokens extracted from Figma (GoatBarber)
  static const Color primary = Color(0xFFE6B23B); // gold CTA
  static const Color primaryContainer = Color(0xFFC98F1F);
  static const Color accent = Color(0xFFF6C85F);
  static const Color background = Color(0xFF0E0E0E);
  static const Color surface = Color(0xFF141414);
  static const Color onPrimary = Color(0xFF000000);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFBDBDBD);
  static const Color error = Color(0xFFD32F2F);
}

class AppStrings {
  static const String appName = 'GoatBarber';
  static const String login = 'Entrar';
  static const String register = 'Cadastrar';
}

class AppConfig {
  // Adjust to your API endpoint
  static String baseUrl = 'http://localhost:3000/api';
  static const Duration timeout = Duration(seconds: 30);
}

class AppRadii {
  static const double small = 8.0;
  static const double normal = 12.0;
  static const double large = 20.0;
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}
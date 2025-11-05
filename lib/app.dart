import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/constants.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/client/client_dashboard.dart';
import 'screens/barber/barber_dashboard.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme(
      displayLarge: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      headlineLarge: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      headlineMedium: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleLarge: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
      labelLarge: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, background: AppColors.background),
          useMaterial3: true,
          textTheme: textTheme,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.normal)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.normal)),
            ),
          ),
        ),
        home: const _RootSelector(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/client': (_) => const ClientDashboard(),
          '/barber': (_) => const BarberDashboard(),
        },
      ),
    );
  }
}

class _RootSelector extends StatelessWidget {
  const _RootSelector();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (!auth.isAuthenticated) return const LoginScreen();
    return auth.usuario?.papel == 'cliente' ? const ClientDashboard() : const BarberDashboard();
  }
}
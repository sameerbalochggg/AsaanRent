import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rent_application/presentation/auth/screens/splash.dart';
import 'package:rent_application/presentation/providers/property_provider.dart';
import 'package:rent_application/presentation/providers/profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Theme Imports ---
import 'package:rent_application/presentation/providers/theme_provider.dart';
import 'package:rent_application/core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: 'https://oxfpnrlxaannwudamdeu.supabase.co',
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im94ZnBucmx4YWFubnd1ZGFtZGV1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwMTAxODgsImV4cCI6MjA3MjU4NjE4OH0.xRnz3jLNTJ3S7J2Lh_7Vkt_RP8aOH9SD7wWIEF_eq88");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider registers all your app's "managers"
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PropertyProvider()),
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'AsaanRent',
            
            // Connects your light and dark themes
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode, 
            
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rent_application/presentation/auth/screens/splash.dart';
import 'package:rent_application/presentation/providers/property_provider.dart';
import 'package:rent_application/presentation/providers/property_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Your App's Color Scheme ---
const kPrimaryColor = Color(0xFF004D40);

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
    // ✅ --- Use MultiProvider to provide all your app's "managers" ---
    return MultiProvider(
      providers: [
        // Manages property lists
        ChangeNotifierProvider(create: (context) => PropertyProvider()),
        // Manages user profile data
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AsaanRent', // Changed title
        
        // ✅ --- Upgraded theme to match your app's professional style ---
        theme: ThemeData(
          primaryColor: kPrimaryColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: kPrimaryColor,
            primary: kPrimaryColor,
            background: const Color(0xFFF8F9FA), // Light grey background
          ),
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          
          // --- Set default font to Poppins ---
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),

          // --- Set default AppBar theme ---
          appBarTheme: AppBarTheme(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            elevation: 1,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
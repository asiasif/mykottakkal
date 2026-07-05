import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mykottakkal/services/auth_service.dart';
import 'package:mykottakkal/services/app_localizations.dart';
import 'package:mykottakkal/views/login_screen.dart';
import 'package:mykottakkal/views/landing_screen.dart';
import 'package:mykottakkal/views/role_selection_screen.dart';
import 'package:mykottakkal/views/user/user_home_screen.dart';
import 'package:mykottakkal/views/worker/worker_registration_screen.dart';
import 'package:mykottakkal/views/shop/shop_dashboard_screen.dart'; // Verified Import
import 'package:mykottakkal/views/admin/admin_dashboard_screen.dart';
import 'package:mykottakkal/views/user/user_profile_setup_screen.dart';
import 'package:mykottakkal/views/email_login_screen.dart';
import 'package:mykottakkal/views/email_signup_screen.dart';
import 'package:mykottakkal/views/worker/worker_dashboard_screen.dart';
import 'package:mykottakkal/services/theme_service.dart';
import 'package:mykottakkal/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    print("DEBUG: Starting Firebase Initialization...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("DEBUG: Firebase Initialized Successfully!");
  } catch (e) {
    print("DEBUG: Firebase Initialization Failed: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Kottakkal City App',
            themeMode: themeService.themeMode,
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ml', 'IN'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2E7D32), // Deep Herbal Green
                primary: const Color(0xFF2E7D32),
                secondary: const Color(0xFFD4AF37), // Antique Gold
                surface: const Color(0xFFF9F5F0), // Warm Cream / Parchment
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              fontFamily: GoogleFonts.outfit().fontFamily,
              textTheme: GoogleFonts.outfitTextTheme().copyWith(
                displayLarge: GoogleFonts.playfairDisplay(color: Color(0xFF3E2723), fontWeight: FontWeight.bold),
                displayMedium: GoogleFonts.playfairDisplay(color: Color(0xFF3E2723), fontWeight: FontWeight.bold),
                headlineLarge: GoogleFonts.playfairDisplay(color: Color(0xFF3E2723), fontWeight: FontWeight.bold),
                headlineMedium: GoogleFonts.playfairDisplay(color: Color(0xFF3E2723), fontWeight: FontWeight.bold),
                titleLarge: GoogleFonts.playfairDisplay(color: Color(0xFF3E2723), fontWeight: FontWeight.bold),
              ),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: Colors.transparent,
                titleTextStyle: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold, fontSize: 22, fontFamily: 'Playfair Display'),
                iconTheme: IconThemeData(color: Color(0xFF3E2723)),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Color(0xFFD4AF37).withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Outfit'),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFFD4AF37).withOpacity(0.3))), // Gold hint
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFFD4AF37).withOpacity(0.3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2)),
              ),
            ),
            darkTheme: ThemeData( // Kept mostly same but consistent with green
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Color(0xFF121212),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2E7D32),
                primary: const Color(0xFF2E7D32),
                secondary: const Color(0xFFD4AF37),
                surface: Color(0xFF1E1E1E),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              fontFamily: GoogleFonts.outfit().fontFamily,
              textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
                displayLarge: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold),
                headlineMedium: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'Playfair Display'),
                iconTheme: IconThemeData(color: Colors.white),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Color(0xFF2C2C2C),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade800)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2)),
              ),
            ),
            initialRoute: '/landing',
            routes: {
              '/landing': (context) => const LandingScreen(),
              '/login': (context) => const LoginScreen(),
              '/role-selection': (context) => const RoleSelectionScreen(),
              '/user-home': (context) => const UserHomeScreen(),
              '/worker-registration': (context) => const WorkerRegistrationScreen(),
              '/merchant-dashboard': (context) => const ShopDashboardScreen(), // UPDATED ROUTE
              '/admin-dashboard': (context) => const AdminDashboardScreen(),
              '/user-profile-setup': (context) => const UserProfileSetupScreen(),
              '/email-login': (context) => const EmailLoginScreen(),
              '/signup': (context) => const EmailSignUpScreen(),
              '/worker-dashboard': (context) => const WorkerDashboardScreen(),
            },
          );
        },
      ),
    );
  }
}

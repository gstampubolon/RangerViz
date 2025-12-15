import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/app_colors.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/product_add_screen.dart';
import 'screens/main_screen.dart';
import 'screens/account_settings_screen.dart';
import 'screens/general_settings_screen.dart'; // ✅ Import file Dark Mode baru

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    debugPrint("✅ Firebase Berhasil Konek!");
  } catch (e) {
    debugPrint("❌ Firebase Gagal: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final initialRoute = FirebaseAuth.instance.currentUser != null ? '/home' : '/';

    return MaterialApp(
      title: 'Superstore Retail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainScreen(),
        '/add': (context) => const ProductAddScreen(),
        '/settings': (context) => const AccountSettingsScreen(), // ✅ Rute settings tetap ada
        '/general_settings': (context) => const GeneralSettingsScreen(), // ✅ Rute baru untuk Dark Mode
      },
    );
  }
}
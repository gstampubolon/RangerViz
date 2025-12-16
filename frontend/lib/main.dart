import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Wajib
import 'package:firebase_auth/firebase_auth.dart';
import 'core/app_colors.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/product_add_screen.dart';
import 'screens/main_screen.dart';
import 'screens/account_settings_screen.dart';

void main() async {
  // 1. Kunci Widget Binding
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Inisialisasi Firebase (Tunggu sampai selesai)
    await Firebase.initializeApp();
    debugPrint("✅ Firebase Berhasil Konek!");
  } catch (e) {
    debugPrint("❌ Firebase Gagal: $e");
  }

  // 3. Jalankan App
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Cek apakah user sudah login sebelumnya
    final initialRoute =
        FirebaseAuth.instance.currentUser != null ? '/home' : '/';

    return MaterialApp(
      title: 'Superstore Retail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          titleTextStyle: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainScreen(),
        '/add': (context) => const ProductAddScreen(),
        '/settings': (context) => const AccountSettingsScreen(),
      },
    );
  }
}

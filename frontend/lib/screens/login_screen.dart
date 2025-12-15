import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.bubble_chart_rounded,
                    size: 60, color: AppColors.primary),
                const SizedBox(height: 20),
                const Text(
                  "Welcome Back,",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold, // Balikin Bold
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  "Sign in to continue managing your products.",
                  style:
                      TextStyle(fontSize: 16, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                const CustomInput(
                    label: "Email",
                    hint: "hello@example.com",
                    icon: Icons.email_outlined),
                const SizedBox(height: 20),
                const CustomInput(
                    label: "Password",
                    hint: "Your password",
                    isPassword: true,
                    icon: Icons.lock_outline),
                const SizedBox(height: 40),
                CustomButton(
                  text: "Login",
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/home'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ",
                        style: TextStyle(color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text(
                        "Register",
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold), // Balikin Bold
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

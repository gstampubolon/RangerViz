import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_colors.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // ✅ 1. Tambahkan Form Key
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  void _handleRegister() async {
    // ✅ 2. Cek Validasi Otomatis
    if (!_formKey.currentState!.validate()) {
      return; 
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(_nameController.text.trim());
        await userCredential.user!.reload();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Akun berhasil dibuat! Silakan Login."), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Terjadi kesalahan.";
      if (e.code == 'weak-password') msg = "Password terlalu lemah.";
      else if (e.code == 'email-already-in-use') msg = "Email sudah terdaftar.";
      else if (e.code == 'invalid-email') msg = "Format email salah.";
      
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form( // ✅ 3. Bungkus dengan Form
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Create Account", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const Text("Start your journey with us", style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                  const SizedBox(height: 32),
                  
                  CustomInput(
                    label: "Full Name",
                    hint: "John Doe",
                    icon: Icons.person_outline,
                    controller: _nameController,
                    validator: (val) => val!.isEmpty ? "Nama wajib diisi" : null,
                  ),
                  const SizedBox(height: 20),
                  
                  CustomInput(
                    label: "Email",
                    hint: "hello@example.com",
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val!.isEmpty) return "Email wajib diisi";
                      if (!val.contains('@')) return "Format email salah";
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  CustomInput(
                    label: "Password",
                    hint: "Create a password",
                    isPassword: true,
                    icon: Icons.lock_outline,
                    controller: _passwordController,
                    validator: (val) => val!.length < 6 ? "Minimal 6 karakter" : null,
                  ),
                  const SizedBox(height: 40),
                  
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : CustomButton(text: "Register", onPressed: _handleRegister),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_colors.dart';
import 'account_settings_screen.dart';
import 'general_settings_screen.dart'; // ✅ Import untuk Pengaturan Umum

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  // Fungsi Logout
  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (ctx.mounted) {
                Navigator.of(ctx)
                    .pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            child: const Text("Ya, Keluar",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? "Pengguna Superstore";
  }

  String _getUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email ?? "email@example.com";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Akun Saya",
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profil
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getUserName(),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_getUserEmail(),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ✅ MENU 1: PENGATURAN AKUN (Edit Nama, Password, Biodata)
            _buildMenuItem(
                context, "Pengaturan Akun", Icons.manage_accounts_outlined, () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AccountSettingsScreen()));
            }),

            // ✅ MENU 2: PENGATURAN UMUM (Dark Mode)
            _buildMenuItem(context, "Pengaturan Umum", Icons.settings_outlined,
                () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GeneralSettingsScreen()));
            }),

            const SizedBox(height: 30),

            // MENU 3: LOGOUT
            _buildMenuItem(context, "Logout", Icons.exit_to_app,
                () => _handleLogout(context),
                isDanger: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap,
      {bool isDanger = false}) {
    Color color = isDanger ? Colors.red : AppColors.textPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title,
            style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        trailing:
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }
}

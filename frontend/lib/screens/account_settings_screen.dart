import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  String _birthDate = "1 Jan 1990";
  String _address = "Jalan Merdeka No. 10, Jakarta";

  // ================= EDIT NAMA =================
  void _showEditProfileDialog() {
    _nameController.text = user?.displayName ?? "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Nama Profil"),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: "Nama Lengkap"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            child: const Text("Simpan",
                style: TextStyle(color: AppColors.primary)),
            onPressed: () async {
              Navigator.pop(context); // ✅ TUTUP DULU

              if (_nameController.text.isEmpty) return;

              try {
                await user?.updateDisplayName(
                    _nameController.text.trim());
                await user?.reload();

                if (!mounted) return;

                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Nama berhasil diperbarui!"),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Gagal update nama: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // ================= GANTI PASSWORD =================
  void _showChangePasswordDialog() {
    _oldPasswordController.clear();
    _newPasswordController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Ganti Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: "Password Lama"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: "Password Baru (Min. 6 Karakter)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            child: const Text("Simpan",
                style: TextStyle(color: AppColors.primary)),
            onPressed: () async {
              if (_newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text("Password baru minimal 6 karakter."),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context); // ✅ tutup dialog dulu

              try {
                final credential =
                    EmailAuthProvider.credential(
                  email: user!.email!,
                  password: _oldPasswordController.text,
                );

                await user!.reauthenticateWithCredential(credential);
                await user!.updatePassword(
                    _newPasswordController.text);

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Password berhasil diganti!"),
                    backgroundColor: Colors.green,
                  ),
                );
              } on FirebaseAuthException catch (e) {
                if (!mounted) return;

                final msg = e.code == 'wrong-password'
                    ? 'Password lama salah.'
                    : 'Terjadi kesalahan.';

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // ================= LUPA PASSWORD =================
  Future<void> _requestForgotPassword() async {
    if (user?.email == null) return;

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: user!.email!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Link reset password dikirim ke ${user!.email}"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengirim link reset: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= BIODATA =================
  void _showBiodataDialog() {
    String tempDate = _birthDate;
    String tempAddress = _address;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          title: const Text("Biodata & Alamat"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text("Tanggal Lahir: $tempDate"),
                TextButton(
                  child: const Text("Pilih Tanggal Lahir",
                      style: TextStyle(color: AppColors.primary)),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: dialogCtx,
                      initialDate: DateFormat('d MMM yyyy')
                          .parse(tempDate),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );

                    if (picked != null) {
                      setDialogState(() {
                        tempDate = DateFormat('d MMM yyyy')
                            .format(picked);
                      });
                    }
                  },
                ),
                const Divider(),
                TextField(
                  maxLines: 3,
                  controller:
                      TextEditingController(text: tempAddress),
                  onChanged: (v) => tempAddress = v,
                  decoration: const InputDecoration(
                      labelText: "Alamat Lengkap"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _birthDate = tempDate;
                  _address = tempAddress;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text("Biodata diperbarui (Simulasi)"),
                  ),
                );
              },
              child: const Text("Simpan",
                  style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan Akun")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildMenuItem("Edit Nama", Icons.edit, _showEditProfileDialog),
          _buildMenuItem(
              "Edit Biodata", Icons.badge, _showBiodataDialog),
          _buildMenuItem(
              "Ganti Password", Icons.lock, _showChangePasswordDialog),
          _buildMenuItem(
              "Lupa Password", Icons.email, _requestForgotPassword),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

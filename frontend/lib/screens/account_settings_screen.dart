import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
// GeneralSettingsScreen tidak perlu diimport di sini lagi

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  // Controllers & State
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  // Data Biodata Dummy (State lokal untuk simulasi)
  String _birthDate = "1 Jan 1990";
  String _address = "Jalan Merdeka No. 10, Jakarta";

  // ==========================================
  // LOGIC EDIT PROFIL (NAMA)
  // ==========================================
  void _showEditProfileDialog() {
    _nameController.text = user?.displayName ?? "";
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Nama Profil"),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: "Nama Lengkap"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              if (mounted && _nameController.text.isNotEmpty) {
                try {
                  await user?.updateDisplayName(_nameController.text.trim());
                  await user?.reload();
                  if (mounted) {
                    Navigator.pop(ctx);
                    setState(() {}); // Refresh list
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Nama berhasil diperbarui!"),
                        backgroundColor: Colors.green));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Gagal update nama: $e"),
                        backgroundColor: Colors.red));
                  }
                }
              }
            },
            child: const Text("Simpan",
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // LOGIC GANTI PASSWORD
  // ==========================================
  void _showChangePasswordDialog() {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Ganti Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password Lama")),
            const SizedBox(height: 10),
            TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: "Password Baru (Min. 6 Karakter)")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              if (_newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Password baru minimal 6 karakter."),
                    backgroundColor: Colors.red));
                return;
              }
              try {
                AuthCredential credential = EmailAuthProvider.credential(
                    email: user!.email!, password: _oldPasswordController.text);
                await user!.reauthenticateWithCredential(credential);
                await user!.updatePassword(_newPasswordController.text);

                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Password berhasil diganti!"),
                      backgroundColor: Colors.green));
                }
              } on FirebaseAuthException catch (e) {
                if (mounted) {
                  String msg =
                      "Gagal ganti password: ${e.code == 'wrong-password' ? 'Password lama salah.' : 'Terjadi kesalahan.'}";
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(msg), backgroundColor: Colors.red));
                }
              } catch (e) {
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Error: $e"), backgroundColor: Colors.red));
              }
            },
            child: const Text("Simpan",
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // LOGIC LUPA PASSWORD
  // ==========================================
  void _requestForgotPassword() async {
    try {
      if (user?.email != null) {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("Link reset password telah dikirim ke ${user!.email}"),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Gagal mengirim link reset: $e"),
          backgroundColor: Colors.red));
    }
  }

  // ==========================================
  // LOGIC TAMBAH ALAMAT/BIODATA (Simulasi)
  // ==========================================
  void _showBiodataDialog() {
    String tempDate = _birthDate;
    String tempAddress = _address;

    showDialog(
      context: context,
      builder: (ctx) =>
          StatefulBuilder(builder: (dialogContext, setDialogState) {
        return AlertDialog(
          title: const Text("Biodata & Alamat"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tanggal Lahir: $tempDate",
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                TextButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: DateFormat('d MMM yyyy').parse(tempDate),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      builder: (context, child) => Theme(
                        data: ThemeData.light().copyWith(
                            colorScheme: const ColorScheme.light(
                                primary: AppColors.primary)),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        tempDate = DateFormat('d MMM yyyy').format(picked);
                      });
                    }
                  },
                  child: const Text("Pilih Tanggal Lahir",
                      style: TextStyle(color: AppColors.accent)),
                ),
                const Divider(),
                TextField(
                  controller: TextEditingController(text: tempAddress),
                  maxLines: 3,
                  onChanged: (val) => tempAddress = val,
                  decoration: const InputDecoration(
                      labelText: "Alamat Lengkap",
                      border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Batal")),
            TextButton(
              onPressed: () {
                setState(() {
                  _birthDate = tempDate;
                  _address = tempAddress;
                });
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Biodata berhasil diperbarui (Simulasi)"),
                    backgroundColor: Colors.blue));
              },
              child: const Text("Simpan",
                  style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      }),
    );
  }

  // ==========================================
  // BUILD UTAMA SUB SETTINGS
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Pengaturan Akun",
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- KELOMPOK PROFIL ---
            const Text("Profil & Biodata",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            _buildInfoTile("Nama Lengkap", user?.displayName ?? "Pengguna",
                Icons.person_outline),
            _buildInfoTile(
                "Tanggal Lahir", _birthDate, Icons.calendar_today_outlined),
            _buildInfoTile("Alamat", _address, Icons.location_on_outlined,
                isMultiline: true),
            _buildMenuItem(context, "Edit Nama", Icons.edit_note_outlined,
                _showEditProfileDialog),
            _buildMenuItem(context, "Edit Biodata / Alamat",
                Icons.badge_outlined, _showBiodataDialog),

            const SizedBox(height: 30),

            // --- KELOMPOK KEAMANAN ---
            const Text("Keamanan Akun",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            _buildMenuItem(context, "Ganti Password", Icons.vpn_key_outlined,
                _showChangePasswordDialog),
            _buildMenuItem(context, "Lupa Password (Kirim Email)",
                Icons.email_outlined, _requestForgotPassword),

            // ✅ HAPUS BAGIAN PENGATURAN UMUM DARI SINI
            const SizedBox(height: 30),

            // Tambahan info untuk debugging
            const Center(
                child: Text("Pengaturan Akun Selesai",
                    style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  // Widget Pembantu Info Tile
  Widget _buildInfoTile(String title, String subtitle, IconData icon,
      {bool isMultiline = false}) {
    // ... (widget ini sama) ...
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              maxLines: isMultiline ? 3 : 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // Widget Pembantu Menu Item
  Widget _buildMenuItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    // ... (widget ini sama) ...
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
        leading: Icon(icon, color: AppColors.textPrimary),
        title: Text(title,
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        trailing:
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }
}

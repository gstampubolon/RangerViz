import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class GeneralSettingsScreen extends StatefulWidget {
  const GeneralSettingsScreen({super.key});

  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> {
  // State untuk mode gelap (simulasi)
  bool _isDarkMode = false; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Pengaturan Umum", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sesuai Screenshot: Judul Pengaturan Aplikasi
            const Text("Pengaturan Aplikasi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: SwitchListTile(
                title: const Text("Mode Gelap (Dark Mode)", style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(_isDarkMode ? "Aktif" : "Non-aktif", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                value: _isDarkMode,
                onChanged: (bool value) {
                  setState(() {
                    _isDarkMode = value;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mode Gelap: ${value ? 'Aktif' : 'Non-aktif'} (Simulasi)")));
                  });
                },
                secondary: Icon(
                  _isDarkMode ? Icons.dark_mode : Icons.light_mode, 
                  color: _isDarkMode ? AppColors.primary : Colors.grey
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
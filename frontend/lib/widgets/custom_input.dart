import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final IconData icon;
  final int maxLines;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  // ✅ TAMBAHAN: Parameter Validator
  final String? Function(String?)? validator;

  const CustomInput({
    super.key,
    required this.label,
    required this.hint,
    this.isPassword = false,
    required this.icon,
    this.maxLines = 1,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator, // ✅ Masukkan di constructor
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Icon(icon, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                // ✅ GANTI DARI TextField KE TextFormField
                child: TextFormField(
                  controller: controller,
                  validator: validator, // ✅ Pasang validator di sini
                  keyboardType: keyboardType,
                  obscureText: isPassword,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    // Style pesan error biar rapi
                    errorStyle: const TextStyle(height: 0.8), 
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
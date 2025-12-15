import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';

class DashboardDetailScreen extends StatelessWidget {
  final String title;
  final String mainValue;
  final IconData icon;

  final List<Map<String, dynamic>>? listData;
  final Map<String, dynamic>? mapData;

  const DashboardDetailScreen(
      {super.key,
      required this.title,
      required this.mainValue,
      required this.icon,
      this.listData,
      this.mapData});

  String _formatCurrency(num value) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(title,
            style: const TextStyle(
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                // ✅ UPDATE: withValues
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      // ✅ UPDATE: withValues
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 40, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text(mainValue,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (listData != null && listData!.isNotEmpty) ...[
              const Text("Rincian Data",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              ...listData!.map((item) {
                String label = item['name'] ?? item['month'] ?? '-';
                String trailingText = "";
                if (item['revenue'] != null) {
                  trailingText = _formatCurrency(item['revenue']);
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade100,
                            blurRadius: 4,
                            offset: const Offset(0, 2))
                      ]),
                  child: ListTile(
                    leading:
                        const Icon(Icons.bar_chart, color: AppColors.accent),
                    title: Text(label,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(
                        item['sales'] != null
                            ? "Terjual: ${item['sales']} unit"
                            : "-",
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: Text(trailingText,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 13)),
                  ),
                );
              }),
            ],
            if (mapData != null && mapData!.isNotEmpty) ...[
              const Text("Rincian Kategori",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              ...mapData!.entries.map((entry) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade100,
                            blurRadius: 4,
                            offset: const Offset(0, 2))
                      ]),
                  child: ListTile(
                    leading:
                        const Icon(Icons.pie_chart_outline, color: Colors.teal),
                    title: Text(entry.key,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    trailing: Text(_formatCurrency(entry.value),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 13)),
                  ),
                );
              }),
            ]
          ],
        ),
      ),
    );
  }
}

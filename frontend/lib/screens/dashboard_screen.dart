import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../core/app_colors.dart';
import '../models/dashboard_model.dart';
import '../core/firestore_service.dart';
import 'dashboard_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<DashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _dashboardFuture = _firestoreService.fetchDashboardSummary();
    });
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  void _goToDetail(String title, String value, IconData icon,
      {List<Map<String, dynamic>>? list, Map<String, dynamic>? map}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DashboardDetailScreen(
                title: title,
                mainValue: value,
                icon: icon,
                listData: list,
                mapData: map)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Executive Dashboard",
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.primary),
              onPressed: _refreshData)
        ],
      ),
      body: FutureBuilder<DashboardData>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          // ✅ FIX: Wrapped in curly braces
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          // ✅ FIX: Wrapped in curly braces
          if (!snapshot.hasData) {
            return const Center(child: Text("Data Kosong"));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. KARTU UTAMA
                _buildSummaryCard(
                  title: "Total Pendapatan",
                  value: _formatCurrency(data.totalSales),
                  icon: Icons.monetization_on,
                  isDark: true,
                  onTap: () => _goToDetail("Pendapatan",
                      _formatCurrency(data.totalSales), Icons.monetization_on,
                      map: data.salesByCategory),
                ),
                const SizedBox(height: 24),

                // 2. LINE CHART CARD
                _buildChartCard(
                  title: "Tren Penjualan Bulanan",
                  icon: Icons.show_chart,
                  onTap: () => _goToDetail(
                      "Tren Bulanan", "Data Tahunan", Icons.show_chart,
                      list: data.monthlySalesTrend),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: CustomPaint(
                        painter:
                            ElegantLineChartPainter(data.monthlySalesTrend)),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. PIE CHART CARD
                _buildChartCard(
                  title: "Penjualan per Kategori",
                  icon: Icons.pie_chart,
                  onTap: () => _goToDetail(
                      "Kategori", "Sebaran Data", Icons.pie_chart,
                      map: data.salesByCategory),
                  child: Row(
                    children: [
                      SizedBox(
                          height: 130,
                          width: 130,
                          child: CustomPaint(
                              painter: ElegantPieChartPainter(
                                  data.salesByCategory))),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _buildPieLegend(data.salesByCategory),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. TOP PRODUCTS
                const Text("Produk Terlaris",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                ...data.topProducts
                    .take(5)
                    .map((prod) => _buildProductRow(prod)),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
      {required String title,
      required String value,
      required IconData icon,
      required VoidCallback onTap,
      bool isDark = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                  size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                      fontSize: 13,
                      letterSpacing: 0.5)),
            ]),
            const SizedBox(height: 12),
            Text(value,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Tap untuk detail rincian",
                      style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey,
                          fontSize: 11)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios,
                      size: 10, color: isDark ? Colors.white54 : Colors.grey)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(
      {required String title,
      required IconData icon,
      required Widget child,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      letterSpacing: 0.5)),
            ]),
            const SizedBox(height: 24),
            child,
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Text("Tap untuk detail rincian",
                    style: TextStyle(color: Colors.grey, fontSize: 11)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey)
              ]),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProductRow(Map<String, dynamic> prod) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.bar_chart,
                color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prod['name'] ?? '-',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text("${prod['sales'] ?? 0} terjual",
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(_formatCurrency((prod['revenue'] as num?)?.toDouble() ?? 0),
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 13)),
        ],
      ),
    );
  }

  List<Widget> _buildPieLegend(Map<String, dynamic> data) {
    int index = 0;
    return data.entries.take(4).map((e) {
      Color color = ElegantPieChartPainter
          .elegantPalette[index % ElegantPieChartPainter.elegantPalette.length];
      index++;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(
                child: Text(e.key,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis)),
          ],
        ),
      );
    }).toList();
  }
}

class ElegantLineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  ElegantLineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..shader =
          const LinearGradient(colors: [AppColors.primary, Color(0xFF64748B)])
              .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dotBorder = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    double maxVal = 0;
    for (var d in data) {
      if ((d['sales'] as num) > maxVal) maxVal = (d['sales'] as num).toDouble();
    }
    if (maxVal == 0) maxVal = 1;

    double stepX = size.width / (data.length - 1);
    var path = Path();

    for (int i = 0; i < data.length; i++) {
      double val = (data[i]['sales'] as num).toDouble();
      double x = i * stepX;
      double y = size.height - (val / maxVal * size.height * 0.8) - 10;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    for (int i = 0; i < data.length; i++) {
      double val = (data[i]['sales'] as num).toDouble();
      double x = i * stepX;
      double y = size.height - (val / maxVal * size.height * 0.8) - 10;
      canvas.drawCircle(Offset(x, y), 5, dotBorder);
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ElegantPieChartPainter extends CustomPainter {
  final Map<String, dynamic> data;
  ElegantPieChartPainter(this.data);

  static const List<Color> elegantPalette = [
    Color(0xFF1E293B),
    Color(0xFF64748B),
    Color(0xFF0D9488),
    Color(0xFFD97706),
    Color(0xFF94A3B8)
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    double total = 0;
    data.forEach((k, v) => total += (v as num).toDouble());
    double startAngle = -pi / 2;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    int index = 0;
    data.forEach((key, value) {
      double sweepAngle = ((value as num).toDouble() / total) * 2 * pi;
      final paint = Paint()
        ..color = elegantPalette[index % elegantPalette.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle + 0.05;
      index++;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

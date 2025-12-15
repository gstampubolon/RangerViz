import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../core/app_colors.dart';
import '../core/firestore_service.dart';

class PaymentWaitingScreen extends StatefulWidget {
  final String orderId;
  final String paymentMethod;
  final String paymentCode;
  final double totalAmount;

  const PaymentWaitingScreen({
    super.key,
    required this.orderId,
    required this.paymentMethod,
    required this.paymentCode,
    required this.totalAmount,
  });

  @override
  State<PaymentWaitingScreen> createState() => _PaymentWaitingScreenState();
}

class _PaymentWaitingScreenState extends State<PaymentWaitingScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  String _formatCurrency(double value) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  // Fungsi Konfirmasi Bayar
  void _confirmPayment() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulasi

    await _firestoreService.updateOrderStatus(widget.orderId, 'Dipesan');

    if (mounted) {
      setState(() => _isLoading = false);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Column(children: [
          Icon(Icons.check_circle, color: Colors.green, size: 60),
          SizedBox(height: 10),
          Text("Pembayaran Berhasil!")
        ]),
        content: const Text(
            "Terima kasih. Pesanan Anda sedang diproses oleh penjual."),
        actions: [
          TextButton(
            onPressed: () {
              // ✅ NAVIGASI KE HOME, BUKA TAB PESANAN (Index 2)
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home', (route) => false,
                  arguments: 2 // Dikirim ke MainScreen
                  );
            },
            child: const Text("Lihat Pesanan Saya"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isBarcode = widget.paymentMethod.contains("Indomaret") ||
        widget.paymentMethod.contains("Alfamart");
    bool isQR = widget.paymentMethod.contains("Gopay");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Menunggu Pembayaran",
            style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          // Close juga balik ke Pesanan
          onPressed: () => Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (route) => false, arguments: 2),
        ),
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.orange.shade50,
            child: Column(
              children: [
                Text("Batas Akhir Pembayaran",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 4),
                const Text("23 Jam 59 Menit",
                    style: TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(_formatCurrency(widget.totalAmount),
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(widget.paymentMethod,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        if (isBarcode) ...[
                          SizedBox(
                              height: 80,
                              width: double.infinity,
                              child: CustomPaint(painter: BarcodePainter())),
                          const SizedBox(height: 16),
                        ] else if (isQR) ...[
                          SizedBox(
                              height: 200,
                              width: 200,
                              child: CustomPaint(painter: QRPainter())),
                          const SizedBox(height: 16),
                        ],
                        const Text("Nomor Pembayaran / Kode",
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(widget.paymentCode,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: AppColors.primary),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Panduan Pembayaran",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16))),
                  const SizedBox(height: 10),
                  _buildStep(
                      1, "Buka aplikasi pembayaran atau datang ke gerai."),
                  _buildStep(
                      2, "Scan QR atau tunjukkan Barcode/Nomor di atas."),
                  _buildStep(3, "Periksa nominal tagihan."),
                  _buildStep(4, "Simpan bukti pembayaran."),
                ],
              ),
            ),
          ),

          // Tombol Bayar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4))
            ]),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmPayment,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Saya Sudah Membayar",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStep(int num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
              radius: 10,
              backgroundColor: Colors.grey[200],
              child: Text("$num",
                  style: const TextStyle(fontSize: 10, color: Colors.black))),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: const TextStyle(color: Colors.black87, height: 1.4))),
        ],
      ),
    );
  }
}

// Painters
class BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    var rand = Random();
    double x = 0;
    while (x < size.width) {
      double w = rand.nextInt(4) + 2.0;
      if (x + w > size.width) break;
      canvas.drawRect(Rect.fromLTWH(x, 0, w, size.height), paint);
      x += w + (rand.nextInt(3) + 2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QRPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    double cellSize = size.width / 25;
    var rand = Random();
    void drawFinder(double ox, double oy) {
      canvas.drawRect(Rect.fromLTWH(ox, oy, 7 * cellSize, 7 * cellSize), paint);
      canvas.drawRect(
          Rect.fromLTWH(
              ox + cellSize, oy + cellSize, 5 * cellSize, 5 * cellSize),
          Paint()..color = Colors.white);
      canvas.drawRect(
          Rect.fromLTWH(
              ox + 2 * cellSize, oy + 2 * cellSize, 3 * cellSize, 3 * cellSize),
          paint);
    }

    drawFinder(0, 0);
    drawFinder(size.width - 7 * cellSize, 0);
    drawFinder(0, size.height - 7 * cellSize);
    for (int i = 0; i < 25; i++) {
      for (int j = 0; j < 25; j++) {
        if ((i < 8 && j < 8) || (i > 16 && j < 8) || (i < 8 && j > 16)) {
          continue;
        }
        if (rand.nextBool()) {
          canvas.drawRect(
              Rect.fromLTWH(i * cellSize, j * cellSize, cellSize, cellSize),
              paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

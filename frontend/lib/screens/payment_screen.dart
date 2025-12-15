import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../core/app_colors.dart';
import '../models/product_model.dart';
import '../core/firestore_service.dart';
import 'payment_waiting_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Product? product;
  final bool isCartCheckout;
  final double totalPrice;

  const PaymentScreen(
      {super.key,
      this.product,
      this.isCartCheckout = false,
      this.totalPrice = 0});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  String? _selectedPaymentMethod;

  String _formatCurrency(double value) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  String _generatePaymentCode(String method) {
    var rand = Random();
    if (method.contains("BCA")) return "8800${rand.nextInt(99999999)}";
    if (method.contains("BNI")) return "9900${rand.nextInt(99999999)}";
    if (method.contains("BSI")) return "5500${rand.nextInt(99999999)}";
    if (method.contains("Indomaret")) return "IND${rand.nextInt(99999999)}";
    if (method.contains("Alfamart")) return "ALF${rand.nextInt(99999999)}";
    return "QR-${rand.nextInt(999999)}";
  }

  void _handlePayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pilih metode pembayaran dulu!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String paymentCode = _generatePaymentCode(_selectedPaymentMethod!);
      String orderId = "";

      // 1. Simpan Order
      if (widget.isCartCheckout) {
        orderId = await _firestoreService.checkoutCart(
            widget.totalPrice, _selectedPaymentMethod!, paymentCode);
      } else if (widget.product != null) {
        orderId = await _firestoreService.createOrder(
            widget.product!, _selectedPaymentMethod!, paymentCode);
      }

      if (mounted) {
        setState(() => _isLoading = false);

        if (_selectedPaymentMethod == 'COD') {
          _showCODSuccess();
        } else {
          // 2. NAVIGASI KE PAGE MENUNGGU BAYAR (Bukan Popup)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentWaitingScreen(
                orderId: orderId,
                paymentMethod: _selectedPaymentMethod!,
                paymentCode: paymentCode,
                totalAmount: widget.isCartCheckout
                    ? widget.totalPrice
                    : (widget.product?.price ?? 0),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Gagal: $e")));
      }
    }
  }

  void _showCODSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Column(children: [
          Icon(Icons.check_circle, color: Colors.green, size: 60),
          SizedBox(height: 10),
          Text("Pesanan Diterima!")
        ]),
        content: const Text("Silakan siapkan uang tunai saat kurir datang."),
        actions: [
          TextButton(
            // ✅ FIX BUG: Balik ke Main Screen, Tab index 2
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                '/main', (route) => false,
                arguments: 2),
            child: const Text("Lihat Pesanan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double displayPrice = widget.isCartCheckout
        ? widget.totalPrice
        : (widget.product?.price ?? 0);
    return Scaffold(
      appBar: AppBar(
          title: const Text("Pembayaran",
              style: TextStyle(color: AppColors.textPrimary)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textPrimary)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Tagihan",
                      style: TextStyle(color: Colors.white70)),
                  Text(_formatCurrency(displayPrice),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text("Pilih Metode Pembayaran",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            _buildPaymentOption(
                title: "Cash on Delivery (COD)",
                icon: Icons.local_shipping_outlined,
                value: "COD"),
            ExpansionTile(
              leading: const Icon(Icons.account_balance),
              title: const Text("Transfer Virtual Account"),
              children: [
                _buildRadioItem("Bank BCA", "BCA Virtual Account"),
                _buildRadioItem("Bank BNI", "BNI Virtual Account"),
                _buildRadioItem("Bank BSI", "BSI Virtual Account")
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text("E-Wallet"),
              children: [_buildRadioItem("Gopay QRIS", "Gopay")],
            ),
            ExpansionTile(
              leading: const Icon(Icons.store),
              title: const Text("Minimarket"),
              children: [
                _buildRadioItem("Indomaret", "Indomaret"),
                _buildRadioItem("Alfamart", "Alfamart")
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handlePayment,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Bayar Sekarang",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioItem(String label, String value) {
    return RadioListTile<String>(
        title: Text(label),
        value: value,
        groupValue: _selectedPaymentMethod,
        activeColor: AppColors.primary,
        onChanged: (val) => setState(() => _selectedPaymentMethod = val));
  }

  Widget _buildPaymentOption(
      {required String title, required IconData icon, required String value}) {
    bool isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color:
                isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
            border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
          const SizedBox(width: 12),
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : Colors.black87)),
          if (isSelected) const Spacer(),
          if (isSelected)
            const Icon(Icons.check_circle, color: AppColors.primary)
        ]),
      ),
    );
  }
}

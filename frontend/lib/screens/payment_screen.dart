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

  const PaymentScreen({
    super.key,
    this.product,
    this.isCartCheckout = false,
    this.totalPrice = 0,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  String? _selectedPaymentMethod;

  String _formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  String _generatePaymentCode(String method) {
    final rand = Random();
    if (method.contains("BCA")) return "8800${rand.nextInt(99999999)}";
    if (method.contains("BNI")) return "9900${rand.nextInt(99999999)}";
    if (method.contains("BSI")) return "5500${rand.nextInt(99999999)}";
    if (method.contains("Indomaret")) return "IND${rand.nextInt(99999999)}";
    if (method.contains("Alfamart")) return "ALF${rand.nextInt(99999999)}";
    return "QR-${rand.nextInt(999999)}";
  }

  Future<void> _handlePayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih metode pembayaran dulu!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final paymentCode =
          _generatePaymentCode(_selectedPaymentMethod!);
      String orderId = "";

      if (widget.isCartCheckout) {
        orderId = await _firestoreService.checkoutCart(
          widget.totalPrice,
          _selectedPaymentMethod!,
          paymentCode,
        );
      } else if (widget.product != null) {
        orderId = await _firestoreService.createOrder(
          widget.product!,
          _selectedPaymentMethod!,
          paymentCode,
        );
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (_selectedPaymentMethod == 'COD') {
        _showCODSuccess();
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentWaitingScreen(
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
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal: $e")));
    }
  }

  void _showCODSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text("Pesanan Diterima!"),
          ],
        ),
        content:
            const Text("Silakan siapkan uang tunai saat kurir datang."),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pushNamedAndRemoveUntil(
              '/main',
              (route) => false,
              arguments: 2,
            ),
            child: const Text("Lihat Pesanan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayPrice = widget.isCartCheckout
        ? widget.totalPrice
        : (widget.product?.price ?? 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pembayaran"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: RadioGroup<String>(
          groupValue: _selectedPaymentMethod,
          onChanged: (value) =>
              setState(() => _selectedPaymentMethod = value),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _totalBox(displayPrice),
              const SizedBox(height: 24),
              const Text(
                "Pilih Metode Pembayaran",
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              _paymentCard(
                title: "Cash on Delivery (COD)",
                icon: Icons.local_shipping_outlined,
                value: "COD",
              ),

              ExpansionTile(
                title: const Text("Transfer Virtual Account"),
                children: const [
                  RadioListTile(
                      title: Text("Bank BCA"),
                      value: "BCA Virtual Account"),
                  RadioListTile(
                      title: Text("Bank BNI"),
                      value: "BNI Virtual Account"),
                  RadioListTile(
                      title: Text("Bank BSI"),
                      value: "BSI Virtual Account"),
                ],
              ),

              ExpansionTile(
                title: const Text("E-Wallet"),
                children: const [
                  RadioListTile(
                      title: Text("Gopay QRIS"), value: "Gopay"),
                ],
              ),

              ExpansionTile(
                title: const Text("Minimarket"),
                children: const [
                  RadioListTile(
                      title: Text("Indomaret"), value: "Indomaret"),
                  RadioListTile(
                      title: Text("Alfamart"), value: "Alfamart"),
                ],
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handlePayment,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Bayar Sekarang"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _totalBox(double price) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Total Tagihan",
              style: TextStyle(color: Colors.white70)),
          Text(
            _formatCurrency(price),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard({
    required String title,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _selectedPaymentMethod == value;

    return RadioListTile<String>(
      value: value,
      title: Text(title),
      secondary: Icon(icon),
      tileColor: isSelected
          ? AppColors.primary.withValues(alpha: 0.05)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : Colors.grey.shade300,
        ),
      ),
    );
  }
}

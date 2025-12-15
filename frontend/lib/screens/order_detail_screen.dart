import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_colors.dart';
import '../core/firestore_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const OrderDetailScreen(
      {super.key, required this.orderId, required this.orderData});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  String _formatCurrency(double value) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "-";
    return DateFormat('dd MMMM yyyy, HH:mm').format(timestamp.toDate());
  }

  void _confirmPayment() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 2));
      await _firestoreService.updateOrderStatus(widget.orderId, 'Dipesan');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Pembayaran Dikonfirmasi!"),
            backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _cancelOrder() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Batalkan Pesanan?"),
        content: const Text(
            "Pesanan akan dibatalkan dan tetap tersimpan di riwayat."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Kembali")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                await _firestoreService.updateOrderStatus(
                    widget.orderId, 'Dibatalkan');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pesanan Dibatalkan")));
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Error: $e"), backgroundColor: Colors.red));
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child:
                const Text("Ya, Batalkan", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String status = widget.orderData['status'] ?? 'Dipesan';
    String paymentCode = widget.orderData['payment_code'] ?? '-';
    double total =
        (widget.orderData['total_price'] ?? widget.orderData['price'] ?? 0)
            .toDouble();

    bool isPending = status == 'Menunggu Pembayaran';
    bool isCancelled = status == 'Dibatalkan';

    Color statusColor = AppColors.primary;
    Color statusBg = AppColors.background;

    if (isPending) {
      statusColor = Colors.orange;
      statusBg = Colors.orange.shade50;
    } else if (isCancelled) {
      statusColor = Colors.red;
      statusBg = Colors.red.shade50;
    } else if (status == 'Dipesan') {
      statusColor = Colors.blueGrey;
      statusBg = Colors.blueGrey.shade50;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Rincian Pesanan",
            style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // STATUS CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(12),
                      // ✅ UPDATE: withValues
                      border:
                          Border.all(color: statusColor.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Text("Status Pesanan",
                            style: TextStyle(
                                color: statusColor.withValues(alpha: 0.8),
                                fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(status,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: statusColor)),
                        const SizedBox(height: 8),
                        Text(
                            "Invoice: #${widget.orderId.substring(0, 8).toUpperCase()}",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text("Detail Produk",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8)),
                          child:
                              const Icon(Icons.inventory_2, color: Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  widget.orderData['name'] ??
                                      'Checkout Keranjang',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const Text("1 x Barang",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(_formatCurrency(total),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text("Info Pengiriman",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildInfoRow("Tanggal Pemesanan",
                      _formatDate(widget.orderData['timestamp'])),
                  _buildInfoRow("Metode Pembayaran",
                      widget.orderData['payment_method'] ?? '-'),

                  if (paymentCode != '-' && isPending)
                    _buildInfoRow("Kode Bayar", paymentCode, isBold: true),

                  const Divider(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Pembayaran",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(_formatCurrency(total),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isPending)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                // ✅ UPDATE: withValues
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4))
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _confirmPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Saya Sudah Bayar",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _cancelOrder,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Batalkan Pesanan",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: isBold ? AppColors.primary : Colors.black87)),
        ],
      ),
    );
  }
}

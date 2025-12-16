import 'package:flutter/foundation.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dashboard_model.dart';
import '../models/product_model.dart';

class FirestoreService {
  // ✅ PERBAIKAN PENTING: Gunakan 'get'
  // Ini mencegah error "No Firebase App" karena _db baru dipanggil saat dibutuhkan
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // ==========================================
  // BAGIAN 1: DASHBOARD
  // ==========================================
  Future<DashboardData> fetchDashboardSummary() async {
    try {
      DocumentSnapshot doc = await _db.collection('dashboard_stats').doc('summary').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return DashboardData.fromJson(data);
      } else {
        debugPrint("Warning: Dokumen dashboard_stats/summary tidak ditemukan (404)");
        return DashboardData(
          totalSales: 0,
          monthlySalesTrend: [],
          salesByCategory: {},
          topProducts: [],
          periodOfAnalysis: "-",
          averageTransactionValue: 0,
          totalProductsSold: 0,
          totalCustomers: 0,
          bestSellerProduct: "-",
          topCategory: "-",
        );
      }
    } catch (e) {
      debugPrint("Error 500 (Dashboard): $e");
      return DashboardData(
        totalSales: 0,
        monthlySalesTrend: [],
        salesByCategory: {},
        topProducts: [],
        periodOfAnalysis: "-",
        averageTransactionValue: 0,
        totalProductsSold: 0,
        totalCustomers: 0,
        bestSellerProduct: "-",
        topCategory: "-",
      );
    }
  }

  // ==========================================
  // BAGIAN 2: PRODUK
  // ==========================================
  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromSnapshot(doc.id, doc.data())).toList();
    });
  }
  
  Future<void> addProduct(Product product) async { await _db.collection('products').add(product.toMap()); }
  Future<void> updateProduct(Product product) async { await _db.collection('products').doc(product.id).update(product.toMap()); }
  Future<void> deleteProduct(String id) async { await _db.collection('products').doc(id).delete(); }

  // ==========================================
  // BAGIAN 3: CART
  // ==========================================
  Stream<QuerySnapshot> getCartItems() {
    return _db.collection('cart').orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> addToCart(Product product) async {
    await _db.collection('cart').add({
      'product_id': product.id,
      'name': product.name,
      'price': product.price,
      'imageUrl': product.imageUrl ?? '', 
      'quantity': 1,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
  
  Future<void> removeFromCart(String docId) async { await _db.collection('cart').doc(docId).delete(); }

  // ==========================================
  // BAGIAN 4: ORDER & TRANSAKSI
  // ==========================================
  Stream<QuerySnapshot> getOrders() {
    return _db.collection('orders').orderBy('timestamp', descending: true).snapshots();
  }

  Future<String> checkoutCart(double totalPrice, String paymentMethod, String paymentCode) async {
    String initialStatus = paymentMethod == 'COD' ? 'Dipesan' : 'Menunggu Pembayaran';
    DocumentReference ref = await _db.collection('orders').add({
      'total_price': totalPrice,
      'type': 'cart_checkout',
      'status': initialStatus,
      'payment_method': paymentMethod,
      'payment_code': paymentCode,
      'timestamp': FieldValue.serverTimestamp(),
    });

    var snapshots = await _db.collection('cart').get();
    for (var doc in snapshots.docs) { await doc.reference.delete(); }
    
    return ref.id;
  }

  Future<String> createOrder(Product product, String paymentMethod, String paymentCode) async {
    String initialStatus = paymentMethod == 'COD' ? 'Dipesan' : 'Menunggu Pembayaran';
    DocumentReference ref = await _db.collection('orders').add({
      'product_id': product.id,
      'name': product.name,
      'price': product.price,
      'status': initialStatus,
      'payment_method': paymentMethod,
      'payment_code': paymentCode,
      'type': 'buy_now',
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _db.collection('products').doc(product.id).update({
      'stock': FieldValue.increment(-1),
      'sales': FieldValue.increment(1),
    });

    return ref.id;
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.collection('orders').doc(orderId).update({'status': status});
  }
}
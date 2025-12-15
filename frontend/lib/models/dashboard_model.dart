import 'package:flutter/material.dart';


class DashboardData {
  final double totalSales; // Poin 1: Total Pendapatan
  final List<Map<String, dynamic>> monthlySalesTrend; // Poin 2: Tren Bulanan
  final Map<String, dynamic> salesByCategory; // Poin 3: Kategori (Pie Chart)
  final List<Map<String, dynamic>> topProducts; // Poin 4: Produk Terlaris
  
  // Data Tambahan (Opsional/Turunan)
  final String periodOfAnalysis;
  final double averageTransactionValue; 
  final int totalProductsSold;
  final int totalCustomers;
  final String bestSellerProduct;
  final String topCategory;

  DashboardData({
    required this.totalSales,
    required this.monthlySalesTrend,
    required this.salesByCategory,
    required this.topProducts,
    required this.periodOfAnalysis,
    required this.averageTransactionValue,
    required this.totalProductsSold,
    required this.totalCustomers,
    required this.bestSellerProduct,
    required this.topCategory,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    // 1. Parsing Sales By Category
    Map<String, dynamic> categoryMap = {};
    String topCat = '-';
    try {
      if (json['sales_by_category'] is Map) {
        categoryMap = Map<String, dynamic>.from(json['sales_by_category']);
        if (categoryMap.isNotEmpty) {
          var sortedKeys = categoryMap.keys.toList(growable: false)
            ..sort((k1, k2) => (categoryMap[k2] as num).compareTo(categoryMap[k1] as num));
          topCat = sortedKeys.first;
        }
      }
    } catch (e) { debugPrint("Error Cat: $e"); }

    // 2. Parsing Top Products
    List<Map<String, dynamic>> productsList = [];
    String bestProduct = '-';
    try {
      if (json['top_products'] is List) {
        for (var item in (json['top_products'] as List)) {
          if (item is Map) productsList.add(Map<String, dynamic>.from(item));
        }
        if (productsList.isNotEmpty) bestProduct = productsList[0]['name'] ?? '-';
      }
    } catch (e) { debugPrint("Error Prod: $e"); }

    // 3. Parsing Monthly Trend (Untuk Grafik Garis)
    List<Map<String, dynamic>> trendList = [];
    try {
      if (json['monthly_sales_trend'] is List) {
        for (var item in (json['monthly_sales_trend'] as List)) {
          if (item is Map) trendList.add(Map<String, dynamic>.from(item));
        }
      }
    } catch (e) { debugPrint("Error Trend: $e"); }

    return DashboardData(
      totalSales: (json['total_sales'] as num?)?.toDouble() ?? 0.0,
      monthlySalesTrend: trendList,
      salesByCategory: categoryMap,
      topProducts: productsList,
      
      // Data Turunan / Default
      periodOfAnalysis: 'Realtime Data',
      averageTransactionValue: 0, 
      totalProductsSold: 0, 
      totalCustomers: 0,
      bestSellerProduct: bestProduct,
      topCategory: topCat,
    );
  }
}
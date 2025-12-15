import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../models/product_model.dart';
import '../core/firestore_service.dart';
import 'product_add_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'Semua';
  String _sortOption = 'Nama (A-Z)';
  String _searchQuery = '';

  final List<String> _sortOptions = [
    'Nama (A-Z)',
    'Harga (Termurah)',
    'Harga (Termahal)',
    'Terlaris (Sales)',
  ];

  String _formatCurrency(double value) {
    final format =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(value);
  }

  // Fungsi Quick Add
  void _quickAddToCart(Product product) async {
    await _firestoreService.addToCart(product);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${product.name} masuk keranjang!"),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Daftar Produk",
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ProductAddScreen()));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Product>>(
        stream: _firestoreService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          var products = snapshot.data ?? [];

          // Logika Filter & Sort (Sama seperti sebelumnya)
          Set<String> categories = {'Semua'};
          categories.addAll(
              products.map((p) => p.category).where((c) => c.isNotEmpty));

          if (_searchQuery.isNotEmpty) {
            products = products
                .where((p) =>
                    p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();
          }

          if (_selectedCategory != 'Semua') {
            products =
                products.where((p) => p.category == _selectedCategory).toList();
          }

          products.sort((a, b) {
            switch (_sortOption) {
              case 'Harga (Termurah)':
                return a.price.compareTo(b.price);
              case 'Harga (Termahal)':
                return b.price.compareTo(a.price);
              case 'Terlaris (Sales)':
                return b.sales.compareTo(a.sales);
              case 'Nama (A-Z)':
              default:
                return a.name.toLowerCase().compareTo(b.name.toLowerCase());
            }
          });

          return Column(
            children: [
              // HEADER
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                color: AppColors.background,
                child: Column(
                  children: [
                    // SEARCH BAR (BUG FIX: Pakai onSubmitted)
                    TextField(
                      controller: _searchController,
                      // ✅ FIX: Ganti onChanged jadi onSubmitted biar gak reload tiap huruf
                      onSubmitted: (val) => setState(() => _searchQuery = val),
                      textInputAction: TextInputAction
                          .search, // Tombol keyboard jadi 'Search'
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: "Cari & Tekan Enter...",
                        hintStyle:
                            const TextStyle(color: AppColors.textSecondary),
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide:
                                const BorderSide(color: AppColors.shadow)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide:
                                const BorderSide(color: AppColors.primary)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // FILTER & SORT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildSmallDropdown(
                          value: categories.contains(_selectedCategory)
                              ? _selectedCategory
                              : 'Semua',
                          items: categories.toList(),
                          onChanged: (val) =>
                              setState(() => _selectedCategory = val!),
                          icon: Icons.filter_list,
                        ),
                        const SizedBox(width: 8),
                        _buildSmallDropdown(
                          value: _sortOption,
                          items: _sortOptions,
                          onChanged: (val) =>
                              setState(() => _sortOption = val!),
                          icon: Icons.sort,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // LIST DATA
              Expanded(
                child: products.isEmpty
                    ? const Center(
                        child: Text("Produk tidak ditemukan",
                            style: TextStyle(color: AppColors.textSecondary)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: products.length,
                        separatorBuilder: (ctx, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.shadow),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetailScreen(
                                                  product: product)));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: const Icon(
                                            Icons.inventory_2_outlined,
                                            color: AppColors.textSecondary),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(product.name,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color:
                                                        AppColors.textPrimary)),
                                            Text(
                                                "${product.category} • Stok: ${product.stock}",
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors
                                                        .textSecondary)),
                                            const SizedBox(height: 4),
                                            Text(_formatCurrency(product.price),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: AppColors.primary)),
                                          ],
                                        ),
                                      ),
                                      // ✅ TOMBOL QUICK ADD TO CART
                                      IconButton(
                                        icon: const Icon(
                                            Icons.add_shopping_cart,
                                            color: AppColors.accent),
                                        onPressed: () =>
                                            _quickAddToCart(product),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSmallDropdown(
      {required String value,
      required List<String> items,
      required Function(String?) onChanged,
      required IconData icon}) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.shadow)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(icon, size: 16, color: AppColors.textSecondary)),
          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          isDense: true,
          dropdownColor: AppColors.surface,
          items: items
              .map((String item) =>
                  DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../core/firestore_service.dart';
import '../core/app_colors.dart';

class ProductAddScreen extends StatefulWidget {
  const ProductAddScreen({super.key});

  @override
  State<ProductAddScreen> createState() => _ProductAddScreenState();
}

class _ProductAddScreenState extends State<ProductAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  // Controller Text
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // ✅ VARIABLE BARU: Untuk Dropdown Kategori
  String? _selectedCategory;
  final List<String> _categoryOptions = [
    'Furniture',
    'Office Supplies',
    'Technology',
    'Electronics',
    'Accessories',
    'Lainnya'
  ];

  bool _isLoading = false;

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final product = Product(
          id: '',
          name: _nameController.text,
          price: double.parse(_priceController.text),
          stock: int.parse(_stockController.text),
          // ✅ GUNAKAN VALUE DARI DROPDOWN
          category: _selectedCategory!,
          description: _descController.text,
          sales: 0,
        );

        await _firestoreService.addProduct(product);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Produk berhasil ditambahkan"),
              backgroundColor: Colors.green));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Gagal: $e"), backgroundColor: Colors.red));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tambah Produk Baru",
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Informasi Produk",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              _buildLabel("Nama Produk"),
              _buildTextField(_nameController, "Contoh: Kursi Kantor Ergonomis",
                  icon: Icons.title),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Harga (Rp)"),
                        _buildTextField(_priceController, "0",
                            isNumber: true,
                            icon: Icons.monetization_on_outlined),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Stok"),
                        _buildTextField(_stockController, "0",
                            isNumber: true, icon: Icons.inventory_2_outlined),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _buildLabel("Kategori"),
              _buildDropdownCategory(),

              const SizedBox(height: 16),

              _buildLabel("Deskripsi"),
              _buildTextField(_descController, "Jelaskan detail produk...",
                  maxLines: 4),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
    );
  }

  // ✅ WIDGET DROPDOWN BARU
  Widget _buildDropdownCategory() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      items: _categoryOptions.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category,
              style: const TextStyle(color: AppColors.textPrimary)),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedCategory = newValue;
        });
      },
      validator: (value) => value == null ? "Kategori wajib dipilih" : null,
      icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
      decoration: InputDecoration(
        hintText: "Pilih Kategori",
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon:
            Icon(Icons.category_outlined, color: Colors.grey[400], size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool isNumber = false, int maxLines = 1, IconData? icon}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon:
            icon != null ? Icon(icon, color: Colors.grey[400], size: 20) : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
      validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
    );
  }
}

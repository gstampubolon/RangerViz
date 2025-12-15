class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final int sales;
  final String? description;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.sales = 0,
    this.description,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'sales': sales,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  factory Product.fromSnapshot(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] ?? 'Tanpa Nama', // Default aman
      // Pastikan ini tidak ada "Elektronik" hardcoded
      category: (map['category'] != null && map['category'].toString().isNotEmpty) 
          ? map['category'] 
          : 'Lainnya', 
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      sales: (map['sales'] as num?)?.toInt() ?? 0,
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
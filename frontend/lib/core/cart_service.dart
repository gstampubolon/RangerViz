import '../models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

class CartService {
  static final CartService instance = CartService._init();
  CartService._init();
  final List<CartItem> _items = [];
  List<CartItem> get items => _items;

  void addToCart(Product product) {
    // ID String
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
  }

  void removeItem(String productId) { // Parameter String
    _items.removeWhere((item) => item.product.id == productId);
  }

  void clearCart() => _items.clear();

  double getTotalPrice() { // Return Double
    double total = 0;
    for (var item in _items) {
      total += (item.product.price * item.quantity);
    }
    return total;
  }
}
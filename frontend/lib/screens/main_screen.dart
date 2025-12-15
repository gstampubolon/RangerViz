import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'dashboard_screen.dart';
import 'product_list_screen.dart';
import 'order_screen.dart';
import 'cart_screen.dart';
import 'account_screen.dart'; // ✅ Import Screen Akun

class MainScreen extends StatefulWidget {
  final int initialIndex; 
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  bool _isArgumentLoaded = false; 

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isArgumentLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        setState(() {
          _currentIndex = args;
        });
      }
      _isArgumentLoaded = true; 
    }
  }

  // ✅ UPDATE: DAFTAR HALAMAN (Sekarang 5 Tab)
  final List<Widget> _pages = [
    const DashboardScreen(),
    const ProductListScreen(),
    const OrderScreen(),
    const CartScreen(),
    const AccountScreen(), // ✅ TAB AKUN (Index 4)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined), 
            activeIcon: Icon(Icons.dashboard), 
            label: "Dashboard"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined), 
            activeIcon: Icon(Icons.inventory_2), 
            label: "Produk"
          ),
          BottomNavigationBarItem( 
            icon: Icon(Icons.assignment_outlined), 
            activeIcon: Icon(Icons.assignment), 
            label: "Pesanan"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined), 
            activeIcon: Icon(Icons.shopping_cart), 
            label: "Cart"
          ),
          // ✅ ITEM BARU: AKUN
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), 
            activeIcon: Icon(Icons.person), 
            label: "Akun"
          ),
        ],
      ),
    );
  }
}
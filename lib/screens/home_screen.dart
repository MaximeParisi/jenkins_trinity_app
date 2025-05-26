import 'package:flutter/material.dart';
import 'product_list_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'scan_product_screen.dart'; 
import '../utils/session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  HomeScreen({required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  late Future<int> cartItemCount = Future.value(0);

  @override
  void initState() {
    super.initState();
    _screens = [
      ProductListScreen(token: widget.token),
      CartScreen(token: widget.token),
      ScanProductScreen(token: widget.token), 
      ProfileScreen(token: widget.token),
    ];
    cartItemCount = getCartItemCount();
  }

  Future<void> _logout() async {
    await SessionManager.clearUserToken();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<int> getCartItemCount() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/cart'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['products'] as List).length;
    }
    return 0;
  }

  void refreshCartCount() {
    setState(() {
      cartItemCount = getCartItemCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: FutureBuilder<int>(
        future: cartItemCount,
        builder: (context, snapshot) {
          int cartCount = snapshot.data ?? 0;

          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
            },
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.store),
                label: 'Produits',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.shopping_cart),
                    if (cartCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '$cartCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Panier',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.qr_code_scanner),
                label: 'Scanner',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          );
        },
      ),
    );
  }
}

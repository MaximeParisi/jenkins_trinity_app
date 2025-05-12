import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart';

class CartScreen extends StatefulWidget {
  final String token;
  CartScreen({required this.token});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List cartItems = [];

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  Future<void> fetchCart() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/cart'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      setState(() {
        cartItems = json.decode(response.body);
      });
    }
  }

  Future<void> removeFromCart(String productId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/cart/remove'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
      body: {'productId': productId},
    );

    if (response.statusCode == 200) {
      fetchCart();
    }
  }

  Future<void> pay() async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/payment'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      setState(() {
        cartItems = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Paiement effectué')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.token.isEmpty) {
      return Scaffold(
        body: Center(child: Text("Token invalide")),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Mon Panier')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  title: Text(item['product']['name']),
                  subtitle: Text('${item['product']['price']} €'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => removeFromCart(item['product']['_id']),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(onPressed: pay, child: Text('Payer'))
        ],
      ),
    );
  }
}

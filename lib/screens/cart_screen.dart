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

  String _extractErrorMessage(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map && decoded.containsKey('message')) {
        return decoded['message'];
      }
    } catch (_) {}
    return 'Réponse invalide du serveur';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> fetchCart() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/cart'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      setState(() {
        cartItems = json.decode(response.body) ?? [];
      });
      print('testo1 : $cartItems');
    } else {
      // Handle error if needed, for example, show a message or handle empty cart
      setState(() {
        cartItems = [];
      });
    }
  }

  Future<void> removeFromCart(String productId, String cartId) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/cart/remove/$cartId'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
      body: json.encode({'product_id': productId}),
    );

    if (response.statusCode == 200) {
      fetchCart();
    } else {
      final msg = _extractErrorMessage(response.body);
      _showError('Erreur suppression produit : $msg');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression du produit')),
      );
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Paiement effectué')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.token == 'test') {
      return Scaffold(
        body: Center(
          child: Text(
            "Token invalide",
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Panier', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF66509C), // Violet spécifique
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                if (item['products'] != null && item['products'].isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: item['products'].map<Widget>((product) {
                      return Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Color(0xFF66509C), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Image.network(
                                      product['picture'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                    title: Text(
                                      '${product['name']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                        '${product['price']} € | ${product['brand']}'),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete,
                                          color: Colors.redAccent),
                                      onPressed: () => removeFromCart(
                                          product['_id'], item['_id']),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Catégorie : ${product['category']}',
                                    style:
                                        TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Infos nutritionnelles :',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                      '• Calories : ${product['nutritionalInformation']['calories']} kcal'),
                                  Text(
                                      '• Protéines : ${product['nutritionalInformation']['proteins']}'),
                                  Text(
                                      '• Glucides : ${product['nutritionalInformation']['carbs']}'),
                                  Text(
                                      '• Lipides : ${product['nutritionalInformation']['fats']}'),
                                ],
                              ),
                            ),
                          ));
                    }).toList(),
                  );
                }

                return SizedBox.shrink();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: pay,
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF66509C), // Violet spécifique
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Payer',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

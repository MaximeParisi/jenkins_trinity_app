import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart';

class ProductListScreen extends StatefulWidget {
  final String token;
  ProductListScreen({required this.token});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List products = [];
  bool cartCreated = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    print('🔐 Token envoyé : ${widget.token}');
    final response = await http.get(
      Uri.parse(ApiConfig.baseUrl + ApiConfig.productListEndpoint),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        products = jsonDecode(response.body);
      });
    } else {
      final error = _extractErrorMessage(response.body);
      _showError('Erreur de connexion : $error');
    }
  }

  Future<void> addToCart(String productId) async {
    try {
      String cartId = '';

      // Étape 1 : récupérer le panier de l'utilisateur
      final cartResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/cart'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (cartResponse.statusCode == 200) {
        final cart = json.decode(cartResponse.body);
        if (cart == 'vide' || cart.isEmpty) {
          print('🛒 Aucun panier, création en cours...');
          final createCartResponse = await http.post(
            Uri.parse('${ApiConfig.baseUrl}/cart'),
            headers: {
              'Authorization': 'Bearer ${widget.token}',
              'Content-Type': 'application/json',
            },
          );

          if (createCartResponse.statusCode == 201) {
            final newCart = json.decode(createCartResponse.body);
            cartId = newCart[0]['_id'];
          } else {
            _showError("❌ Erreur création panier.");
            return;
          }
        } else {
          print('test : $cart');
          cartId = cart[0]['_id'];
        }
      } else {
        // Si pas de panier, le créer
        final createCartResponse = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/cart'),
          headers: {
            'Authorization': 'Bearer ${widget.token}',
            'Content-Type': 'application/json',
          },
        );

        if (createCartResponse.statusCode == 201) {
          final cart = json.decode(cartResponse.body);
          cartId = cart[0]['_id'];
        } else {
          _showError("Impossible de récupérer ou créer le panier.");
          return;
        }
      }

      // Étape 2 : ajouter le produit
      print('🧪 URL complète : ${ApiConfig.baseUrl}/cart/add/$cartId');
      final addResponse = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/cart/add/$cartId'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({'_id': productId}),
      );

      if (addResponse.statusCode == 200) {
        _showError('✅ Produit ajouté au panier');
      } else {
        final msg = _extractErrorMessage(addResponse.body);
        _showError('Erreur ajout produit : $msg');
      }
    } catch (e) {
      _showError('Erreur réseau : $e');
    }
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

  @override
  Widget build(BuildContext context) {
    if (widget.token.isEmpty) {
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
        title: Text('Produits', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF66509C), // Violet spécifique
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF66509C), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              title: Text(
                product['name'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${product['price']} €'),
              trailing: ElevatedButton(
                onPressed: () => addToCart(product['_id']),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF66509C), // Violet spécifique
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                child: Text('Ajouter',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
              ),
            ),
          );
        },
      ),
    );
  }
}

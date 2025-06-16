import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart';

class ScanProductScreen extends StatefulWidget {
  final String token;

  ScanProductScreen({required this.token});

  @override
  _ScanProductScreenState createState() => _ScanProductScreenState();
}

class _ScanProductScreenState extends State<ScanProductScreen> {
  String? barcode;
  Map<String, dynamic>? product;
  bool isLoading = false;

  Future<void> fetchProduct(String barcode) async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('${ApiConfig.baseUrl}/products/barcode/$barcode');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${widget.token}',
    });

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      setState(() {
        product = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produit non trouvé')),
      );
    }
  }

  Future<void> addToCart(String barcode) async {
    try {
      String cartId = '';

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
          final createCartResponse = await http.post(
            Uri.parse('${ApiConfig.baseUrl}/cart'),
            headers: {
              'Authorization': 'Bearer ${widget.token}',
              'Content-Type': 'application/json',
            },
          );

          if (createCartResponse.statusCode == 201) {
            final newCart = json.decode(createCartResponse.body);
            cartId = newCart['_id'];
          } else {
            _showMessage("❌ Erreur création panier.");
            return;
          }
        } else {
          cartId = cart[0]['_id'];
        }
      } else {
        final createCartResponse = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/cart'),
          headers: {
            'Authorization': 'Bearer ${widget.token}',
            'Content-Type': 'application/json',
          },
        );

        if (createCartResponse.statusCode == 201) {
          final newCart = json.decode(createCartResponse.body);
          cartId = newCart['_id'];
        } else {
          _showMessage("Impossible de récupérer ou créer le panier.");
          return;
        }
      }

      final addResponse = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/cart/add/barcode/$cartId'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({'barcode': barcode}),
      );

      if (addResponse.statusCode == 200) {
        _showMessage('✅ Produit ajouté au panier');
      } else {
        _showMessage('Erreur ajout produit');
      }
    } catch (e) {
      _showMessage('Erreur réseau : $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void onDetect(BarcodeCapture barcodeCapture) {
    if (barcode != null) return;
    if (barcodeCapture.barcodes.isEmpty) return;
    final value = barcodeCapture.barcodes.first.rawValue;
    if (value != null) {
      barcode = value;
      fetchProduct(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner un produit'),
        backgroundColor: Color(0xFF66509C),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Fermer',
          )
        ],
      ),
      body: product == null
          ? Stack(
              children: [
                MobileScanner(
                  onDetect: onDetect,
                ),
                if (isLoading)
                  Center(child: CircularProgressIndicator()),
              ],
            )
          : Padding(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nom : ${product!['name']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('Marque : ${product!['brand']}'),
                    Text('Catégorie : ${product!['category']}'),
                    Text('Prix : ${product!['price'] ?? '-'} €'),
                    SizedBox(height: 10),
                    Text('Infos nutritionnelles :', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('• Calories : ${product!['nutritionalInformation']['calories']} kcal'),
                    Text('• Protéines : ${product!['nutritionalInformation']['proteins']}'),
                    Text('• Glucides : ${product!['nutritionalInformation']['carbs']}'),
                    Text('• Lipides : ${product!['nutritionalInformation']['fats']}'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => addToCart(product!['barcode']),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF66509C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      child: Text('Ajouter au panier', style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          product = null;
                          barcode = null;
                        });
                      },
                      child: Text('Scanner un autre produit'),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}

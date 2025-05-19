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

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await http.get(
      Uri.parse(ApiConfig.baseUrl + ApiConfig.productListEndpoint),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );
    if (response.statusCode == 200) {
      setState(() {
        products = jsonDecode(response.body);
      });
    } else {
      // Gérer l'erreur
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.token == 'test') {
      return Scaffold(
        body: Center(child: Text("Token invalide")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Produits'),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product['name']),
            subtitle: Text('${product['price']} €'),
          );
        },
      ),
    );
  }
}

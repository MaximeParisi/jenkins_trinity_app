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

  void onDetect(BarcodeCapture barcodeCapture) {
    if (barcode != null) return;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nom : ${product!['name']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('Marque : ${product!['brand']}'),
                  Text('Catégorie : ${product!['category']}'),
                  Text('Prix : ${product!['price']} €'),
                  SizedBox(height: 10),
                  Text('Infos nutritionnelles :', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('• Calories : ${product!['nutritionalInformation']['calories']} kcal'),
                  Text('• Protéines : ${product!['nutritionalInformation']['proteins']}'),
                  Text('• Glucides : ${product!['nutritionalInformation']['carbs']}'),
                  Text('• Lipides : ${product!['nutritionalInformation']['fats']}'),
                  SizedBox(height: 20),
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
    );
  }
}

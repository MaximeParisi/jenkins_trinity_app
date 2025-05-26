import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CartScreen extends StatefulWidget {
  final String token;
  CartScreen({required this.token});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List cartItems = [];

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    fetchCart();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(initSettings);
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

  Future<void> showPaymentNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'payment_channel',
      'Paiement',
      channelDescription: 'Notifications de paiement',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Paiement réussi',
      'Votre facture a été générée avec succès.',
      platformDetails,
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
    } else {
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
    }
  }

  Future<void> createInvoice(String orderId, double total) async {
    final invoiceResponse = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/invoices'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'orderID': orderId,
        'products': cartItems.expand((item) => item['products']).toList(),
        'total': total,
        'paymentStatus': 'completed'
      }),
    );

    if (invoiceResponse.statusCode != 201) {
      _showError("Erreur lors de la création de la facture");
    }
  }

  Future<void> pay() async {
    final total = getTotalPrice().toStringAsFixed(2);

    final List<Map<String, dynamic>> items = [];

    for (var item in cartItems) {
      if (item['products'] != null) {
        for (var product in item['products']) {
          items.add({
            'name': product['name'],
            'price': product['price'].toString(),
            'quantity': 1,
          });
        }
      }
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/paypal/create-order'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'total': total,
        'cartItems': items,
        'id': 'temporary_id',
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final orderId = data['orderID'];
      final approvalUrl =
          'https://www.sandbox.paypal.com/checkoutnow?token=$orderId';

      if (await canLaunch(approvalUrl)) {
        await launch(approvalUrl);

        // Simuler confirmation après redirection
        await Future.delayed(Duration(seconds: 2));

        await showPaymentNotification();

        await createInvoice(orderId, double.parse(total));
        _showError('Paiement et facture complétés');
      } else {
        _showError('Impossible d’ouvrir PayPal');
      }
    } else {
      final msg = _extractErrorMessage(response.body);
      _showError('Erreur paypal : $msg');
    }
  }

  double getTotalPrice() {
    double total = 0.0;
    for (var item in cartItems) {
      if (item['products'] != null) {
        for (var product in item['products']) {
          if (product['price'] != null) {
            total += double.tryParse(product['price'].toString()) ?? 0.0;
          }
        }
      }
    }
    return total;
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
        backgroundColor: Color(0xFF66509C),
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
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
                                Text('Catégorie : ${product['category']}',
                                    style:
                                        TextStyle(fontStyle: FontStyle.italic)),
                                SizedBox(height: 6),
                                Text('Infos nutritionnelles :',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
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
                        ),
                      );
                    }).toList(),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Total : ${getTotalPrice().toStringAsFixed(2)} €',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: pay,
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF66509C),
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

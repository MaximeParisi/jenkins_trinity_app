import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../config/api.dart';

class InvoiceScreen extends StatefulWidget {
  final String token;
  InvoiceScreen({required this.token});

  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  List invoices = [];

  @override
  void initState() {
    super.initState();
    fetchInvoices();
  }

  Future<void> fetchInvoices() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/invoices/'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      setState(() {
        invoices = json.decode(response.body);
      });
    } else {
      setState(() {
        invoices = [];
      });
    }
  }

  Future<void> _payInvoice(String orderId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/paypal/create-order'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({'orderId': orderId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final String paypalOrderId = data['orderID'];
      final Uri approvalUrl = Uri.parse(
          'https://www.sandbox.paypal.com/checkoutnow?token=$paypalOrderId');

      final bool launched = await launchUrl(approvalUrl,
          mode: LaunchMode.externalApplication);

      if (launched) {
        await Future.delayed(Duration(seconds: 2));
        await _confirmPayment(paypalOrderId);
      }
    }
  }

  Future<void> _confirmPayment(String orderId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/paypal/capture-payment'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({'orderId': orderId}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Paiement effectué avec succès')),
      );
      fetchInvoices();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du paiement')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Factures', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF66509C),
      ),
      body: invoices.isEmpty
          ? const Center(child: Text('Aucune facture trouvée'))
          : ListView.builder(
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.receipt),
                          title: Text('Facture #${invoice['_id']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Commande : ${invoice['orderID']}'),
                              Text('Montant : ${invoice['totalAmount']} €'),
                              Text('Statut : ${invoice['paymentStatus']}'),
                            ],
                          ),
                        ),
                        if (invoice['paymentStatus'] != 'completed')
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ElevatedButton(
                              onPressed: () =>
                                  _payInvoice(invoice['orderID'].toString()),
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFF66509C),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                'Payer',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

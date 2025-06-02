import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: invoices.isEmpty
          ? const Center(child: Text('Aucune facture trouvée'))
          : ListView.builder(
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
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
                );
              },
            ),
    );
  }
}

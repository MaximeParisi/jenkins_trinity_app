import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> register() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users');
    try {
      final response = await http.post(url, body: {
        'firstName': firstnameController.text,
        'lastName': lastnameController.text,
        'phoneNumber': phoneController.text,
        'password': passwordController.text,
      });

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final error = _extractErrorMessage(response.body);
        _showError('Erreur d\'inscription : $error ');
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
    return Scaffold(
      appBar: AppBar(title: Text('Créer un compte')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: firstnameController, decoration: InputDecoration(labelText: 'Prénom')),
            TextField(controller: lastnameController, decoration: InputDecoration(labelText: 'Nom')),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Phone')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Mot de passe'), obscureText: true),
            ElevatedButton(onPressed: register, child: Text('S\'inscrire')),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api.dart';
import '../../utils/session_manager.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');
    try {
      final response = await http.post(url, body: {
        'email': emailController.text,
        'password': passwordController.text,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['token'] == null) {
          _showError('Erreur : token manquant dans la réponse');
          return;
        }
        await SessionManager.saveUserToken(data['token']);
        Navigator.pushReplacementNamed(context, '/products');
      } else {
        final error = _extractErrorMessage(response.body);
        _showError('Erreur de connexion : $error');
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
      appBar: AppBar(title: Text('Connexion')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            ElevatedButton(onPressed: login, child: Text('Se connecter')),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text('Créer un compte'),
            ),
          ],
        ),
      ),
    );
  }
}

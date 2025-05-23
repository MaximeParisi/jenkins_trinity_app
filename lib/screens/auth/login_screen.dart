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
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/signin');
    try {
      final response = await http.post(url, body: {
        'phoneNumber': phoneController.text,
        'password': passwordController.text,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        if (data['token'] == null) {
          _showError('Erreur : token manquant dans la réponse : $data');
          return;
        }
        await SessionManager.saveUserToken(data['token']);
        final stored = await SessionManager.getUserToken();
        print('✅ Token sauvegardé et relu : $stored');

        Navigator.pushReplacementNamed(context, '/home');
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
          Container(
            margin: EdgeInsets.only(bottom: 16),
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
            child: TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                labelStyle: TextStyle(color: Color(0xFF66509C)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 32),
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
            child: TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                labelStyle: TextStyle(color: Color(0xFF66509C)), // Violet correct
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              ),
              obscureText: true,
            ),
          ),
          ElevatedButton(
            onPressed: login,
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF66509C), // Violet correct
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Se connecter',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: Text(
              'Créer un compte',
              style: TextStyle(color: Color(0xFF66509C)), // Violet correct
            ),
          ),
        ],
      ),
    ),
  );
} 
}

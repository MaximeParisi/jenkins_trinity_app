import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api.dart';

class ProfileScreen extends StatefulWidget {
  final String token;

  ProfileScreen({required this.token});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    fetchProfile();
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

  Future<void> fetchProfile() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/me');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${widget.token}',
      }).timeout(Duration(seconds: 10), onTimeout: () {
        // Gérer l'erreur de timeout
        print("Timeout error");
        return http.Response('{"error":"timeout"}', 408);
      });

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            user = json.decode(response.body);
          });
        }
      } else {
        print('Erreur API : ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur de connexion : $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/users/');
      final response = await http.delete(url, headers: {
        'Authorization': 'Bearer ${widget.token}',
      });

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        print(response.body);
        final error = _extractErrorMessage(response.body);
        _showError('Erreur suppression User : $error');
      }
    } catch (e) {
      _showError('Erreur réseau : $e');
    }
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

    if (user == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    print(user);

    return Scaffold(
      appBar: AppBar(
        title: Text('Mon profil', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF66509C), // Violet spécifique
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 16),
              child: Text(
                'Nom : ${user!['user']['lastName']}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 16),
              child: Text(
                'Prénom : ${user!['user']['firstName']}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 16),
              child: Text(
                'Phone : ${user!['user']['phoneNumber']}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/profile/update'),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF66509C), // Violet spécifique
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
              child: Text(
                'Modifier',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: deleteAccount,
              child: Text(
                'Supprimer mon compte',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

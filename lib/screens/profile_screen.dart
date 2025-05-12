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

  Future<void> fetchProfile() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/me');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${widget.token}',
    });

    if (response.statusCode == 200) {
      setState(() {
        user = json.decode(response.body);
      });
    }
  }

  Future<void> deleteAccount() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/delete');
    final response = await http.delete(url, headers: {
      'Authorization': 'Bearer ${widget.token}',
    });

    if (response.statusCode == 200) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
         if (widget.token.isEmpty) {
      return Scaffold(
        body: Center(child: Text("Token invalide")),
      );
    }
    if (user == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Mon profil')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nom : ${user!['lastname']}'),
            Text('Prénom : ${user!['firstname']}'),
            Text('Email : ${user!['email']}'),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/profile/update'), child: Text('Modifier')),
            TextButton(onPressed: deleteAccount, child: Text('Supprimer mon compte', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }
}

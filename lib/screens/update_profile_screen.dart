import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api.dart';

class UpdateProfileScreen extends StatefulWidget {
  final String token;

  UpdateProfileScreen({required this.token});

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();

  Future<void> updateProfile() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/update');
    final response = await http.put(url,
        headers: {'Authorization': 'Bearer ${widget.token}'},
        body: {
          'firstname': firstnameController.text,
          'lastname': lastnameController.text,
          'email': emailController.text,
        });

    if (response.statusCode == 200) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la mise à jour')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
         if (widget.token.isEmpty) {
      return Scaffold(
        body: Center(child: Text("Token invalide")),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Modifier le profil')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: firstnameController, decoration: InputDecoration(labelText: 'Prénom')),
            TextField(controller: lastnameController, decoration: InputDecoration(labelText: 'Nom')),
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            ElevatedButton(onPressed: updateProfile, child: Text('Mettre à jour')),
          ],
        ),
      ),
    );
  }
}

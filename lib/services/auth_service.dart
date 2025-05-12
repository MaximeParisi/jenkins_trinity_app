import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api.dart';


class AuthService {
  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['token'];
    }
    return null;
  }

  Future<bool> register(Map<String, String> user) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user),
    );
    return response.statusCode == 200;
  }

  Future<bool> updateUser(String token, Map<String, String> updatedData) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(updatedData),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteUser(String token) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/delete'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }
}

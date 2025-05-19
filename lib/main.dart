import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/update_profile_screen.dart';
import 'utils/session_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<String> _getToken() async {
    final token = await SessionManager.getUserToken();
    return token;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final token = snapshot.data!;
        final isLoggedIn = token != 'test';

        return MaterialApp(
          home: isLoggedIn
              ? ProductListScreen(token: token)
              : LoginScreen(), // ← pas de route initiale, juste `home:`
          routes: {
            '/register': (context) => RegisterScreen(),
            '/products': (context) => ProductListScreen(token: token),
            '/home': (context) => HomeScreen(token: token),
            '/cart': (context) => CartScreen(token: token),
            '/profile': (context) => ProfileScreen(token: token),
            '/profile/update': (context) => UpdateProfileScreen(token: token),
          },
          theme: ThemeData(primarySwatch: Colors.blue),
        );
      },
    );
  }
}

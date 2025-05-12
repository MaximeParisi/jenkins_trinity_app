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
  Future<String?> _getToken() async {
    return await SessionManager.getUserToken();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final token = snapshot.data;

        if (token == null) {
          // Si le token est null, on redirige vers la page de login
          return MaterialApp(
            initialRoute: '/login',
            routes: {
              '/login': (context) => LoginScreen(),
              '/register': (context) => RegisterScreen(),
            },
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
          );
        }

        // Si le token est non-nul, on affiche les autres écrans
        return MaterialApp(
          initialRoute: '/products',
          routes: {
            '/login': (context) => LoginScreen(),
            '/register': (context) => RegisterScreen(),
            '/home': (context) => ProductListScreen(token: token),
            '/products': (context) => ProductListScreen(token: token),
            '/cart': (context) => CartScreen(token: token),
            '/profile': (context) => ProfileScreen(token: token),
            '/profile/update': (context) => UpdateProfileScreen(token: token),
          },
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
        );
      },
    );
  }
}

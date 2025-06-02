import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'mocks_generator.mocks.dart'; 

import 'package:jenkins_trinity_app/screens/auth/login_screen.dart';
import 'package:jenkins_trinity_app/screens/auth/register_screen.dart';

void main() {
  group('LoginScreen tests', () {
    testWidgets('Affiche erreur si identifiants invalides', (WidgetTester tester) async {
      final client = MockClient();
      when(client.post(any, body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{"message": "Identifiants invalides"}', 400));

      await tester.pumpWidget(MaterialApp(home: LoginScreen()));

      await tester.enterText(find.byType(TextField).at(0), '0600000000');
      await tester.enterText(find.byType(TextField).at(1), 'wrongpassword');
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Erreur de connexion'), findsOneWidget);
    });
  });

  group('RegisterScreen tests', () {
    testWidgets('Affiche erreur si téléphone déjà utilisé', (WidgetTester tester) async {
      final client = MockClient();
      when(client.post(any, body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{"message": "Téléphone déjà utilisé"}', 400));

      await tester.pumpWidget(MaterialApp(home: RegisterScreen()));

      await tester.enterText(find.byType(TextField).at(0), 'Jean');
      await tester.enterText(find.byType(TextField).at(1), 'Dupont');
      await tester.enterText(find.byType(TextField).at(2), '0600000000');
      await tester.enterText(find.byType(TextField).at(3), 'test1234');
      await tester.tap(find.text("S'inscrire"));
      await tester.pumpAndSettle();

      expect(find.textContaining('Erreur d\'inscription'), findsOneWidget);
    });
  });
}

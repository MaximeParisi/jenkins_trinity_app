# jenkins_trinity_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# jenkins_trinity_app



https://developer.paypal.com/tools/sandbox/card-testing/





1. Documentation technique

# Architecture de l'application mobile

L'application suit une architecture modulaire organisée par responsabilités, avec les dossiers principaux suivants :

lib/

screens/ : contient tous les écrans (UI)

services/ : logique métier (authentification, panier, produits)

models/ : définitions des modèles de données (Product, User, etc.)

config/ : configuration de l'API (URL de base, headers, etc.)

utils/ : utilitaires comme la gestion de session

widgets/ : composants UI réutilisables

# Composants utilisés

Écrans (UI) : login_screen, register_screen, home_screen, cart_screen, invoice_screen, etc.

Services :

auth_service.dart : authentification

cart_service.dart : gestion du panier

product_service.dart : récupération des produits

Notifications : flutter_local_notifications

Scanneur de produits : mobile_scanner

Navigation : Navigator intégré à Flutter

Appels HTTP : http package avec token dans les headers

# Choix technologiques

Flutter : framework de développement cross-platform

Backend : API REST auto-hébergée (non Firebase) node express

Authentification : basée sur token JWT

Base de données (backend) : MongoDB (via le backend)


# Flux de données

Connexion / Inscription :

Utilisateur saisit ses infos -> requête POST vers /login ou /register

Réponse avec token -> stocké localement

Navigation / Affichage des produits :

Requête GET avec token vers /products

Affichage dans ProductListScreen

Ajout au panier :

Appel à /cart/add avec les infos du produit

Rechargement du panier à l’aide d’un GET /cart

Paiement PayPal :

Requête POST /paypal/create-order

Redirection vers l’URL PayPal dans navigateur externe

Simulation de confirmation -> création de la facture

Facture :

Facture générée sur le backend via /invoices

Visualisation via GET /invoices


2. Diagrammes UML

# Diagramme de classes (extrait simplifié)

+-------------+         +-------------+          +---------------+
|    User     |<>------>|   Invoice   |<>--------|   Product     |
+-------------+         +-------------+          +---------------+
| id          |         | id          |          | id            |
| name        |         | userId      |          | name          |
| phone       |         | total       |          | price         |
| password    |         | createdAt   |          | brand         |
+-------------+         +-------------+          +---------------+

Un User peut avoir plusieurs Invoice

Une Invoice contient plusieurs Product

# Diagramme d'activités : "Scan -> Panier -> Paiement -> Facture"

[Start]
   |
   v
[Scan produit (QR/barcode)]
   |
   v
[Appel API Open Food Facts / backend]
   |
   v
[Ajouter au panier]
   |
   v
[Cliquer "Payer"]
   |
   v
[Création commande PayPal + redirection]
   |
   v
[Confirmation paiement (retour app)]
   |
   v
[Création facture backend]
   |
   v
[Notification affichée]
   |
   v
[Facture consultable]
   |
   v
[End]



# Lancer les tests et obtenir la couverture - Jenkins Trinity App

# 1. Prérequis dans pubspec.yaml

Ajoutez les dépendances suivantes si ce n’est pas encore fait :

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.2
  build_runner: ^2.4.6

# 2. Générer les fichiers de mocks

Exécutez cette commande si vous utilisez @GenerateMocks :

dart run build_runner build --delete-conflicting-outputs

# 3. Organisation des fichiers de test

Les fichiers de test doivent être placés dans le dossier test/ à la racine du projet.
Ils doivent se terminer par _test.dart.

Exemple : test/auth_service_test.dart

# 4. Lancer les tests

flutter test

# 5. Générer la couverture des tests

flutter test --coverage

Cela génère le fichier : coverage/lcov.info

# 6. Voir le % de couverture

Méthode A : avec lcov-summary (Node.js requis)

Installer l'outil :

sudo npm install -g lcov-summary

Afficher le résumé :

lcov-summary coverage/lcov.info

Méthode B : Générer un rapport HTML (recommandé)

Installer lcov si besoin :

sudo apt install lcov

Générer le rapport :

genhtml coverage/lcov.info -o coverage/html
xdg-open coverage/html/index.html

# Exemple de sortie attendue :

Name                             Stmts   Miss  Cover
----------------------------------------------------
lib/services/auth_service.dart       3      0   100%
----------------------------------------------------
TOTAL                                3      0   100%

# Astuce

Utilisez l’extension VSCode Coverage Gutters pour afficher la couverture directement dans l’éditeur si vous utilisez VSCode.



class ApiConfig {
  static const String baseUrl = 'http://217.182.61.107:3000/api'; // URL de base du backend

  // Endpoints API
  static const String loginEndpoint = '/auth/signin';
  static const String registerEndpoint = '/auth/users';
  static const String userProfileEndpoint = '/user/users';
  static const String productListEndpoint = '/products';
  static const String cartEndpoint = '/cart';
  static const String checkoutEndpoint = '/checkout';
}

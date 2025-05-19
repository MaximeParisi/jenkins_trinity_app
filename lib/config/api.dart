class ApiConfig {
  static const String baseUrl = 'http://217.182.61.107:3001'; // URL de base du backend

  // Endpoints API
  static const String loginEndpoint = '/api/auth/signin';
  static const String registerEndpoint = '/api/auth/users';
  static const String userProfileEndpoint = '/api/user/users';
  static const String productListEndpoint = '/api/products';
  static const String cartEndpoint = '/api/cart';
  static const String checkoutEndpoint = '/api/checkout';
}

class ApiConfig {
  static const String baseUrl = 'http://217.182.61.107:3000'; // URL de base du backend

  // Endpoints API
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String userProfileEndpoint = '/api/user/profile';
  static const String productListEndpoint = '/api/products';
  static const String cartEndpoint = '/api/cart';
  static const String checkoutEndpoint = '/api/checkout';
}

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000/api';

  // Routes d'authentification
  static String get login => '/auth/login';
  static String get register => '/auth/register';
  static String get logout => '/auth/logout';
  static String get refresh => '/auth/refresh';
  static String get me => '/auth/me';

  // Routes des produits
  static String get products => '/products';
  static String product(int id) => '/products/$id';

  // Routes des catégories
  static String get categories => '/categories';
  static String category(int id) => '/categories/$id';
  static String categoryProducts(int id) => '/categories/$id/products';

  // Route de recherche
  static String get search => '/search';

  // Routes publiques
  static String get publicProducts => '/public/products';
  static String publicProduct(int id) => '/public/products/$id';
  static String get publicCategories => '/public/categories';
  static String publicCategory(int id) => '/public/categories/$id';
  static String publicCategoryProducts(int id) =>
      '/public/categories/$id/products';
  static String get publicSearch => '/public/search';
}

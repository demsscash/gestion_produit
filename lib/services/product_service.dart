import '../config/api_config.dart';
import '../models/product.dart';
import 'auth_service.dart';
import 'api_service.dart';

class ProductService {
  final ApiService _apiService;
  final AuthService _authService;

  ProductService({ApiService? apiService, AuthService? authService})
    : _apiService = apiService ?? ApiService(),
      _authService = authService ?? AuthService();

  // Récupération de tous les produits
  Future<List<Product>> getProducts({int? page, int? perPage}) async {
    bool isAuthenticated = await _authService.isAuthenticated();
    String endpoint =
        isAuthenticated ? ApiConfig.products : ApiConfig.publicProducts;

    if (page != null && perPage != null) {
      endpoint += '?page=$page&per_page=$perPage';
    }

    final response = await _apiService.get(
      endpoint,
      requiresAuth: isAuthenticated,
    );

    List<dynamic> productsJson =
        response is List ? response : response['data'] ?? [];

    return productsJson
        .map((productJson) => Product.fromJson(productJson))
        .toList();
  }

  // Récupération d'un produit spécifique
  Future<Product> getProduct(int id) async {
    bool isAuthenticated = await _authService.isAuthenticated();
    String endpoint =
        isAuthenticated ? ApiConfig.product(id) : ApiConfig.publicProduct(id);

    final response = await _apiService.get(
      endpoint,
      requiresAuth: isAuthenticated,
    );

    return Product.fromJson(response);
  }

  // Création d'un produit (nécessite authentification admin)
  Future<Product> createProduct(Product product) async {
    final response = await _apiService.post(
      ApiConfig.products,
      product.toJson(),
    );

    return Product.fromJson(response);
  }

  // Mise à jour d'un produit (nécessite authentification admin)
  Future<Product> updateProduct(int id, Product product) async {
    final response = await _apiService.put(
      ApiConfig.product(id),
      product.toJson(),
    );

    return Product.fromJson(response);
  }

  // Suppression d'un produit (nécessite authentification admin)
  Future<bool> deleteProduct(int id) async {
    await _apiService.delete(ApiConfig.product(id));
    return true;
  }

  // Recherche de produits
  Future<List<Product>> searchProducts({
    String? query,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
  }) async {
    bool isAuthenticated = await _authService.isAuthenticated();
    String endpoint =
        isAuthenticated ? ApiConfig.search : ApiConfig.publicSearch;

    // Construction des paramètres de recherche
    List<String> queryParams = [];
    if (query != null && query.isNotEmpty) {
      queryParams.add('query=${Uri.encodeComponent(query)}');
    }
    if (categoryId != null) {
      queryParams.add('category_id=$categoryId');
    }
    if (minPrice != null) {
      queryParams.add('min_price=$minPrice');
    }
    if (maxPrice != null) {
      queryParams.add('max_price=$maxPrice');
    }

    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }

    final response = await _apiService.get(
      endpoint,
      requiresAuth: isAuthenticated,
    );

    List<dynamic> productsJson =
        response is List ? response : response['data'] ?? [];

    return productsJson
        .map((productJson) => Product.fromJson(productJson))
        .toList();
  }
}

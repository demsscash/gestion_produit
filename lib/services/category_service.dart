import '../config/api_config.dart';
import '../models/category.dart';
import '../models/product.dart';
import 'auth_service.dart';
import 'api_service.dart';

class CategoryService {
  final ApiService _apiService;
  final AuthService _authService;

  CategoryService({ApiService? apiService, AuthService? authService})
      : _apiService = apiService ?? ApiService(),
        _authService = authService ?? AuthService();

  // Récupération de toutes les catégories
  Future<List<Category>> getCategories({int? page, int? perPage}) async {
    bool isAuthenticated = await _authService.isAuthenticated();
    String endpoint = ApiConfig.categories;

    if (page != null && perPage != null) {
      endpoint += '?page=$page&per_page=$perPage';
    }

    try {
      final response = await _apiService.get(
        endpoint,
        requiresAuth: isAuthenticated,
      );

      List<dynamic> categoriesJson =
          response is List ? response : response['data'] ?? [];

      return categoriesJson
          .map((categoryJson) => Category.fromJson(categoryJson))
          .toList();
    } catch (e) {
      // Si la requête authentifiée échoue, essayer avec l'endpoint public
      if (isAuthenticated) {
        try {
          String publicEndpoint = ApiConfig.publicCategories;
          if (page != null && perPage != null) {
            publicEndpoint += '?page=$page&per_page=$perPage';
          }

          final response = await _apiService.get(
            publicEndpoint,
            requiresAuth: false,
          );

          List<dynamic> categoriesJson =
              response is List ? response : response['data'] ?? [];

          return categoriesJson
              .map((categoryJson) => Category.fromJson(categoryJson))
              .toList();
        } catch (_) {
          rethrow;
        }
      }
      rethrow;
    }
  }

  // Récupération d'une catégorie spécifique
  Future<Category> getCategory(int id) async {
    bool isAuthenticated = await _authService.isAuthenticated();
    String endpoint = ApiConfig.category(id);

    try {
      final response = await _apiService.get(
        endpoint,
        requiresAuth: isAuthenticated,
      );

      return Category.fromJson(response);
    } catch (e) {
      // Si la requête authentifiée échoue, essayer avec l'endpoint public
      if (isAuthenticated) {
        try {
          final response = await _apiService.get(
            ApiConfig.publicCategory(id),
            requiresAuth: false,
          );

          return Category.fromJson(response);
        } catch (_) {
          rethrow;
        }
      }
      rethrow;
    }
  }

  // Récupération des produits d'une catégorie spécifique
  Future<List<Product>> getCategoryProducts(
    int id, {
    int? page,
    int? perPage,
  }) async {
    bool isAuthenticated = await _authService.isAuthenticated();
    String endpoint = ApiConfig.categoryProducts(id);

    if (page != null && perPage != null) {
      endpoint += '?page=$page&per_page=$perPage';
    }

    try {
      final response = await _apiService.get(
        endpoint,
        requiresAuth: isAuthenticated,
      );

      List<dynamic> productsJson =
          response is List ? response : response['data'] ?? [];

      return productsJson
          .map((productJson) => Product.fromJson(productJson))
          .toList();
    } catch (e) {
      // Si la requête authentifiée échoue, essayer avec l'endpoint public
      if (isAuthenticated) {
        try {
          String publicEndpoint = ApiConfig.publicCategoryProducts(id);
          if (page != null && perPage != null) {
            publicEndpoint += '?page=$page&per_page=$perPage';
          }

          final response = await _apiService.get(
            publicEndpoint,
            requiresAuth: false,
          );

          List<dynamic> productsJson =
              response is List ? response : response['data'] ?? [];

          return productsJson
              .map((productJson) => Product.fromJson(productJson))
              .toList();
        } catch (_) {
          rethrow;
        }
      }
      rethrow;
    }
  }

  // Création d'une catégorie (nécessite authentification admin)
  Future<Category> createCategory(Category category) async {
    final response = await _apiService.post(ApiConfig.categories, {
      'name': category.name,
      'description': category.description,
    });

    return Category.fromJson(response);
  }

  // Mise à jour d'une catégorie (nécessite authentification admin)
  Future<Category> updateCategory(int id, Category category) async {
    final response = await _apiService.put(ApiConfig.category(id), {
      'name': category.name,
      'description': category.description,
    });

    return Category.fromJson(response);
  }

  // Suppression d'une catégorie (nécessite authentification admin)
  Future<bool> deleteCategory(int id) async {
    await _apiService.delete(ApiConfig.category(id));
    return true;
  }
}

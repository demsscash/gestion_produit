import '../config/api_config.dart';
import '../models/category.dart';
import '../models/product.dart';
import 'auth_service.dart';
import 'api_service.dart';

class CategoryService {
  final ApiService _apiService;
  final AuthService _authService;
  
  CategoryService({
    ApiService? apiService, 
    AuthService? authService
  }) : 
    _apiService = apiService ?? ApiService(),
    _authService = authService ?? AuthService();

  // Récupération de toutes les catégories
  Future<List<Category>> getCategories() async {
    bool isAuthenticated = await _authService.isAuthenticated();
    String endpoint = isAuthenticated 
        ? ApiConfig.categories 
        : ApiConfig.publicCategories;
    
    final response = await _apiService.get(
      endpoint,
      requiresAuth: isAuthenticated,
    );
    
    List<dynamic> categoriesJson = response is List 
        ? response 
        : response['data'] ?? [];
    
    return categoriesJson
        .map((categoryJson) => Category.fromJson(categoryJson))
        .toList();
  }

  // Récupération d'une catégorie spécifique
  Future<Category> getCategory(int id) async {
    bool isAuthenticated = await _authService.isAuthenticated();
    String endpoint = isAuthenticated 
        ? ApiConfig.category(id) 
        : ApiConfig.publicCategory(id);
    
    final response = await _apiService.get(
      endpoint,
      requiresAuth: isAuthenticated,
    );
    
    return Category.fromJson(response);
  }

  // Récupération des produits d'une catégorie spécifique
  Future<List<Product>> getCategoryProducts(int id) async {
    bool isAuthenticated = await _authService.isAuthenticated();
    String endpoint = isAuthenticated 
        ? ApiConfig.categoryProducts(id) 
        : ApiConfig.publicCategoryProducts(id);
    
    final response = await _apiService.get(
      endpoint,
      requiresAuth: isAuthenticated,
    );
    
    List<dynamic> productsJson = response is List 
        ? response 
        : response['data'] ?? [];
    
    return productsJson
        .map((productJson) => Product.fromJson(productJson))
        .toList();
  }

  // Création d'une catégorie (nécessite authentification admin)
  Future<Category> createCategory(String name, String? description) async {
    final response = await _apiService.post(
      ApiConfig.categories,
      {
        'name': name,
        'description': description,
      },
    );
    
    return Category.fromJson(response);
  }

  // Mise à jour d'une catégorie (nécessite authentification admin)
  Future<Category> updateCategory(int id, String name, String? description) async {
    final response = await _apiService.put(
      ApiConfig.category(id),
      {
        'name': name,
        'description': description,
      },
    );
    
    return Category.fromJson(response);
  }

  // Suppression d'une catégorie (nécessite authentification admin)
  Future<bool> deleteCategory(int id) async {
    await _apiService.delete(ApiConfig.category(id));
    return true;
  }
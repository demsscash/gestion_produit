import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/product.dart';
import '../services/category_service.dart';
import '../utils/error_handler.dart';

/// Provider pour gérer l'état des catégories
class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService;

  /// Liste des catégories
  List<Category> _categories = [];

  /// Catégorie sélectionnée
  Category? _selectedCategory;

  /// Produits de la catégorie sélectionnée
  List<Product> _categoryProducts = [];

  /// État de chargement
  bool _isLoading = false;

  /// État d'erreur
  bool _hasError = false;

  /// Message d'erreur
  String _errorMessage = '';

  /// Nombre d'éléments par page
  final int _pageSize = 10;

  /// Constructeur avec injection du service de catégories
  CategoryProvider({CategoryService? categoryService})
      : _categoryService = categoryService ?? CategoryService();

  /// Getters pour les propriétés
  List<Category> get categories => _categories;
  Category? get selectedCategory => _selectedCategory;
  List<Product> get categoryProducts => _categoryProducts;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  /// Méthode pour charger toutes les catégories
  Future<void> loadCategories() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      _categories = await _categoryService.getCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _hasError = true;

      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage =
            'Erreur lors du chargement des catégories: ${e.toString()}';
      }

      notifyListeners();
    }
  }

  /// Méthode pour charger une catégorie spécifique
  Future<void> loadCategory(int id) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      _selectedCategory = await _categoryService.getCategory(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _hasError = true;

      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage =
            'Erreur lors du chargement de la catégorie: ${e.toString()}';
      }

      notifyListeners();
    }
  }

  /// Méthode pour charger les produits d'une catégorie
  Future<void> loadCategoryProducts(int categoryId) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      _categoryProducts = await _categoryService.getCategoryProducts(
        categoryId,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _hasError = true;

      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage =
            'Erreur lors du chargement des produits de la catégorie: ${e.toString()}';
      }

      notifyListeners();
    }
  }

  /// Méthode pour ajouter une catégorie
  Future<bool> addCategory(Category category) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final newCategory = await _categoryService.createCategory(category);
      _categories.add(newCategory);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _hasError = true;

      if (e is ValidationException) {
        _errorMessage = e.getFirstError();
      } else if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage =
            'Erreur lors de l\'ajout de la catégorie: ${e.toString()}';
      }

      notifyListeners();
      return false;
    }
  }

  /// Méthode pour mettre à jour une catégorie
  Future<bool> updateCategory(int id, Category category) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final updatedCategory = await _categoryService.updateCategory(
        id,
        category,
      );

      // Mettre à jour la liste des catégories
      final index = _categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        _categories[index] = updatedCategory;
      }

      // Mettre à jour la catégorie sélectionnée
      if (_selectedCategory?.id == id) {
        _selectedCategory = updatedCategory;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _hasError = true;

      if (e is ValidationException) {
        _errorMessage = e.getFirstError();
      } else if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage =
            'Erreur lors de la mise à jour de la catégorie: ${e.toString()}';
      }

      notifyListeners();
      return false;
    }
  }

  /// Méthode pour supprimer une catégorie
  Future<bool> deleteCategory(int id) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      await _categoryService.deleteCategory(id);

      // Supprimer de la liste des catégories
      _categories.removeWhere((c) => c.id == id);

      // Réinitialiser la catégorie sélectionnée si c'est celle qui a été supprimée
      if (_selectedCategory?.id == id) {
        _selectedCategory = null;
        _categoryProducts = [];
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _hasError = true;

      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage =
            'Erreur lors de la suppression de la catégorie: ${e.toString()}';
      }

      notifyListeners();
      return false;
    }
  }

  /// Méthode pour sélectionner une catégorie
  void selectCategory(Category category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Méthode pour réinitialiser la catégorie sélectionnée
  void clearSelectedCategory() {
    _selectedCategory = null;
    _categoryProducts = [];
    notifyListeners();
  }

  /// Méthode pour réinitialiser les erreurs
  void clearErrors() {
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }

  /// Méthode pour rafraîchir les données
  Future<void> refresh() async {
    await loadCategories();
    if (_selectedCategory != null) {
      await loadCategoryProducts(_selectedCategory!.id);
    }
    clearErrors();
  }
}

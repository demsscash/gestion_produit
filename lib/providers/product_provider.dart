import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../utils/error_handler.dart';

/// Provider pour gérer l'état des produits
class ProductProvider with ChangeNotifier {
  final ProductService _productService;

  /// Liste des produits
  List<Product> _products = [];

  /// Produit sélectionné
  Product? _selectedProduct;

  /// État de chargement
  bool _isLoading = false;

  /// État d'erreur
  bool _hasError = false;

  /// Message d'erreur
  String _errorMessage = '';

  /// Contrôleur de pagination pour l'infinite scroll
  final PagingController<int, Product> pagingController = PagingController(
    firstPageKey: 1,
  );

  /// Nombre d'éléments par page
  final int _pageSize = 10;

  /// Constructeur avec injection du service de produits
  ProductProvider({ProductService? productService})
    : _productService = productService ?? ProductService() {
    // Configurer le contrôleur de pagination
    pagingController.addPageRequestListener((pageKey) {
      _fetchProductsPage(pageKey);
    });
  }

  /// Getters pour les propriétés
  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  /// Méthode pour charger tous les produits
  Future<void> loadProducts() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      _products = await _productService.getProducts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _hasError = true;

      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage =
            'Erreur lors du chargement des produits: ${e.toString()}';
      }

      notifyListeners();
    }
  }

  /// Méthode pour charger les produits avec pagination
  Future<void> _fetchProductsPage(int pageKey) async {
    try {
      final newProducts = await _productService.getProducts(
        page: pageKey,
        perPage: _pageSize,
      );

      final isLastPage = newProducts.length < _pageSize;
      if (isLastPage) {
        pagingController.appendLastPage(newProducts);
      } else {
        pagingController.appendPage(newProducts, pageKey + 1);
      }
    } catch (e) {
      pagingController.error = e;
    }
  }

  /// Méthode pour charger un produit spécifique
  Future<void> loadProduct(int id) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      _selectedProduct = await _productService.getProduct(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _hasError = true;

      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Erreur lors du chargement du produit: ${e.toString()}';
      }

      notifyListeners();
    }
  }

  /// Méthode pour ajouter un produit
  Future<bool> addProduct(Product product) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final newProduct = await _productService.createProduct(product);
      _products.add(newProduct);
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
        _errorMessage = 'Erreur lors de l\'ajout du produit: ${e.toString()}';
      }

      notifyListeners();
      return false;
    }
  }

  /// Méthode pour mettre à jour un produit
  Future<bool> updateProduct(int id, Product product) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final updatedProduct = await _productService.updateProduct(id, product);

      // Mettre à jour la liste des produits
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }

      // Mettre à jour le produit sélectionné
      if (_selectedProduct?.id == id) {
        _selectedProduct = updatedProduct;
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
            'Erreur lors de la mise à jour du produit: ${e.toString()}';
      }

      notifyListeners();
      return false;
    }
  }

  /// Méthode pour supprimer un produit
  Future<bool> deleteProduct(int id) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      await _productService.deleteProduct(id);

      // Supprimer de la liste des produits
      _products.removeWhere((p) => p.id == id);

      // Réinitialiser le produit sélectionné si c'est celui qui a été supprimé
      if (_selectedProduct?.id == id) {
        _selectedProduct = null;
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
            'Erreur lors de la suppression du produit: ${e.toString()}';
      }

      notifyListeners();
      return false;
    }
  }

  /// Méthode pour sélectionner un produit
  void selectProduct(Product product) {
    _selectedProduct = product;
    notifyListeners();
  }

  /// Méthode pour réinitialiser le produit sélectionné
  void clearSelectedProduct() {
    _selectedProduct = null;
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
    pagingController.refresh();
    clearErrors();
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }
}

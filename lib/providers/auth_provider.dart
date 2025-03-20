import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/error_handler.dart';

/// Statuts possibles de l'authentification
enum AuthStatus {
  /// Statut initial lors du chargement de l'application
  initial,

  /// En cours d'authentification
  authenticating,

  /// Authentifié avec succès
  authenticated,

  /// Non authentifié (déconnecté ou erreur)
  unauthenticated,

  /// Erreur d'authentification
  error,
}

/// Provider qui gère l'état d'authentification
class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String _errorMessage = '';

  // Constructeur avec injection du service d'authentification
  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    // Vérifier l'état d'authentification au démarrage
    _checkAuthStatus();
  }

  // Getters pour les propriétés
  AuthStatus get status => _status;
  User? get user => _user;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAuthenticating => _status == AuthStatus.authenticating;
  bool get isAdmin => _user?.isAdmin ?? false;

  // Méthode pour vérifier l'état d'authentification
  Future<void> _checkAuthStatus() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        _user = await _authService.getCurrentUser();
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      print('Erreur lors de la vérification de l\'authentification: $e');
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Méthode pour se connecter
  Future<bool> login(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = '';
    notifyListeners();

    try {
      _user = await _authService.login(email: email, password: password);

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;

      if (e is ValidationException) {
        _errorMessage = e.getFirstError();
      } else if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Erreur lors de la connexion: ${e.toString()}';
      }

      notifyListeners();
      return false;
    }
  }

  // Méthode pour s'inscrire
  Future<bool> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    _status = AuthStatus.authenticating;
    _errorMessage = '';
    notifyListeners();

    try {
      await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;

      if (e is ValidationException) {
        _errorMessage = e.getFirstError();
      } else if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Erreur lors de l\'inscription: ${e.toString()}';
      }

      notifyListeners();
      return false;
    }
  }

  // Méthode pour se déconnecter
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    } finally {
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  // Méthode pour rafraîchir les données de l'utilisateur
  Future<void> refreshUserData() async {
    try {
      _user = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      print('Erreur lors du rafraîchissement des données utilisateur: $e');
    }
  }
}

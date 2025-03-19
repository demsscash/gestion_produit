import '../config/api_config.dart';
import '../models/user.dart';
import '../utils/shared_prefs.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  // Méthode pour s'inscrire
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _apiService.post(ApiConfig.register, {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    }, requiresAuth: false);

    return response;
  }

  // Méthode pour se connecter
  Future<User> login({required String email, required String password}) async {
    final response = await _apiService.post(ApiConfig.login, {
      'email': email,
      'password': password,
    }, requiresAuth: false);

    // Extraire et stocker le token
    final String token = response['access_token'];
    await SharedPrefs.setToken(token);

    // Calculer et stocker la date d'expiration du token
    final int expiresInSeconds = response['expires_in'] ?? 3600;
    final DateTime expiryTime = DateTime.now().add(
      Duration(seconds: expiresInSeconds),
    );
    await SharedPrefs.setTokenExpiry(expiryTime);

    // Extraire et renvoyer les informations de l'utilisateur
    final User user = User.fromJson(response['user']);
    await SharedPrefs.setUser(user);

    return user;
  }

  // Méthode pour se déconnecter
  Future<void> logout() async {
    try {
      await _apiService.post(ApiConfig.logout, {});
    } catch (e) {
      // Même en cas d'erreur, on supprime les données locales
      print('Erreur lors de la déconnexion: $e');
    } finally {
      await _clearAuthData();
    }
  }

  // Méthode pour actualiser le token
  Future<bool> refreshToken() async {
    try {
      final response = await _apiService.post(ApiConfig.refresh, {});

      // Extraire et stocker le nouveau token
      final String token = response['access_token'];
      await SharedPrefs.setToken(token);

      // Calculer et stocker la nouvelle date d'expiration du token
      final int expiresInSeconds = response['expires_in'] ?? 3600;
      final DateTime expiryTime = DateTime.now().add(
        Duration(seconds: expiresInSeconds),
      );
      await SharedPrefs.setTokenExpiry(expiryTime);

      return true;
    } catch (e) {
      print('Erreur lors du rafraîchissement du token: $e');
      await _clearAuthData();
      return false;
    }
  }

  // Méthode pour vérifier si le token est valide
  Future<bool> isAuthenticated() async {
    final token = await SharedPrefs.getToken();
    final expiryTime = await SharedPrefs.getTokenExpiry();

    if (token == null || expiryTime == null) {
      return false;
    }

    // Si le token expire dans moins de 5 minutes, on essaie de le rafraîchir
    if (expiryTime.difference(DateTime.now()).inMinutes < 5) {
      return await refreshToken();
    }

    return true;
  }

  // Méthode pour obtenir les informations de l'utilisateur actuel
  Future<User?> getCurrentUser() async {
    if (!await isAuthenticated()) {
      return null;
    }

    try {
      // On essaie d'abord de récupérer depuis les préférences
      User? user = await SharedPrefs.getUser();

      // Si pas d'utilisateur en cache, on interroge l'API
      if (user == null) {
        final response = await _apiService.get(ApiConfig.me);
        user = User.fromJson(response);
        await SharedPrefs.setUser(user);
      }

      return user;
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  // Méthode privée pour effacer les données d'authentification
  Future<void> _clearAuthData() async {
    await SharedPrefs.removeToken();
    await SharedPrefs.removeTokenExpiry();
    await SharedPrefs.removeUser();
  }
}

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

/// Classe utilitaire pour gérer le stockage local et sécurisé
class SharedPrefs {
  // Clés pour le stockage
  static const String _tokenKey = 'auth_token';
  static const String _tokenExpiryKey = 'auth_token_expiry';
  static const String _userKey = 'current_user';

  // Instance de stockage sécurisé pour les données sensibles
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Méthodes pour gérer le token JWT

  /// Stocke le token d'authentification dans le stockage sécurisé
  static Future<void> setToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Récupère le token d'authentification depuis le stockage sécurisé
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Supprime le token d'authentification du stockage sécurisé
  static Future<void> removeToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  // Méthodes pour gérer la date d'expiration du token

  /// Stocke la date d'expiration du token
  static Future<void> setTokenExpiry(DateTime expiry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
  }

  /// Récupère la date d'expiration du token
  static Future<DateTime?> getTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString(_tokenExpiryKey);
    if (expiryString == null) return null;

    return DateTime.parse(expiryString);
  }

  /// Supprime la date d'expiration du token
  static Future<void> removeTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenExpiryKey);
  }

  // Méthodes pour gérer les données de l'utilisateur

  /// Stocke les données de l'utilisateur
  static Future<void> setUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// Récupère les données de l'utilisateur
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString == null) return null;

    try {
      return User.fromJson(jsonDecode(userString));
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  /// Supprime les données de l'utilisateur
  static Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Méthodes génériques

  /// Stocke une valeur dans les préférences partagées
  static Future<void> setValue(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      await prefs.setString(key, jsonEncode(value));
    }
  }

  /// Récupère une valeur depuis les préférences partagées
  static Future<dynamic> getValue(String key, Type type) async {
    final prefs = await SharedPreferences.getInstance();

    if (type == String) {
      return prefs.getString(key);
    } else if (type == int) {
      return prefs.getInt(key);
    } else if (type == double) {
      return prefs.getDouble(key);
    } else if (type == bool) {
      return prefs.getBool(key);
    } else if (type == List<String>) {
      return prefs.getStringList(key);
    } else {
      final value = prefs.getString(key);
      if (value == null) return null;

      return jsonDecode(value);
    }
  }

  /// Supprime une valeur des préférences partagées
  static Future<void> removeValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Efface toutes les préférences partagées
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _secureStorage.deleteAll();
  }
}

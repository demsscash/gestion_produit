import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../utils/error_handler.dart';
import '../utils/shared_prefs.dart';

class ApiService {
  final http.Client _client = http.Client();

  // Récupération du token depuis le stockage sécurisé
  Future<String?> _getToken() async {
    return await SharedPrefs.getToken();
  }

  // Méthode GET
  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _prepareHeaders(requiresAuth);
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: headers,
      );
      return _processResponse(response);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  // Méthode POST
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _prepareHeaders(requiresAuth);
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  // Méthode PUT
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _prepareHeaders(requiresAuth);
      final response = await _client.put(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  // Méthode DELETE
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _prepareHeaders(requiresAuth);
      final response = await _client.delete(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: headers,
      );
      return _processResponse(response);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  // Prépare les en-têtes avec le token d'authentification si nécessaire
  Future<Map<String, String>> _prepareHeaders(bool requiresAuth) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        throw Exception('Authentification requise');
      }
    }

    return headers;
  }

  // Traite la réponse HTTP
  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Non autorisé. Veuillez vous reconnecter.');
    } else if (response.statusCode == 403) {
      throw ForbiddenException(
        'Accès interdit. Vous n\'avez pas les permissions requises.',
      );
    } else if (response.statusCode == 404) {
      throw NotFoundException(
        'Ressource non trouvée: ${response.request?.url}',
      );
    } else if (response.statusCode == 422) {
      final Map<String, dynamic> data = json.decode(response.body);
      final Map<String, dynamic> errors = data['errors'] ?? {};
      throw ValidationException('Erreur de validation', errors);
    } else {
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        final String message = data['message'] ?? 'Erreur inconnue';
        throw ApiException(message, response.statusCode);
      } catch (e) {
        if (e is ApiException) {
          rethrow;
        }
        throw ApiException(
          'Erreur serveur: ${response.statusCode}',
          response.statusCode,
        );
      }
    }
  }
}

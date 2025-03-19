import 'dart:io';

// Classe d'exception de base pour les erreurs d'API
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

// Exception pour les erreurs d'authentification
class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message, 401);
}

// Exception pour les erreurs de permissions
class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message, 403);
}

// Exception pour les ressources non trouvées
class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message, 404);
}

// Exception pour les erreurs de validation
class ValidationException extends ApiException {
  final Map<String, dynamic> errors;

  ValidationException(String message, this.errors) : super(message, 422);

  String getFirstError() {
    if (errors.isEmpty) return message;

    final firstField = errors.keys.first;
    final firstError =
        errors[firstField] is List
            ? errors[firstField][0]
            : errors[firstField].toString();

    return '$firstField: $firstError';
  }
}

// Gestionnaire d'erreurs central
class ErrorHandler {
  static Exception handleError(dynamic e) {
    if (e is ApiException) {
      return e;
    } else if (e is SocketException) {
      return ApiException(
        'Erreur de connexion au serveur. Vérifiez votre connexion internet.',
        0,
      );
    } else if (e is HttpException) {
      return ApiException('Erreur HTTP: ${e.message}', 0);
    } else if (e is FormatException) {
      return ApiException('Format de réponse invalide: ${e.message}', 0);
    } else {
      return ApiException('Une erreur est survenue: ${e.toString()}', 0);
    }
  }
}

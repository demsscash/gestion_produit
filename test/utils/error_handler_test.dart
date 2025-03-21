import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_produit/utils/error_handler.dart';

void main() {
  group('ApiException', () {
    test('doit créer ApiException avec message et statusCode', () {
      final exception = ApiException('Message d\'erreur', 400);
      expect(exception.message, 'Message d\'erreur');
      expect(exception.statusCode, 400);
      expect(exception.toString(), 'Message d\'erreur');
    });
  });

  group('ValidationException', () {
    test('doit créer ValidationException avec message et erreurs', () {
      final exception = ValidationException('Erreur de validation', {
        'name': ['Le nom est requis'],
        'email': ['L\'email est invalide']
      });
      expect(exception.message, 'Erreur de validation');
      expect(exception.statusCode, 422);
      expect(exception.errors.length, 2);
      expect(exception.errors['name'][0], 'Le nom est requis');
      expect(exception.errors['email'][0], 'L\'email est invalide');
    });

    test('doit retourner le premier message d\'erreur', () {
      final exception = ValidationException('Erreur de validation', {
        'name': ['Le nom est requis'],
        'email': ['L\'email est invalide']
      });
      expect(exception.getFirstError(), 'name: Le nom est requis');
    });

    test('doit retourner le message original quand errors est vide', () {
      final exception = ValidationException('Erreur de validation', {});
      expect(exception.getFirstError(), 'Erreur de validation');
    });
  });

  group('ErrorHandler', () {
    test('doit retourner la même exception si c\'est une ApiException', () {
      final original = ApiException('Erreur API', 400);
      final result = ErrorHandler.handleError(original);
      expect(result, same(original));
    });

    test('doit envelopper SocketException dans ApiException', () {
      final original = SocketException('Connexion échouée');
      final result = ErrorHandler.handleError(original);
      expect(result, isA<ApiException>());
      expect(result.toString(), contains('connexion au serveur'));
    });

    test('doit envelopper HttpException dans ApiException', () {
      final original = HttpException('Erreur HTTP');
      final result = ErrorHandler.handleError(original);
      expect(result, isA<ApiException>());
      expect(result.toString(), contains('Erreur HTTP'));
    });

    test('doit envelopper FormatException dans ApiException', () {
      final original = FormatException('Erreur de format');
      final result = ErrorHandler.handleError(original);
      expect(result, isA<ApiException>());
      expect(result.toString(), contains('Format de réponse invalide'));
    });

    test('doit envelopper une exception inconnue dans ApiException', () {
      final original = Exception('Erreur inconnue');
      final result = ErrorHandler.handleError(original);
      expect(result, isA<ApiException>());
      expect(result.toString(), contains('Une erreur est survenue'));
    });
  });
}

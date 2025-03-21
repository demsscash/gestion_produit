import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_produit/models/user.dart';

void main() {
  group('User', () {
    test('doit créer une instance de User à partir de json', () {
      // Préparation
      final Map<String, dynamic> json = {
        'id': 1,
        'name': 'Jean Dupont',
        'email': 'jean@exemple.com',
        'role': 'user',
        'email_verified_at': '2023-01-01T00:00:00.000Z'
      };

      // Action
      final user = User.fromJson(json);

      // Vérification
      expect(user.id, 1);
      expect(user.name, 'Jean Dupont');
      expect(user.email, 'jean@exemple.com');
      expect(user.role, 'user');
      expect(user.emailVerifiedAt, DateTime.parse('2023-01-01T00:00:00.000Z'));
      expect(user.isAdmin, isFalse);
    });

    test('doit gérer un email_verified_at null dans json', () {
      // Préparation
      final Map<String, dynamic> json = {
        'id': 1,
        'name': 'Jean Dupont',
        'email': 'jean@exemple.com',
        'role': 'user',
        'email_verified_at': null
      };

      // Action
      final user = User.fromJson(json);

      // Vérification
      expect(user.id, 1);
      expect(user.name, 'Jean Dupont');
      expect(user.email, 'jean@exemple.com');
      expect(user.role, 'user');
      expect(user.emailVerifiedAt, isNull);
    });

    test('doit détecter correctement le rôle admin', () {
      // Préparation
      final Map<String, dynamic> json = {
        'id': 1,
        'name': 'Utilisateur Admin',
        'email': 'admin@exemple.com',
        'role': 'admin',
        'email_verified_at': '2023-01-01T00:00:00.000Z'
      };

      // Action
      final user = User.fromJson(json);

      // Vérification
      expect(user.isAdmin, isTrue);
    });

    test('doit convertir un utilisateur en json', () {
      // Préparation
      final user = User(
        id: 1,
        name: 'Jean Dupont',
        email: 'jean@exemple.com',
        role: 'user',
        emailVerifiedAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
      );

      // Action
      final json = user.toJson();

      // Vérification
      expect(json['id'], 1);
      expect(json['name'], 'Jean Dupont');
      expect(json['email'], 'jean@exemple.com');
      expect(json['role'], 'user');
      expect(json['email_verified_at'], '2023-01-01T00:00:00.000Z');
    });

    test('doit convertir un utilisateur avec email_verified_at null en json',
        () {
      // Préparation
      final user = User(
        id: 1,
        name: 'Jean Dupont',
        email: 'jean@exemple.com',
        role: 'user',
      );

      // Action
      final json = user.toJson();

      // Vérification
      expect(json['id'], 1);
      expect(json['name'], 'Jean Dupont');
      expect(json['email'], 'jean@exemple.com');
      expect(json['role'], 'user');
      expect(json['email_verified_at'], isNull);
    });
  });
}

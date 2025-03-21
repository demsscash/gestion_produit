import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_produit/models/category.dart';

void main() {
  group('Category', () {
    test('doit créer une instance de Category à partir de json', () {
      // Préparation
      final Map<String, dynamic> json = {
        'id': 1,
        'name': 'Catégorie Test',
        'description': 'Ceci est une catégorie test'
      };

      // Action
      final category = Category.fromJson(json);

      // Vérification
      expect(category.id, 1);
      expect(category.name, 'Catégorie Test');
      expect(category.description, 'Ceci est une catégorie test');
    });

    test('doit gérer une description null dans json', () {
      // Préparation
      final Map<String, dynamic> json = {
        'id': 1,
        'name': 'Catégorie Test',
        'description': null
      };

      // Action
      final category = Category.fromJson(json);

      // Vérification
      expect(category.id, 1);
      expect(category.name, 'Catégorie Test');
      expect(category.description, isNull);
    });

    test('doit convertir une catégorie en json', () {
      // Préparation
      final category = Category(
          id: 1,
          name: 'Catégorie Test',
          description: 'Ceci est une catégorie test');

      // Action
      final json = category.toJson();

      // Vérification
      expect(json['id'], 1);
      expect(json['name'], 'Catégorie Test');
      expect(json['description'], 'Ceci est une catégorie test');
    });

    test('doit convertir une catégorie avec description null en json', () {
      // Préparation
      final category = Category(id: 1, name: 'Catégorie Test');

      // Action
      final json = category.toJson();

      // Vérification
      expect(json['id'], 1);
      expect(json['name'], 'Catégorie Test');
      expect(json['description'], isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_produit/models/product.dart';
import 'package:gestion_produit/models/category.dart';

void main() {
  group('Product', () {
    test('doit créer une instance de Product à partir de json', () {
      // Préparation
      final Map<String, dynamic> json = {
        'id': 1,
        'name': 'Produit Test',
        'description': 'Ceci est un produit test',
        'price': 19.99,
        'stock': 10,
        'categories': [
          {
            'id': 1,
            'name': 'Catégorie Test',
            'description': 'Description de la catégorie test'
          }
        ],
        'created_at': '2023-01-01T00:00:00.000Z',
        'updated_at': '2023-01-02T00:00:00.000Z'
      };

      // Action
      final product = Product.fromJson(json);

      // Vérification
      expect(product.id, 1);
      expect(product.name, 'Produit Test');
      expect(product.description, 'Ceci est un produit test');
      expect(product.price, 19.99);
      expect(product.stock, 10);
      expect(product.categories.length, 1);
      expect(product.categories[0].id, 1);
      expect(product.categories[0].name, 'Catégorie Test');
      expect(product.categories[0].description,
          'Description de la catégorie test');
      expect(product.createdAt, DateTime.parse('2023-01-01T00:00:00.000Z'));
      expect(product.updatedAt, DateTime.parse('2023-01-02T00:00:00.000Z'));
    });

    test('doit gérer un prix entier dans json', () {
      // Préparation
      final Map<String, dynamic> json = {
        'id': 1,
        'name': 'Produit Test',
        'description': null,
        'price': 20,
        'stock': 10,
        'categories': [],
        'created_at': '2023-01-01T00:00:00.000Z',
        'updated_at': '2023-01-02T00:00:00.000Z'
      };

      // Action
      final product = Product.fromJson(json);

      // Vérification
      expect(product.price, 20.0);
      expect(product.price, isA<double>());
    });

    test('doit convertir un produit en json', () {
      // Préparation
      final product = Product(
        id: 1,
        name: 'Produit Test',
        description: 'Ceci est un produit test',
        price: 19.99,
        stock: 10,
        categories: [
          Category(id: 1, name: 'Catégorie 1'),
          Category(id: 2, name: 'Catégorie 2')
        ],
        createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2023-01-02T00:00:00.000Z'),
      );

      // Action
      final json = product.toJson();

      // Vérification
      expect(json['name'], 'Produit Test');
      expect(json['description'], 'Ceci est un produit test');
      expect(json['price'], 19.99);
      expect(json['stock'], 10);
      expect(json['categories'], [1, 2]);

      // Ces champs ne doivent pas être inclus dans toJson
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('created_at'), isFalse);
      expect(json.containsKey('updated_at'), isFalse);
    });

    test('doit créer une copie avec des valeurs mises à jour', () {
      // Préparation
      final product = Product(
        id: 1,
        name: 'Produit Test',
        description: 'Ceci est un produit test',
        price: 19.99,
        stock: 10,
        categories: [Category(id: 1, name: 'Catégorie 1')],
        createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2023-01-02T00:00:00.000Z'),
      );

      // Action
      final updatedProduct = product.copyWith(
        name: 'Produit Mis à Jour',
        price: 29.99,
        stock: 5,
      );

      // Vérification
      expect(updatedProduct.id, 1); // Inchangé
      expect(updatedProduct.name, 'Produit Mis à Jour'); // Changé
      expect(
          updatedProduct.description, 'Ceci est un produit test'); // Inchangé
      expect(updatedProduct.price, 29.99); // Changé
      expect(updatedProduct.stock, 5); // Changé
      expect(updatedProduct.categories.length, 1); // Inchangé
      expect(updatedProduct.createdAt, product.createdAt); // Inchangé
      expect(updatedProduct.updatedAt, product.updatedAt); // Inchangé
    });
  });
}

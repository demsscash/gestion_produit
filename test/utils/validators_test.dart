import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_produit/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('doit retourner null pour un email valide', () {
        final result = Validators.validateEmail('test@example.com');
        expect(result, isNull);
      });

      test('doit retourner un message d\'erreur pour un email vide', () {
        final result = Validators.validateEmail('');
        expect(result, 'L\'email est requis');
      });

      test(
          'doit retourner un message d\'erreur pour un format d\'email invalide',
          () {
        final result = Validators.validateEmail('invalid-email');
        expect(result, 'Veuillez entrer une adresse email valide');
      });
    });

    group('validatePassword', () {
      test('doit retourner null pour un mot de passe valide', () {
        final result = Validators.validatePassword('password123');
        expect(result, isNull);
      });

      test('doit retourner un message d\'erreur pour un mot de passe vide', () {
        final result = Validators.validatePassword('');
        expect(result, 'Le mot de passe est requis');
      });

      test(
          'doit retourner un message d\'erreur pour un mot de passe trop court',
          () {
        final result = Validators.validatePassword('pass');
        expect(result, 'Le mot de passe doit contenir au moins 8 caractères');
      });
    });

    group('validatePasswordConfirmation', () {
      test('doit retourner null quand les mots de passe correspondent', () {
        final result = Validators.validatePasswordConfirmation(
            'password123', 'password123');
        expect(result, isNull);
      });

      test('doit retourner un message d\'erreur pour une confirmation vide',
          () {
        final result =
            Validators.validatePasswordConfirmation('', 'password123');
        expect(result, 'La confirmation du mot de passe est requise');
      });

      test(
          'doit retourner un message d\'erreur quand les mots de passe ne correspondent pas',
          () {
        final result = Validators.validatePasswordConfirmation(
            'password321', 'password123');
        expect(result, 'Les mots de passe ne correspondent pas');
      });
    });

    group('validateName', () {
      test('doit retourner null pour un nom valide', () {
        final result = Validators.validateName('John Doe');
        expect(result, isNull);
      });

      test('doit retourner un message d\'erreur pour un nom vide', () {
        final result = Validators.validateName('');
        expect(result, 'Le nom est requis');
      });

      test('doit retourner un message d\'erreur pour un nom trop court', () {
        final result = Validators.validateName('J');
        expect(result, 'Le nom doit contenir au moins 2 caractères');
      });
    });

    group('validatePrice', () {
      test('doit retourner null pour un prix valide', () {
        final result = Validators.validatePrice('10.50');
        expect(result, isNull);
      });

      test('doit retourner null pour un prix avec virgule', () {
        final result = Validators.validatePrice('10,50');
        expect(result, isNull);
      });

      test('doit retourner un message d\'erreur pour un prix vide', () {
        final result = Validators.validatePrice('');
        expect(result, 'Le prix est requis');
      });

      test(
          'doit retourner un message d\'erreur pour un format de prix invalide',
          () {
        final result = Validators.validatePrice('abc');
        expect(result, 'Veuillez entrer un prix valide');
      });

      test('doit retourner un message d\'erreur pour un prix négatif', () {
        final result = Validators.validatePrice('-10.50');
        expect(result, 'Le prix ne peut pas être négatif');
      });
    });

    group('validateStock', () {
      test('doit retourner null pour un stock valide', () {
        final result = Validators.validateStock('10');
        expect(result, isNull);
      });

      test('doit retourner un message d\'erreur pour un stock vide', () {
        final result = Validators.validateStock('');
        expect(result, 'Le stock est requis');
      });

      test(
          'doit retourner un message d\'erreur pour un format de stock invalide',
          () {
        final result = Validators.validateStock('abc');
        expect(result, 'Veuillez entrer un nombre entier valide');
      });

      test('doit retourner un message d\'erreur pour un stock négatif', () {
        final result = Validators.validateStock('-10');
        expect(result, 'Le stock ne peut pas être négatif');
      });
    });

    group('validateCategories', () {
      test('doit retourner null pour une liste de catégories non vide', () {
        final result = Validators.validateCategories([1, 2, 3]);
        expect(result, isNull);
      });

      test(
          'doit retourner un message d\'erreur pour une liste de catégories vide',
          () {
        final result = Validators.validateCategories([]);
        expect(result, 'Au moins une catégorie est requise');
      });

      test(
          'doit retourner un message d\'erreur pour une liste de catégories null',
          () {
        final result = Validators.validateCategories(null);
        expect(result, 'Au moins une catégorie est requise');
      });
    });

    group('validateRequired', () {
      test('doit retourner null pour une valeur non vide', () {
        final result = Validators.validateRequired('value', 'Champ');
        expect(result, isNull);
      });

      test('doit retourner un message d\'erreur pour une valeur vide', () {
        final result = Validators.validateRequired('', 'Champ');
        expect(result, 'Champ est requis');
      });

      test('doit retourner un message d\'erreur pour une valeur null', () {
        final result = Validators.validateRequired(null, 'Champ');
        expect(result, 'Champ est requis');
      });
    });
  });
}

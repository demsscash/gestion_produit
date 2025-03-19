/// Classe contenant des méthodes de validation pour les formulaires
class Validators {
  /// Valide une adresse email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }

    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(value)) {
      return 'Veuillez entrer une adresse email valide';
    }

    return null;
  }

  /// Valide un mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }

    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }

    return null;
  }

  /// Valide la confirmation d'un mot de passe
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'La confirmation du mot de passe est requise';
    }

    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }

    return null;
  }

  /// Valide un nom
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom est requis';
    }

    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }

    return null;
  }

  /// Valide un prix
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le prix est requis';
    }

    final double? price = double.tryParse(value.replaceAll(',', '.'));
    if (price == null) {
      return 'Veuillez entrer un prix valide';
    }

    if (price < 0) {
      return 'Le prix ne peut pas être négatif';
    }

    return null;
  }

  /// Valide un stock
  static String? validateStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le stock est requis';
    }

    final int? stock = int.tryParse(value);
    if (stock == null) {
      return 'Veuillez entrer un nombre entier valide';
    }

    if (stock < 0) {
      return 'Le stock ne peut pas être négatif';
    }

    return null;
  }

  /// Valide une liste de catégories
  static String? validateCategories(List<dynamic>? value) {
    if (value == null || value.isEmpty) {
      return 'Au moins une catégorie est requise';
    }

    return null;
  }

  /// Valide un champ requis
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }

    return null;
  }
}

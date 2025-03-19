import 'package:flutter/material.dart';

/// Utilitaire pour gérer les erreurs de formulaire
class FormUtil {
  /// Affiche un message d'erreur sous un champ de formulaire
  static Widget buildErrorText(String? errorText) {
    if (errorText == null || errorText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 12.0),
      child: Text(
        errorText,
        style: const TextStyle(color: Colors.red, fontSize: 12.0),
      ),
    );
  }

  /// Crée un style de décoration pour les champs de formulaire
  static InputDecoration inputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
    );
  }

  /// Crée un style de décoration pour les champs de formulaire de type texte multiligne
  static InputDecoration textAreaDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      alignLabelWithHint: true,
    );
  }

  /// Style pour les boutons de formulaire
  static ButtonStyle formButtonStyle() {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
    );
  }

  /// Crée un sélecteur de date
  static Future<DateTime?> showDatePickerDialog(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final currentDate = DateTime.now();

    return showDatePicker(
      context: context,
      initialDate: initialDate ?? currentDate,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(currentDate.year + 10),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  /// Formate une date pour l'affichage
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

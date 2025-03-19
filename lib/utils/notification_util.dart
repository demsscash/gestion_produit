import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

/// Utilitaire pour afficher des notifications dans l'application
class NotificationUtil {
  /// Affiche une notification de succès
  static void showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    Duration? duration,
  }) {
    Flushbar(
      title: title ?? 'Succès',
      message: message,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: duration ?? const Duration(seconds: 3),
      backgroundColor: Colors.green,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  /// Affiche une notification d'erreur
  static void showError(
    BuildContext context, {
    required String message,
    String? title,
    Duration? duration,
  }) {
    Flushbar(
      title: title ?? 'Erreur',
      message: message,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: duration ?? const Duration(seconds: 3),
      backgroundColor: Colors.red,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  /// Affiche une notification d'information
  static void showInfo(
    BuildContext context, {
    required String message,
    String? title,
    Duration? duration,
  }) {
    Flushbar(
      title: title ?? 'Information',
      message: message,
      icon: const Icon(Icons.info, color: Colors.white),
      duration: duration ?? const Duration(seconds: 3),
      backgroundColor: Colors.blue,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  /// Affiche une notification d'avertissement
  static void showWarning(
    BuildContext context, {
    required String message,
    String? title,
    Duration? duration,
  }) {
    Flushbar(
      title: title ?? 'Attention',
      message: message,
      icon: const Icon(Icons.warning, color: Colors.white),
      duration: duration ?? const Duration(seconds: 3),
      backgroundColor: Colors.orange,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  /// Affiche une boîte de dialogue de confirmation
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String cancelText = 'ANNULER',
    String confirmText = 'CONFIRMER',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelText),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  confirmText,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    return result ?? false;
  }
}

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import '../../../models/category.dart';
import '../../../providers/category_provider.dart';
import '../../../utils/validators.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category;

  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(isEditing ? 'Modifier la catégorie' : 'Ajouter une catégorie'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'name': widget.category?.name ?? '',
            'description': widget.category?.description ?? '',
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Champ nom
              FormBuilderTextField(
                name: 'name',
                decoration: const InputDecoration(
                  labelText: 'Nom de la catégorie',
                  hintText: 'Entrez le nom de la catégorie',
                  prefixIcon: Icon(Icons.category),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Le nom de la catégorie est requis',
                  ),
                  FormBuilderValidators.minLength(
                    2,
                    errorText: 'Le nom doit contenir au moins 2 caractères',
                  ),
                ]),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Champ description
              FormBuilderTextField(
                name: 'description',
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Entrez une description de la catégorie',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 32),

              // Bouton d'enregistrement
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCategory,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(isEditing ? 'METTRE À JOUR' : 'AJOUTER'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Méthode pour enregistrer la catégorie
  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      final values = _formKey.currentState!.value;
      final categoryProvider = Provider.of<CategoryProvider>(
        context,
        listen: false,
      );

      // Préparer les données de la catégorie
      final name = values['name'] as String;
      final description = values['description'] as String?;

      bool success;

      if (widget.category == null) {
        // Créer une nouvelle catégorie
        final newCategory = Category(
          id: 0, // L'ID sera attribué par le serveur
          name: name,
          description: description,
        );

        success = await categoryProvider.addCategory(newCategory);
      } else {
        // Mettre à jour une catégorie existante
        final updatedCategory = Category(
          id: widget.category!.id,
          name: name,
          description: description,
        );

        success = await categoryProvider.updateCategory(
          widget.category!.id,
          updatedCategory,
        );
      }

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      if (success) {
        // Afficher un message de succès
        Flushbar(
          title: 'Succès',
          message: widget.category == null
              ? 'La catégorie a été ajoutée avec succès'
              : 'La catégorie a été mise à jour avec succès',
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);

        // Retourner à l'écran précédent après un court délai
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        // Afficher un message d'erreur
        Flushbar(
          title: 'Erreur',
          message: categoryProvider.errorMessage,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      }
    }
  }
}

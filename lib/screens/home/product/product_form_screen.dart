import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import '../../../models/category.dart';
import '../../../models/product.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../utils/validators.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  List<Category> _categories = [];
  List<Category> _selectedCategories = [];

  @override
  void initState() {
    super.initState();

    // Charger les catégories
    _loadCategories();

    // Initialiser les catégories sélectionnées
    if (widget.product != null) {
      _selectedCategories = List.from(widget.product!.categories);
    }
  }

  // Charger les catégories depuis l'API
  Future<void> _loadCategories() async {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    await categoryProvider.loadCategories();

    setState(() {
      _categories = categoryProvider.categories;
    });
  }

  // Méthode pour enregistrer le produit
  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      final values = _formKey.currentState!.value;
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      // Préparer les données du produit
      final name = values['name'] as String;
      final description = values['description'] as String?;
      final priceString = values['price'] as String;
      final stockString = values['stock'] as String;

      // Convertir les valeurs numériques
      final price = double.parse(priceString.replaceAll(',', '.'));
      final stock = int.parse(stockString);

      bool success;

      if (widget.product == null) {
        // Créer un nouveau produit
        final newProduct = Product(
          id: 0, // L'ID sera attribué par le serveur
          name: name,
          description: description,
          price: price,
          stock: stock,
          categories: _selectedCategories,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        success = await productProvider.addProduct(newProduct);
      } else {
        // Mettre à jour un produit existant
        final updatedProduct = Product(
          id: widget.product!.id,
          name: name,
          description: description,
          price: price,
          stock: stock,
          categories: _selectedCategories,
          createdAt: widget.product!.createdAt,
          updatedAt: DateTime.now(),
        );

        success = await productProvider.updateProduct(
          widget.product!.id,
          updatedProduct,
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
          message:
              widget.product == null
                  ? 'Le produit a été ajouté avec succès'
                  : 'Le produit a été mis à jour avec succès',
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
          message: productProvider.errorMessage,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le produit' : 'Ajouter un produit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'name': widget.product?.name ?? '',
            'description': widget.product?.description ?? '',
            'price': widget.product?.price.toString() ?? '',
            'stock': widget.product?.stock.toString() ?? '',
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Champ nom
              FormBuilderTextField(
                name: 'name',
                decoration: const InputDecoration(
                  labelText: 'Nom du produit',
                  hintText: 'Entrez le nom du produit',
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Le nom du produit est requis',
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
                  hintText: 'Entrez une description du produit',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Champ prix
              FormBuilderTextField(
                name: 'price',
                decoration: const InputDecoration(
                  labelText: 'Prix',
                  hintText: 'Entrez le prix du produit',
                  prefixIcon: Icon(Icons.euro),
                  suffixText: '€',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: Validators.validatePrice,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Champ stock
              FormBuilderTextField(
                name: 'stock',
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  hintText: 'Entrez la quantité en stock',
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                keyboardType: TextInputType.number,
                validator: Validators.validateStock,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Sélection des catégories
              const Text(
                'Catégories',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Liste des catégories
              if (_categories.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _categories.map((category) {
                        final isSelected = _selectedCategories.any(
                          (c) => c.id == category.id,
                        );

                        return FilterChip(
                          label: Text(category.name),
                          selected: isSelected,
                          onSelected:
                              _isLoading
                                  ? null
                                  : (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedCategories.add(category);
                                      } else {
                                        _selectedCategories.removeWhere(
                                          (c) => c.id == category.id,
                                        );
                                      }
                                    });
                                  },
                        );
                      }).toList(),
                ),

              if (_selectedCategories.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Veuillez sélectionner au moins une catégorie',
                    style: TextStyle(color: Colors.red[600], fontSize: 12),
                  ),
                ),

              const SizedBox(height: 32),

              // Bouton d'enregistrement
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isLoading || _selectedCategories.isEmpty
                          ? null
                          : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child:
                      _isLoading
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
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/category.dart';
import '../../../models/product.dart';
import '../../../providers/category_provider.dart';
import '../../../utils/theme.dart';
import '../product/product_detail_screen.dart';
import 'category_form_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final Category category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  List<Product> _products = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Charger les produits de la catégorie
    _loadCategoryProducts();
  }

  // Charger les produits de la catégorie
  Future<void> _loadCategoryProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    try {
      await categoryProvider.loadCategoryProducts(widget.category.id);

      setState(() {
        _products = categoryProvider.categoryProducts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          // Bouton de modification
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder:
                          (_) => CategoryFormScreen(category: widget.category),
                    ),
                  )
                  .then((_) => _loadCategoryProducts());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec informations de la catégorie
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icône de la catégorie
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.category,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nom de la catégorie
                  Text(
                    widget.category.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  if (widget.category.description != null &&
                      widget.category.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        widget.category.description!,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),

            // Liste des produits de la catégorie
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre de la section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Produits dans cette catégorie',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_products.isNotEmpty)
                        Text(
                          '${_products.length} produit${_products.length > 1 ? 's' : ''}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // État de chargement
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  // État d'erreur
                  else if (_hasError)
                    Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 50,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erreur lors du chargement des produits: $_errorMessage',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadCategoryProducts,
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    )
                  // Aucun produit
                  else if (_products.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 50,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucun produit dans cette catégorie',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ajoutez des produits à cette catégorie pour les voir ici',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  // Liste des produits
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _products.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return ProductItem(product: product);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget pour l'élément de liste de produit
class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            // Image du produit
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: 'https://via.placeholder.com/100',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image),
                    ),
              ),
            ),
            const SizedBox(width: 16),

            // Informations du produit
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.price.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        product.stock > 0
                            ? Icons.check_circle
                            : Icons.remove_circle,
                        size: 16,
                        color: product.stock > 0 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.stock > 0
                            ? 'En stock (${product.stock})'
                            : 'Rupture de stock',
                        style: TextStyle(
                          fontSize: 12,
                          color: product.stock > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Flèche de navigation
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

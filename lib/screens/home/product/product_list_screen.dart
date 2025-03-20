import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../models/product.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../utils/theme.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'name';
  int? _selectedCategoryId;
  bool _isLoading = false;
  List<Product> _products = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Ajouter un écouteur pour rechercher lorsque le texte change
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });

      // Rafraîchir les résultats
      _loadProducts();
    });

    // Charger les produits au démarrage
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Méthode pour charger les produits
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      if (_searchQuery.isEmpty && _selectedCategoryId == null) {
        await productProvider.loadProducts();
      } else {
        await productProvider.searchProducts(
          query: _searchQuery.isNotEmpty ? _searchQuery : null,
          categoryId: _selectedCategoryId,
        );
      }

      if (!mounted) return;

      setState(() {
        _products = productProvider.products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Méthode pour supprimer un produit
  Future<void> _deleteProduct(Product product) async {
    // Demander confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text(
          'Voulez-vous vraiment supprimer le produit "${product.name}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ANNULER'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('SUPPRIMER'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      final success = await productProvider.deleteProduct(product.id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produit supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );

        // Recharger les produits
        _loadProducts();
      } else {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(productProvider.errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Méthode pour changer le tri
  void _changeSorting(String sortBy) {
    setState(() {
      _sortBy = sortBy;
    });

    // Trier les produits
    _sortProducts();
  }

  // Méthode pour trier les produits
  void _sortProducts() {
    setState(() {
      switch (_sortBy) {
        case 'name':
          _products.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'price_asc':
          _products.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_desc':
          _products.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'newest':
          _products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
      }
    });
  }

  // Méthode pour filtrer par catégorie
  void _filterByCategory(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });

    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    // Obtenez les catégories pour le filtre
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categories;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Barre de recherche
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Champ de recherche
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un produit...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Options de tri et filtres
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Menu de tri
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => SimpleDialog(
                                title: const Text('Trier par'),
                                children: [
                                  SimpleDialogOption(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _changeSorting('name');
                                    },
                                    child: const Text('Nom'),
                                  ),
                                  SimpleDialogOption(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _changeSorting('price_asc');
                                    },
                                    child: const Text('Prix croissant'),
                                  ),
                                  SimpleDialogOption(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _changeSorting('price_desc');
                                    },
                                    child: const Text('Prix décroissant'),
                                  ),
                                  SimpleDialogOption(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _changeSorting('newest');
                                    },
                                    child: const Text('Plus récent'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Chip(
                            avatar: const Icon(Icons.sort, size: 18),
                            label: Text('Trier par: ${_getSortLabel(_sortBy)}'),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Filtre par catégorie
                        if (categories.isNotEmpty)
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => SimpleDialog(
                                  title: const Text('Filtrer par catégorie'),
                                  children: [
                                    SimpleDialogOption(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _filterByCategory(null);
                                      },
                                      child:
                                          const Text('Toutes les catégories'),
                                    ),
                                    ...categories.map(
                                      (category) => SimpleDialogOption(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _filterByCategory(category.id);
                                        },
                                        child: Text(category.name),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Chip(
                              avatar: const Icon(Icons.filter_list, size: 18),
                              label: Text(_selectedCategoryId == null
                                  ? 'Catégorie: Toutes'
                                  : 'Catégorie: ${categories.firstWhere((c) => c.id == _selectedCategoryId, orElse: () => categories.first).name}'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Liste des produits
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadProducts,
                child: _isLoading
                    ? _buildLoadingList()
                    : _errorMessage.isNotEmpty
                        ? _buildErrorWidget()
                        : _products.isEmpty
                            ? _buildEmptyState()
                            : _buildProductList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (_) => const ProductFormScreen(),
                ),
              )
              .then((_) => _loadProducts());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget pour l'état de chargement
  Widget _buildLoadingList() {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemBuilder: (context, index) {
        return const ProductShimmerItem();
      },
    );
  }

  // Widget pour l'état d'erreur
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur: $_errorMessage',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProducts,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  // Widget pour l'état vide
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: Colors.grey,
            size: 60,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun produit trouvé',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Essayez de modifier vos filtres ou ajoutez un nouveau produit',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (_) => const ProductFormScreen(),
                    ),
                  )
                  .then((_) => _loadProducts());
            },
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un produit'),
          ),
        ],
      ),
    );
  }

  // Widget pour la liste des produits
  Widget _buildProductList() {
    return ListView.builder(
      itemCount: _products.length,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemBuilder: (context, index) {
        final product = _products[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: OpenContainer(
            transitionDuration: const Duration(milliseconds: 500),
            closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            closedElevation: 2,
            openBuilder: (context, _) => ProductDetailScreen(product: product),
            closedBuilder: (context, openContainer) {
              return ProductListItem(
                product: product,
                onTap: openContainer,
                onEdit: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => ProductFormScreen(product: product),
                        ),
                      )
                      .then((_) => _loadProducts());
                },
                onDelete: () => _deleteProduct(product),
              );
            },
          ),
        );
      },
    );
  }

  // Obtenir le libellé de tri
  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'name':
        return 'Nom';
      case 'price_asc':
        return 'Prix ↑';
      case 'price_desc':
        return 'Prix ↓';
      case 'newest':
        return 'Plus récent';
      default:
        return 'Nom';
    }
  }
}

// Widget pour l'élément de liste de produit
class ProductListItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductListItem({
    super.key,
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Image du produit
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: 'https://via.placeholder.com/100',
                placeholder: (context, url) => const ProductImagePlaceholder(),
                errorWidget: (context, url, error) => const ProductImageError(),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
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
                  if (product.description != null &&
                      product.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        product.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Prix et catégories
                  Row(
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: product.stock > 0
                              ? Colors.green[100]
                              : Colors.red[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.stock > 0
                              ? 'En stock: ${product.stock}'
                              : 'Rupture',
                          style: TextStyle(
                            fontSize: 12,
                            color: product.stock > 0
                                ? Colors.green[800]
                                : Colors.red[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (product.categories.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Wrap(
                        spacing: 4,
                        children: product.categories
                            .take(2)
                            .map(
                              (category) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withAlpha(30),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                  tooltip: 'Modifier',
                  iconSize: 20,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                  tooltip: 'Supprimer',
                  iconSize: 20,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Widget pour afficher un placeholder d'image
class ProductImagePlaceholder extends StatelessWidget {
  const ProductImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

// Widget pour afficher une erreur d'image
class ProductImageError extends StatelessWidget {
  const ProductImageError({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.broken_image)),
    );
  }
}

// Widget pour le chargement
class ProductShimmerItem extends StatelessWidget {
  const ProductShimmerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Image placeholder
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Text placeholders
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: double.infinity,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 60,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 80,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions placeholders
              Column(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

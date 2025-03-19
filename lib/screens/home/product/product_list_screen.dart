import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../models/product.dart';
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
  int? _filterCategoryId;

  @override
  void initState() {
    super.initState();

    // Ajouter un écouteur pour rechercher lorsque le texte change
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });

      // Rafraîchir les résultats
      _refreshList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Méthode pour rafraîchir la liste
  void _refreshList() {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    productProvider.refresh();
  }

  // Méthode pour changer le tri
  void _changeSorting(String sortBy) {
    setState(() {
      _sortBy = sortBy;
    });
    _refreshList();
  }

  // Méthode pour supprimer un produit
  Future<void> _deleteProduct(Product product) async {
    // Demander confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(productProvider.errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Barre de recherche et filtres
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barre de recherche
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un produit...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          _searchQuery.isNotEmpty
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
                  Row(
                    children: [
                      // Menu de tri
                      PopupMenuButton<String>(
                        initialValue: _sortBy,
                        child: Chip(
                          avatar: const Icon(Icons.sort, size: 18),
                          label: Text('Trier par: ${_getSortLabel(_sortBy)}'),
                        ),
                        onSelected: _changeSorting,
                        itemBuilder:
                            (context) => [
                              const PopupMenuItem(
                                value: 'name',
                                child: Text('Nom'),
                              ),
                              const PopupMenuItem(
                                value: 'price_asc',
                                child: Text('Prix croissant'),
                              ),
                              const PopupMenuItem(
                                value: 'price_desc',
                                child: Text('Prix décroissant'),
                              ),
                              const PopupMenuItem(
                                value: 'newest',
                                child: Text('Plus récent'),
                              ),
                            ],
                      ),
                      const SizedBox(width: 8),

                      // Filtres par catégorie
                      // TODO: Implémenter le filtre par catégorie
                    ],
                  ),
                ],
              ),
            ),

            // Liste des produits avec pagination
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _refreshList(),
                child: PagedListView<int, Product>(
                  pagingController: productProvider.pagingController,
                  builderDelegate: PagedChildBuilderDelegate<Product>(
                    itemBuilder: (context, product, index) {
                      // Élément de liste de produit avec animation d'ouverture
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: OpenContainer(
                          transitionDuration: const Duration(milliseconds: 500),
                          closedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          closedElevation: 2,
                          openBuilder:
                              (context, _) =>
                                  ProductDetailScreen(product: product),
                          closedBuilder: (context, openContainer) {
                            return ProductListItem(
                              product: product,
                              onEdit: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                            ProductFormScreen(product: product),
                                  ),
                                );
                              },
                              onDelete: () => _deleteProduct(product),
                            );
                          },
                        ),
                      );
                    },
                    // État vide
                    firstPageErrorIndicatorBuilder:
                        (context) => Center(
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
                                'Erreur: ${productProvider.errorMessage}',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _refreshList,
                                child: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        ),
                    // État de chargement
                    firstPageProgressIndicatorBuilder:
                        (context) => ListView.builder(
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return const ProductShimmerItem();
                          },
                        ),
                    // État sans données
                    noItemsFoundIndicatorBuilder:
                        (context) => Center(
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
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const ProductFormScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Ajouter un produit'),
                              ),
                            ],
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductListItem({
    super.key,
    required this.product,
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

                  // Prix et stock
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
                          color:
                              product.stock > 0
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
                            color:
                                product.stock > 0
                                    ? Colors.green[800]
                                    : Colors.red[800],
                          ),
                        ),
                      ),
                    ],
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

// Widget pour le chargement
class ProductShimmerItem extends StatelessWidget {
  const ProductShimmerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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

// Widget pour afficher un placeholder d'image
class ProductImagePlaceholder extends StatelessWidget {
  const ProductImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: Center(child: Icon(Icons.image, color: Colors.grey[400])),
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
      child: Center(child: Icon(Icons.broken_image, color: Colors.grey[600])),
    );
  }
}

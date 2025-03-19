import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../models/category.dart';
import '../../../providers/category_provider.dart';
import 'category_detail_screen.dart';
import 'category_form_screen.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    categoryProvider.refresh();
  }

  // Méthode pour supprimer une catégorie
  Future<void> _deleteCategory(Category category) async {
    // Demander confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmation'),
            content: Text(
              'Voulez-vous vraiment supprimer la catégorie "${category.name}" ?',
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
      final categoryProvider = Provider.of<CategoryProvider>(
        context,
        listen: false,
      );
      final success = await categoryProvider.deleteCategory(category.id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catégorie supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(categoryProvider.errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Barre de recherche
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher une catégorie...',
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
            ),

            // Liste des catégories avec pagination
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _refreshList(),
                child: PagedListView<int, Category>(
                  pagingController: categoryProvider.pagingController,
                  builderDelegate: PagedChildBuilderDelegate<Category>(
                    itemBuilder: (context, category, index) {
                      // Élément de liste de catégorie avec animation d'ouverture
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
                                  CategoryDetailScreen(category: category),
                          closedBuilder: (context, openContainer) {
                            return CategoryListItem(
                              category: category,
                              onTap: openContainer,
                              onEdit: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => CategoryFormScreen(
                                          category: category,
                                        ),
                                  ),
                                );
                              },
                              onDelete: () => _deleteCategory(category),
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
                                'Erreur: ${categoryProvider.errorMessage}',
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
                            return const CategoryShimmerItem();
                          },
                        ),
                    // État sans données
                    noItemsFoundIndicatorBuilder:
                        (context) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.category_outlined,
                                color: Colors.grey,
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Aucune catégorie trouvée',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Ajoutez une nouvelle catégorie pour commencer',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (_) => const CategoryFormScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Ajouter une catégorie'),
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
}

// Widget pour l'élément de liste de catégorie
class CategoryListItem extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryListItem({
    super.key,
    required this.category,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.2),
          child: const Icon(Icons.category),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle:
            category.description != null && category.description!.isNotEmpty
                ? Text(
                  category.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
                : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }
}

// Widget pour le chargement
class CategoryShimmerItem extends StatelessWidget {
  const CategoryShimmerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Avatar placeholder
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
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
                        width: 150,
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
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Actions placeholders
              Row(
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
                  const SizedBox(width: 8),
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

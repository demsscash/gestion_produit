import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/product.dart';
import '../../../utils/theme.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          // Bouton de modification
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductFormScreen(product: product),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du produit
            Hero(
              tag: 'product_image_${product.id}',
              child: SizedBox(
                width: double.infinity,
                height: 250,
                child: CachedNetworkImage(
                  imageUrl: 'https://via.placeholder.com/500',
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                  errorWidget:
                      (context, url, error) => const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                ),
              ),
            ),

            // Informations du produit
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prix et stock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Prix
                      Text(
                        '${product.price.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),

                      // Indicateur de stock
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              product.stock > 0
                                  ? Colors.green[100]
                                  : Colors.red[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              product.stock > 0
                                  ? Icons.inventory
                                  : Icons.inventory_2_outlined,
                              size: 16,
                              color:
                                  product.stock > 0
                                      ? Colors.green[800]
                                      : Colors.red[800],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.stock > 0
                                  ? 'En stock (${product.stock})'
                                  : 'Rupture de stock',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    product.stock > 0
                                        ? Colors.green[800]
                                        : Colors.red[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description ?? 'Aucune description disponible.',
                    style: TextStyle(color: Colors.grey[700], height: 1.5),
                  ),
                  const SizedBox(height: 16),

                  // Catégories
                  const Text(
                    'Catégories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        product.categories.map((category) {
                          return Chip(
                            label: Text(category.name),
                            backgroundColor: AppTheme.accentColor.withOpacity(
                              0.2,
                            ),
                            labelStyle: const TextStyle(
                              color: AppTheme.primaryColor,
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Informations complémentaires
                  const Text(
                    'Informations complémentaires',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('ID', product.id.toString(), Icons.tag),
                  const Divider(),
                  _buildInfoRow(
                    'Créé le',
                    dateFormat.format(product.createdAt),
                    Icons.calendar_today,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    'Dernière mise à jour',
                    dateFormat.format(product.updatedAt),
                    Icons.update,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour afficher une ligne d'information
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../auth/login_screen.dart';
import 'product/product_list_screen.dart';
import 'category/category_list_screen.dart';
import 'product/product_form_screen.dart';
import 'category/category_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Liste des écrans principaux
  final List<Widget> _screens = [
    const ProductListScreen(),
    const CategoryListScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Chargement initial des données après le premier build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  // Méthode pour charger les données initiales
  Future<void> _loadInitialData() async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);

    // Recharger les données pour s'assurer qu'elles soient à jour
    await productProvider.loadProducts();
    await categoryProvider.loadCategories();
  }

  // Méthode pour changer d'écran
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Méthode pour gérer la déconnexion
  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final bool isAdmin = authProvider.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion de Produits'),
        actions: [
          // Menu utilisateur
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
              // TODO: Ajouter d'autres options utilisateur
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Utilisateur',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Paramètres'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Déconnexion'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      // Menu de navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Produits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Catégories',
          ),
        ],
      ),
      // Bouton flottant pour ajouter (visible uniquement pour les admins)
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                // Redirection vers l'écran d'ajout correspondant
                if (_selectedIndex == 0) {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                            builder: (_) => const ProductFormScreen()),
                      )
                      .then((_) => _loadInitialData());
                } else {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                            builder: (_) => const CategoryFormScreen()),
                      )
                      .then((_) => _loadInitialData());
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

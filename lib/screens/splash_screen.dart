import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Configuration de l'animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    _controller.forward();

    // Vérification de l'état d'authentification après un délai
    Future.delayed(const Duration(seconds: 2), () {
      _checkAuthStatus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Vérifier si l'utilisateur est connecté
  void _checkAuthStatus() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      // Rediriger vers l'écran principal si l'utilisateur est connecté
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      // Rediriger vers l'écran de connexion si l'utilisateur n'est pas connecté
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo avec animation
            ScaleTransition(
              scale: _animation,
              child: const Icon(
                Icons.shopping_cart,
                size: 100,
                color: Color(0xFF4361EE),
              ),
            ),
            const SizedBox(height: 24),
            // Titre de l'application avec animation
            FadeTransition(
              opacity: _controller,
              child: const Text(
                'Gestion de Produits',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 48),
            // Indicateur de chargement
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

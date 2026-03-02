import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../services/chef_provider.dart';
import '../widgets/mascot_bubble.dart';
import 'camera_screen.dart';
import 'recipes_screen.dart';
import 'cooking_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _goToCamera(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _FullCameraPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Contenido principal ─────────────────────────────────────
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Espacio para que el mascot no tape el header
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hola, Chef',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  letterSpacing: 0.3)),
                          const SizedBox(height: 2),
                          const Text('¿Qué cocinamos hoy?',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      // Espacio para el mascot
                      const SizedBox(width: 80),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Hero card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('Gemini AI',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(height: 10),
                              const Text('Escanea tu\nrefrigerador',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      height: 1.15)),
                              const SizedBox(height: 6),
                              Text('y descubre qué puedes cocinar',
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.6),
                                      fontSize: 12)),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () => _goToCamera(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 9),
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.camera_alt_rounded,
                                          color: Colors.white, size: 14),
                                      SizedBox(width: 6),
                                      Text('Escanear ahora',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text('🍳', style: TextStyle(fontSize: 64)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats
                  Row(
                    children: [
                      _StatCard(
                          value: '0',
                          label: 'Cocinadas',
                          icon: Icons.restaurant_rounded),
                      const SizedBox(width: 10),
                      _StatCard(
                          value: '0',
                          label: 'Favoritos',
                          icon: Icons.star_rounded),
                      const SizedBox(width: 10),
                      _StatCard(
                          value: '0',
                          label: 'Escaneos',
                          icon: Icons.camera_alt_rounded),
                    ],
                  ),
                  const SizedBox(height: 32),

                  const Text('Consejos',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _TipCard(
                      icon: Icons.lightbulb_rounded,
                      tip:
                          'Buena iluminación = mejores resultados al escanear'),
                  const SizedBox(height: 8),
                  _TipCard(
                      icon: Icons.eco_rounded,
                      tip: 'Gemini detecta hasta 20 ingredientes en una foto'),
                  const SizedBox(height: 8),
                  _TipCard(
                      icon: Icons.volume_up_rounded,
                      tip: 'Activa el volumen para escuchar las instrucciones'),
                  const SizedBox(height: 40),
                ],
              ),
            ),

            // ── Mascot (esquina superior derecha) ───────────────────────
            const Positioned(
              top: 12,
              right: 12,
              child: MascotBubble(
                context: MascotContext.dashboard,
                size: 68,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  const _StatCard(
      {required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        ]),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String tip;
  const _TipCard({required this.icon, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(width: 12),
        Expanded(
            child: Text(tip,
                style: const TextStyle(
                    color: Colors.white, fontSize: 13, height: 1.4))),
      ]),
    );
  }
}

class _FullCameraPage extends StatelessWidget {
  const _FullCameraPage();

  @override
  Widget build(BuildContext context) {
    return Consumer<ChefProvider>(
      builder: (context, provider, _) {
        if (provider.state == ChefState.recipesReady) {
          return RecipesScreen(onBack: () {
            provider.resetToCamera();
            Navigator.of(context).pop();
          });
        }
        if (provider.state == ChefState.cooking) {
          return const CookingScreen();
        }
        return const CameraScreen();
      },
    );
  }
}
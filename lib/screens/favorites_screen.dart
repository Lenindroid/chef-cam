import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../services/chef_provider.dart';
import '../models/recipe.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChefProvider>().cargarFavoritos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChefProvider>(
      builder: (context, provider, _) {
        final favoritos = provider.favoritos;
        final loading = provider.loadingFavoritos;

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Favoritos',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(
                            loading
                                ? 'Cargando...'
                                : '${favoritos.length} receta${favoritos.length == 1 ? '' : 's'} guardada${favoritos.length == 1 ? '' : 's'}',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: loading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary, strokeWidth: 2))
                        : favoritos.isEmpty
                            ? _EmptyState()
                            : RefreshIndicator(
                                color: AppColors.primary,
                                backgroundColor: AppColors.surface,
                                onRefresh: () =>
                                    context.read<ChefProvider>().cargarFavoritos(),
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.88,
                                  ),
                                  itemCount: favoritos.length,
                                  itemBuilder: (context, i) =>
                                      _FavoriteCard(recipe: favoritos[i]),
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18)),
            child: const Center(
                child:
                    Icon(Icons.star_rounded, color: Colors.white, size: 32)),
          ),
          const SizedBox(height: 16),
          const Text('Sin favoritos aún',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            'Toca la ⭐ en cualquier receta\ndel historial para guardarla aquí',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Recipe recipe;
  const _FavoriteCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ChefProvider>();

    return Container(
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji grande
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(14)),
                  child: Center(
                      child: Text(recipe.emoji,
                          style: const TextStyle(fontSize: 28))),
                ),
                const SizedBox(height: 10),
                Text(recipe.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const Spacer(),
                // Badges
                Row(
                  children: [
                    _SmallBadge(label: '${recipe.prepTimeMinutes}m'),
                    const SizedBox(width: 6),
                    _SmallBadge(label: recipe.difficulty),
                  ],
                ),
              ],
            ),
          ),
          // Botón quitar favorito
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _confirmarEliminar(context, provider, recipe),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.star_rounded,
                    color: AppColors.primary, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(
      BuildContext context, ChefProvider provider, Recipe recipe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('${recipe.emoji} ${recipe.title}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('¿Quitar de favoritos?',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                          color: AppColors.surface2,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                          child: Text('Cancelar',
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w600))),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      provider.eliminarFavorito(recipe);
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12)),
                      child: Center(
                          child: Text('Quitar',
                              style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w700))),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  const _SmallBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
    );
  }
}
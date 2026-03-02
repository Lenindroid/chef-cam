import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chef_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/ingredient_chip.dart';
import '../widgets/recipe_card.dart';

class RecipesScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const RecipesScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChefProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: onBack ?? provider.resetToCamera,
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Recetas encontradas',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                          Text('${provider.recipes.length} opciones disponibles',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (provider.detectedIngredients.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Ingredientes detectados',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 0.8)),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: provider.detectedIngredients.length,
                      itemBuilder: (_, i) => IngredientChip(ingredient: provider.detectedIngredients[i]),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Elige una receta',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 0.8)),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: provider.recipes.length,
                    itemBuilder: (_, i) => RecipeCard(
                      recipe: provider.recipes[i],
                      onTap: () => provider.selectRecipe(provider.recipes[i]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
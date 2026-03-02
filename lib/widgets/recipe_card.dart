import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../utils/app_colors.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  const RecipeCard({super.key, required this.recipe, required this.onTap});

  Color _diffColor(String d) {
    switch (d.toLowerCase()) {
      case 'fácil': case 'facil': return const Color(0xFF4CAF50);
      case 'medio': case 'media': return AppColors.primary;
      default: return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(recipe.emoji, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(recipe.description, style: TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(children: [
                    _Tag(Icons.timer_outlined, '${recipe.prepTimeMinutes} min'),
                    const SizedBox(width: 10),
                    _Tag(Icons.bar_chart_rounded, recipe.difficulty, color: _diffColor(recipe.difficulty)),
                    const SizedBox(width: 10),
                    _Tag(Icons.format_list_numbered_rounded, '${recipe.steps.length} pasos'),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _Tag(this.icon, this.label, {this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return Row(children: [
      Icon(icon, size: 11, color: c),
      const SizedBox(width: 3),
      Text(label, style: TextStyle(color: c, fontSize: 11)),
    ]);
  }
}
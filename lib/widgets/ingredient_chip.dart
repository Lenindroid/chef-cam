import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class IngredientChip extends StatelessWidget {
  final String ingredient;
  const IngredientChip({super.key, required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(ingredient, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}
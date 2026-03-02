import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chef_provider.dart';
import '../models/recipe.dart';
import '../utils/app_colors.dart';
import '../widgets/mascot_bubble.dart';

class CookingScreen extends StatelessWidget {
  const CookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChefProvider>(
      builder: (context, provider, _) {
        final recipe = provider.selectedRecipe;
        if (recipe == null) return const SizedBox.shrink();

        final CookingStep? step = provider.currentStepData;
        final totalSteps = recipe.steps.length;
        final currentIndex = provider.currentStep;
        final isLastStep = currentIndex >= totalSteps - 1;
        final isDone = provider.statusMessage == '¡Receta completada!';

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: provider.backToRecipes,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${recipe.emoji} ${recipe.title}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            Text('Paso ${currentIndex + 1} de $totalSteps',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                          ],
                        ),
                      ),

                      // ── Mascot en header ────────────────────────────────
                      MascotBubble(
                        context: isDone
                            ? MascotContext.done
                            : MascotContext.cooking,
                        size: 56,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (currentIndex + 1) / totalSteps,
                      backgroundColor: AppColors.surface,
                      color: AppColors.primary,
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Step content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Imagen del paso
                        if (step?.imageUrl != null)
                          Expanded(
                            flex: 2,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                child: Image.network(
                                  step!.imageUrl!,
                                  key: ValueKey('img_$currentIndex'),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (_, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      color: AppColors.surface,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                            color: AppColors.primary,
                                            strokeWidth: 2),
                                      ),
                                    );
                                  },
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.surface,
                                    child: Center(
                                      child: Icon(
                                          Icons.image_not_supported_rounded,
                                          color: AppColors.surface2,
                                          size: 32),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text('${currentIndex + 1}',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ),

                        const SizedBox(height: 12),

                        // Instrucción
                        Expanded(
                          flex: 3,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text('${currentIndex + 1}',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800)),
                                    ),
                                    if (provider.isSpeaking) ...[
                                      const SizedBox(width: 8),
                                      Icon(Icons.volume_up_rounded,
                                          color: AppColors.primary, size: 16),
                                      const SizedBox(width: 4),
                                      Text('Narrando...',
                                          style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 12)),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 12),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    step?.instruction ?? '¡Receta completada!',
                                    key: ValueKey(currentIndex),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        height: 1.6),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                if (step?.durationSeconds != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface2,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.timer_outlined,
                                            color: AppColors.primary, size: 14),
                                        const SizedBox(width: 5),
                                        Text(
                                            _formatDuration(
                                                step!.durationSeconds!),
                                            style: TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _Btn(
                            icon: Icons.skip_previous_rounded,
                            label: 'Anterior',
                            onTap: currentIndex > 0
                                ? provider.previousStep
                                : null,
                            filled: false,
                          ),
                          const SizedBox(width: 10),
                          _Btn(
                            icon: Icons.replay_rounded,
                            label: 'Repetir',
                            onTap: provider.repeatStep,
                            filled: false,
                          ),
                          const SizedBox(width: 10),
                          _Btn(
                            icon: isLastStep
                                ? Icons.check_rounded
                                : Icons.skip_next_rounded,
                            label: isLastStep ? '¡Listo!' : 'Siguiente',
                            onTap: provider.nextStep,
                            filled: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                            totalSteps,
                            (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: i == currentIndex ? 20 : 6,
                                  height: 6,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: i <= currentIndex
                                        ? AppColors.primary
                                        : AppColors.surface2,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '$seconds seg';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s > 0 ? '${m}m ${s}s' : '${m} min';
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool filled;
  const _Btn(
      {required this.icon,
      required this.label,
      this.onTap,
      required this.filled});

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: filled ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: filled
                      ? Colors.black
                      : (disabled ? AppColors.surface2 : Colors.white),
                  size: 20),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: filled
                        ? Colors.black
                        : (disabled ? AppColors.surface2 : Colors.white),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
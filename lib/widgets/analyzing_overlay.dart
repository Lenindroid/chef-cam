import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AnalyzingOverlay extends StatelessWidget {
  final String message;
  const AnalyzingOverlay({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('👨‍🍳', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 16),
              const Text('Analizando...', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(message, style: TextStyle(color: AppColors.textSecondary, fontSize: 13), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.surface2,
                  color: AppColors.primary,
                  minHeight: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
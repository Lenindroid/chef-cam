import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AuthGoogleBtn extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  const AuthGoogleBtn({super.key, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity, height: 52,
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
        child: loading
            ? Center(child: SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 22, height: 22,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    child: const Center(
                      child: Text('G', style: TextStyle(
                          color: Color(0xFF4285F4), fontSize: 13, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('Continuar con Google',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }
}

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Container(height: 1, color: AppColors.surface)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text('o continúa con email',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ),
      Expanded(child: Container(height: 1, color: AppColors.surface)),
    ]);
  }
}

class AuthLabel extends StatelessWidget {
  final String text;
  const AuthLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600));
}

class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboard;
  final IconData? prefixIcon;
  const AuthField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboard = TextInputType.text,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: AppColors.textSecondary, size: 18)
              : null,
        ),
      ),
    );
  }
}

class AuthFieldPass extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  const AuthFieldPass({
    super.key,
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 18),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppColors.textSecondary, size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class AuthPrimaryBtn extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;
  const AuthPrimaryBtn({
    super.key,
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity, height: 52,
        decoration: BoxDecoration(
          color: loading ? AppColors.surface2 : AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: loading
              ? SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
              : Text(label, style: const TextStyle(
                  color: Colors.black, fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

class AuthErrorBox extends StatelessWidget {
  final String message;
  const AuthErrorBox(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEF5350).withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, color: Color(0xFFEF5350), size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(message,
            style: const TextStyle(color: Color(0xFFEF5350), fontSize: 13))),
      ]),
    );
  }
}
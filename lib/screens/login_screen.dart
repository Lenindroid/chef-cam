import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import '../widgets/auth_widgets.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _googleLoading = false;
  String? _error;

  Future<void> _loginEmail() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Completa todos los campos');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      _goHome();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _parseError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginGoogle() async {
    setState(() { _googleLoading = true; _error = null; });
    try {
      final res = await AuthService.signInWithGoogle();
      if (res == null) { setState(() => _googleLoading = false); return; }
      if (!mounted) return;
      _goHome();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _parseError(e.toString()));
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  String _parseError(String e) {
    if (e.contains('Invalid login')) return 'Correo o contraseña incorrectos';
    if (e.contains('Email not confirmed')) return 'Confirma tu correo antes de entrar';
    if (e.contains('network')) return 'Sin conexión. Revisa tu internet';
    return 'Error al iniciar sesión';
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64),
              const Text(
                'Bienvenido\nde vuelta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Inicia sesión para continuar',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 40),

              if (_error != null) ...[
                AuthErrorBox(_error!),
                const SizedBox(height: 16),
              ],

              AuthGoogleBtn(loading: _googleLoading, onTap: _loginGoogle),
              const SizedBox(height: 20),
              const AuthDivider(),
              const SizedBox(height: 20),

              const AuthLabel('Correo electrónico'),
              const SizedBox(height: 8),
              AuthField(controller: _emailCtrl, hint: 'tu@correo.com', keyboard: TextInputType.emailAddress),
              const SizedBox(height: 16),

              const AuthLabel('Contraseña'),
              const SizedBox(height: 8),
              AuthFieldPass(
                controller: _passCtrl,
                obscure: _obscure,
                onToggle: () => setState(() => _obscure = !_obscure),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              AuthPrimaryBtn(label: 'Iniciar sesión', loading: _loading, onTap: _loginEmail),
              const SizedBox(height: 24),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: '¿No tienes cuenta? ',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      children: [
                        TextSpan(
                          text: 'Regístrate',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
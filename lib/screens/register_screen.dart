import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import '../widgets/auth_widgets.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  bool _googleLoading = false;
  String? _error;

  Future<void> _register() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'Completa todos los campos');
      return;
    }
    if (pass != confirm) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Mínimo 6 caracteres en la contraseña');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.signUpWithEmail(email, pass, name);
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
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false,
    );
  }

  String _parseError(String e) {
    if (e.contains('already registered') || e.contains('already been registered'))
      return 'Este correo ya está registrado';
    if (e.contains('invalid') && e.contains('email')) return 'Correo inválido';
    if (e.contains('network')) return 'Sin conexión. Revisa tu internet';
    return 'Error al crear la cuenta';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
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
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Crea tu\ncuenta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Únete y empieza a cocinar con IA',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 36),

              if (_error != null) ...[
                AuthErrorBox(_error!),
                const SizedBox(height: 16),
              ],

              AuthGoogleBtn(loading: _googleLoading, onTap: _loginGoogle),
              const SizedBox(height: 20),
              const AuthDivider(),
              const SizedBox(height: 20),

              const AuthLabel('Nombre'),
              const SizedBox(height: 8),
              AuthField(
                controller: _nameCtrl,
                hint: 'Tu nombre completo',
                prefixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 16),

              const AuthLabel('Correo electrónico'),
              const SizedBox(height: 8),
              AuthField(
                controller: _emailCtrl,
                hint: 'tu@correo.com',
                keyboard: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),

              const AuthLabel('Contraseña'),
              const SizedBox(height: 8),
              AuthFieldPass(
                controller: _passCtrl,
                obscure: _obscure,
                onToggle: () => setState(() => _obscure = !_obscure),
              ),
              const SizedBox(height: 16),

              const AuthLabel('Confirmar contraseña'),
              const SizedBox(height: 8),
              AuthFieldPass(
                controller: _confirmCtrl,
                obscure: _obscureConfirm,
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 28),

              AuthPrimaryBtn(label: 'Crear cuenta', loading: _loading, onTap: _register),
              const SizedBox(height: 20),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: RichText(
                    text: TextSpan(
                      text: '¿Ya tienes cuenta? ',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      children: [
                        TextSpan(
                          text: 'Inicia sesión',
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
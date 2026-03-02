import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../services/camera_service.dart';
import '../services/chef_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/scan_overlay.dart';
import '../widgets/analyzing_overlay.dart';
import '../widgets/mascot_bubble.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraService _cameraService = CameraService();
  bool _cameraReady = false;
  bool _flashOn = false;
  Timer? _errorTimer;
  String? _lastError; // para no reiniciar el timer con el mismo error

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      await _cameraService.initialize();
      if (mounted) setState(() => _cameraReady = true);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _capture() async {
    final provider = context.read<ChefProvider>();
    if (provider.state == ChefState.analyzing) return;
    final bytes = await _cameraService.captureImage();
    if (bytes != null && mounted) await provider.analyzeImage(bytes);
  }

  void _toggleFlash() {
    setState(() => _flashOn = !_flashOn);
    _cameraService.setFlash(_flashOn ? FlashMode.torch : FlashMode.off);
  }

  void _startErrorTimer(String errorKey) {
    if (_lastError == errorKey) return; // mismo error, no reiniciar
    _lastError = errorKey;
    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        context.read<ChefProvider>().clearError();
        _lastError = null;
      }
    });
  }

  void _dismissError() {
    _errorTimer?.cancel();
    _lastError = null;
    context.read<ChefProvider>().clearError();
  }

  @override
  void dispose() {
    _errorTimer?.cancel();
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChefProvider>(
      builder: (context, provider, _) {
        final isAnalyzing = provider.state == ChefState.analyzing;

        // Arrancar timer cuando aparece un error nuevo
        if (provider.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _startErrorTimer(provider.error!);
          });
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              if (_cameraReady && _cameraService.controller != null)
                CameraPreview(_cameraService.controller!)
              else
                Container(
                  color: Colors.black,
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2),
                  ),
                ),

              const ScanOverlay(),
              if (isAnalyzing)
                AnalyzingOverlay(message: provider.statusMessage),

              // ── Top: ChefCam + flash ──────────────────────────────────
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Center(
                        child: Text(
                          'ChefCam',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: _toggleFlash,
                            child: Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: _flashOn
                                    ? AppColors.primary
                                    : Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _flashOn ? Icons.flash_on : Icons.flash_off,
                                color: _flashOn ? Colors.black : Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Mascot ────────────────────────────────────────────────
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100, right: 12),
                    child: MascotBubble(
                      context: isAnalyzing
                          ? MascotContext.analyzing
                          : MascotContext.scanning,
                      size: 64,
                    ),
                  ),
                ),
              ),

              // ── Error con X y auto-dismiss 10s ────────────────────────
              if (provider.error != null)
                Positioned(
                  top: 130, left: 20, right: 20,
                  child: _ErrorBanner(
                    key: ValueKey(provider.error),
                    isYaPreparada: provider.errorEsYaPreparada,
                    nombre: provider.nombreYaPreparada,
                    mensaje: provider.errorEsYaPreparada
                        ? '¡Eso ya está listo para comer! Apunta al refri para generar recetas.'
                        : provider.error!,
                    onDismiss: _dismissError,
                  ),
                ),

              // ── Bottom ────────────────────────────────────────────────
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                  child: Column(
                    children: [
                      Text(
                        isAnalyzing
                            ? provider.statusMessage
                            : 'Apunta al refrigerador o despensa',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7), fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: isAnalyzing ? null : _capture,
                        child: Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            color: isAnalyzing
                                ? AppColors.surface2
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: isAnalyzing
                              ? Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: CircularProgressIndicator(
                                      color: AppColors.primary, strokeWidth: 2))
                              : const Icon(Icons.camera_alt_rounded,
                                  color: Colors.black, size: 30),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Banner de error con fade-in, X para cerrar
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorBanner extends StatefulWidget {
  final bool isYaPreparada;
  final String? nombre;
  final String mensaje;
  final VoidCallback onDismiss;

  const _ErrorBanner({
    super.key,
    required this.isYaPreparada,
    required this.nombre,
    required this.mensaje,
    required this.onDismiss,
  });

  @override
  State<_ErrorBanner> createState() => _ErrorBannerState();
}

class _ErrorBannerState extends State<_ErrorBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          decoration: BoxDecoration(
            color: widget.isYaPreparada
                ? const Color(0xFF1A1A2E)
                : Colors.red.shade900.withOpacity(0.93),
            borderRadius: BorderRadius.circular(14),
            border: widget.isYaPreparada
                ? Border.all(color: AppColors.primary, width: 1.5)
                : Border.all(color: Colors.white.withOpacity(0.12), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji / ícono izquierda
              Padding(
                padding: const EdgeInsets.only(top: 1, right: 10),
                child: widget.isYaPreparada
                    ? const Text('😄', style: TextStyle(fontSize: 24))
                    : const Icon(Icons.error_outline_rounded,
                        color: Colors.white, size: 22),
              ),

              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isYaPreparada && widget.nombre != null) ...[
                      Text(
                        widget.nombre!,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      widget.mensaje,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),

              // X para cerrar
              GestureDetector(
                onTap: widget.onDismiss,
                child: Container(
                  width: 28, height: 28,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

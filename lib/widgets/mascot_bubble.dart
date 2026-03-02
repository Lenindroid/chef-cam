import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Diálogos por contexto
// ─────────────────────────────────────────────────────────────────────────────
enum MascotContext {
  dashboard,
  scanning,
  analyzing,
  recipes,
  cooking,
  done,
}

const _dialogues = {
  MascotContext.dashboard: [
    '¡Hola, Chef! 👋',
    '¿Qué cocinamos hoy?',
    '¡Tengo hambre! 🍽️',
    'Escanea el refri 📸',
    '¡Seré tu sous-chef!',
    'Hoy me antoja pasta 🍝',
  ],
  MascotContext.scanning: [
    'Apunta bien 📷',
    '¡Busco ingredientes!',
    'Sin mover la mano...',
    'Busca buena luz 💡',
    '¡Veo algo rico!',
  ],
  MascotContext.analyzing: [
    'Analizando... 🔍',
    '¡Casi listo!',
    'Hay mucho aquí 👀',
    'Calculando recetas...',
    '¡Interesante! 🤔',
  ],
  MascotContext.recipes: [
    '¡Elige bien! 😄',
    'Todas se ven ricas 🤤',
    '¡Yo haría la primera!',
    '¿Cuál se antoja más?',
    '¡Vamos a cocinar!',
  ],
  MascotContext.cooking: [
    '¡Sigue así, Chef! 💪',
    '¡Huele delicioso! 👃',
    '¡Vas muy bien!',
    'Con calma y amor 🍳',
    '¡Casi terminamos!',
    '¡Tú puedes! ✨',
  ],
  MascotContext.done: [
    '¡Excelente, Chef! 🎉',
    '¡Buen provecho! 🍽️',
    '¡Lo lograste! 🏆',
    '¡Eres un crack! 👨‍🍳',
  ],
};

// ─────────────────────────────────────────────────────────────────────────────
// Widget principal
// ─────────────────────────────────────────────────────────────────────────────
class MascotBubble extends StatefulWidget {
  final MascotContext context;

  /// Si se pasa un mensaje fijo, no rota automáticamente.
  final String? fixedMessage;

  /// Tamaño del lobo (default 72).
  final double size;

  const MascotBubble({
    super.key,
    required this.context,
    this.fixedMessage,
    this.size = 72,
  });

  @override
  State<MascotBubble> createState() => _MascotBubbleState();
}

class _MascotBubbleState extends State<MascotBubble>
    with TickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late AnimationController _bubbleCtrl;
  late Animation<double> _floatAnim;
  late Animation<double> _bubbleFade;
  late Animation<double> _bubbleScale;

  late List<String> _messages;
  int _msgIndex = 0;
  String _currentMsg = '';
  Timer? _rotateTimer;

  @override
  void initState() {
    super.initState();

    _messages = widget.fixedMessage != null
        ? [widget.fixedMessage!]
        : List<String>.from(
            _dialogues[widget.context] ?? _dialogues[MascotContext.dashboard]!);
    // Shuffle para variedad
    _messages.shuffle(Random());
    _currentMsg = _messages[0];

    // Animación de flotado continuo
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    // Animación de entrada/salida del bubble
    _bubbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _bubbleFade = CurvedAnimation(parent: _bubbleCtrl, curve: Curves.easeOut);
    _bubbleScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _bubbleCtrl, curve: Curves.elasticOut),
    );

    _bubbleCtrl.forward();

    // Rotar mensajes cada 4 segundos si no hay mensaje fijo
    if (widget.fixedMessage == null) {
      _rotateTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        _nextMessage();
      });
    }
  }

  Future<void> _nextMessage() async {
    await _bubbleCtrl.reverse();
    if (!mounted) return;
    setState(() {
      _msgIndex = (_msgIndex + 1) % _messages.length;
      _currentMsg = _messages[_msgIndex];
    });
    _bubbleCtrl.forward();
  }

  @override
  void didUpdateWidget(MascotBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.context != widget.context ||
        oldWidget.fixedMessage != widget.fixedMessage) {
      _rotateTimer?.cancel();
      _messages = widget.fixedMessage != null
          ? [widget.fixedMessage!]
          : List<String>.from(
              _dialogues[widget.context] ??
                  _dialogues[MascotContext.dashboard]!);
      _messages.shuffle(Random());
      _msgIndex = 0;
      _currentMsg = _messages[0];
      _bubbleCtrl.forward(from: 0);

      if (widget.fixedMessage == null) {
        _rotateTimer = Timer.periodic(const Duration(seconds: 4), (_) {
          _nextMessage();
        });
      }
    }
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _bubbleCtrl.dispose();
    _rotateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatCtrl,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _floatAnim.value),
        child: child,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Nube de diálogo ──────────────────────────────────────────────
          FadeTransition(
            opacity: _bubbleFade,
            child: ScaleTransition(
              scale: _bubbleScale,
              alignment: Alignment.centerRight,
              child: _SpeechBubble(message: _currentMsg),
            ),
          ),
          const SizedBox(width: 6),

          // ── Lobo ─────────────────────────────────────────────────────────
          GestureDetector(
            onTap: _nextMessage, // Tap para cambiar mensaje
            child: Image.asset(
              'assets/images/chef_wolf.gif',
              width: widget.size,
              height: widget.size,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nube de diálogo con cola apuntando a la derecha
// ─────────────────────────────────────────────────────────────────────────────
class _SpeechBubble extends StatelessWidget {
  final String message;
  const _SpeechBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BubblePainter(),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 160, minWidth: 80),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        margin: const EdgeInsets.only(right: 10), // espacio para la cola
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    const radius = Radius.circular(12);
    const tailW = 10.0;
    const tailH = 10.0;
    // Cola en el lado derecho, apuntando al lobo
    final bubbleRect = RRect.fromLTRBR(
      0, 0, size.width - tailW, size.height, radius);

    // Sombra
    canvas.drawRRect(bubbleRect, shadowPaint);
    // Bubble blanco
    canvas.drawRRect(bubbleRect, paint);

    // Cola triangular derecha
    final tailPath = Path()
      ..moveTo(size.width - tailW, size.height * 0.65)
      ..lineTo(size.width, size.height * 0.82)
      ..lineTo(size.width - tailW, size.height * 0.82 + tailH * 0.3)
      ..close();
    canvas.drawPath(tailPath, paint);
  }

  @override
  bool shouldRepaint(_BubblePainter old) => false;
}
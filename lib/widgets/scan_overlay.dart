import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ScanOverlay extends StatefulWidget {
  const ScanOverlay({super.key});

  @override
  State<ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<ScanOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final boxSize = size.width * 0.72;
    final boxTop = (size.height - boxSize) * 0.38;
    final boxLeft = (size.width - boxSize) / 2;

    return Stack(
      children: [
        // Dark overlay with cutout
        CustomPaint(
          size: Size(size.width, size.height),
          painter: _OverlayPainter(Rect.fromLTWH(boxLeft, boxTop, boxSize, boxSize)),
        ),
        // Scanning line
        Positioned(
          left: boxLeft, top: boxTop,
          child: SizedBox(
            width: boxSize, height: boxSize,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => CustomPaint(painter: _LinePainter(_ctrl.value, AppColors.primary)),
            ),
          ),
        ),
        // Corner brackets
        Positioned(
          left: boxLeft, top: boxTop,
          child: SizedBox(
            width: boxSize, height: boxSize,
            child: CustomPaint(painter: _CornerPainter(AppColors.primary)),
          ),
        ),
        // Label
        Positioned(
          left: 0, right: 0, top: boxTop + boxSize + 14,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('Encuadra los ingredientes',
                  style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ),
        ),
      ],
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final Rect box;
  _OverlayPainter(this.box);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.5);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(box, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _LinePainter extends CustomPainter {
  final double progress;
  final Color color;
  _LinePainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final y = progress * size.height;
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.progress != progress;
}

class _CornerPainter extends CustomPainter {
  final Color color;
  _CornerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const len = 20.0;
    final paint = Paint()..color = color..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.square;
    // TL
    canvas.drawLine(Offset.zero, const Offset(len, 0), paint);
    canvas.drawLine(Offset.zero, const Offset(0, len), paint);
    // TR
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - len, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);
    // BL
    canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - len), paint);
    // BR
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - len, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - len), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
import 'dart:ui' as ui;
import 'package:audify_v3/widgets/wave_path.dart';
import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color? dotColor;
  final double? dotRadius;
  final double? borderRadius;
  final double? borderWidth;
  final Color secondaryColor;

  WavePainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
    this.dotColor = Colors.white,
    this.dotRadius = 7,
    this.borderRadius = 7,
    this.borderWidth = 2,
  });

  Offset cubicBezier(double t, Offset p0, Offset p1, Offset p2, Offset p3) {
    final u = 1 - t;
    return Offset(
      u * u * u * p0.dx +
          3 * u * u * t * p1.dx +
          3 * u * t * t * p2.dx +
          t * t * t * p3.dx,
      u * u * u * p0.dy +
          3 * u * u * t * p1.dy +
          3 * u * t * t * p2.dy +
          t * t * t * p3.dy,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double midHeight = size.height / 2;
    final double width = size.width;

    // 1. Definir el camino de la onda (Path)
    final path = buildWavePath(size);

    // 2. Dibujar fondo de la barra (Gris muy suave)
    final backgroundPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, backgroundPaint);

    // 3. Dibujar la parte activa con DEGRADADO
    // final rect = Rect.fromLTWH(0, 0, width * progress, size.height);
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.linear(
        Offset(0, midHeight),
        Offset(width * progress, midHeight),
        [
          primaryColor.withValues(alpha: 0.3), // Inicia invisible
          primaryColor.withValues(alpha: 0.6), // Pasa a medio tono
          primaryColor, // Termina en el color sólido solicitado
        ],
        [0.0, 0.5, 1.0],
      );

    // Cortamos para que solo se pinte hasta el progreso actual
    canvas.save();
    final metric = path.computeMetrics().first;
    final progressPath = metric.extractPath(0, metric.length * progress);
    canvas.clipRect(Rect.fromLTWH(0, 0, width * progress, size.height));
    canvas.drawPath(progressPath, progressPaint);
    canvas.restore();

    final tangent = metric.getTangentForOffset(metric.length * progress);

    if (tangent == null) return;

    final center = tangent.position;

    // Sombra/Brillo del punto
    final shadowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center, 10, shadowPaint);

    // Punto sólido
    final circlePaint = Paint()..color = dotColor!;
    canvas.drawCircle(center, dotRadius!, circlePaint);

    // Pequeño borde blanco para que resalte
    final borderPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, borderRadius!, borderPaint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

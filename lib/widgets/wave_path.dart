import 'dart:ui';

Path buildWavePath(Size size) {
  final mid = size.height / 2;
  final w = size.width;

  return Path()
    ..moveTo(0, mid)
    ..cubicTo(w * 0.1, mid - 25, w * 0.1, mid + 20, w * 0.25, mid)
    ..cubicTo(w * 0.45, mid - 30, w * 0.45, mid + 25, w * 0.65, mid)
    ..cubicTo(w * 0.85, mid - 32, w * 0.85, mid + 27, w, mid);
}

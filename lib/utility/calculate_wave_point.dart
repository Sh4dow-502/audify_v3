import 'dart:ui';

import 'package:audify_v3/widgets/wave_path.dart';

Offset calculateWavePoint(Size size, double progress) {
  final path = buildWavePath(size);
  final metric = path.computeMetrics().first;

  final tangent = metric.getTangentForOffset(
    metric.length * progress.clamp(0.0, 1.0),
  );

  return tangent?.position ?? Offset.zero;
}

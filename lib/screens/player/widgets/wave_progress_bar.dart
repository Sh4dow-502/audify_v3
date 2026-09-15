// import 'package:audify_v3/screens/media_screen/utils/calcuate_wave_point.dart';
import 'package:audify_v3/theme/custom_colors.dart';
import 'package:audify_v3/utility/calculate_wave_point.dart';
import 'package:audify_v3/widgets/wave_painter.dart';
import 'package:flutter/material.dart';

// import 'package:audify/screens/media_screen/utils/wave_painter.dart';
// import 'package:audify/theme/custom_colors.dart';

class WaveProgressBar extends StatefulWidget {
  final double progress;
  final Duration duration;
  final Future<void> Function(Duration position) onSeek;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final Color? primaryColor;
  final Color? secondaryColor;
  final double? height;

  const WaveProgressBar({
    super.key,
    required this.progress,
    required this.duration,
    required this.onSeek,
    this.onChanged,
    this.onChangeEnd,
    this.primaryColor = CustomColors.purple,
    this.secondaryColor,
    this.height = 30,
  });

  @override
  State<WaveProgressBar> createState() => _WaveProgressBarState();
}

class _WaveProgressBarState extends State<WaveProgressBar> {
  bool _isDragging = false;
  double _dragProgress = 0.0;
  double? _lockedProgress;
  // double? _lastVisualProgress;

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _effectiveProgress {
    if (_isDragging) return _dragProgress;
    if (_lockedProgress != null) return _lockedProgress!;
    return widget.progress;
  }

  void _updateDrag(Offset localPosition, double width) {
    final dx = localPosition.dx.clamp(0.0, width);
    final newProgress = dx / width;

    setState(() {
      _isDragging = true;
      _dragProgress = newProgress;
    });

    //  feedback continuo
    widget.onChanged?.call(newProgress);
  }

  Future<void> _endDrag() async {
    final target = _dragProgress;

    setState(() {
      _isDragging = false;
      _lockedProgress = target; // mantenemos la posición visual
    });

    widget.onChangeEnd?.call(target);

    final newPosition = widget.duration * target;
    await widget.onSeek(newPosition);
  }

  @override
  void didUpdateWidget(covariant WaveProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_lockedProgress != null) {
      final diff = (widget.progress - _lockedProgress!).abs();
      if (diff < 0.005) {
        setState(() {
          _lockedProgress = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, widget.height!);
        final point = calculateWavePoint(size, _effectiveProgress);

        final dragDuration = widget.duration * _effectiveProgress;

        return SizedBox(
          height: widget.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (d) => _updateDrag(d.localPosition, size.width),
                onPanStart: (d) {
                  _updateDrag(d.localPosition, size.width);
                },
                onPanEnd: (_) => _endDrag(),
                child: CustomPaint(
                  size: size,
                  painter: WavePainter(
                    primaryColor: widget.primaryColor!,
                    secondaryColor:
                        widget.secondaryColor ??
                        widget.primaryColor!.withValues(alpha: 0.11),
                    progress: _effectiveProgress,
                  ),
                ),
              ),

              // Label siguiendo el punto
              if (_isDragging)
                Positioned(
                  left: point.dx - 22,
                  top: point.dy - 45,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _format(dragDuration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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

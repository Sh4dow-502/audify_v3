import 'package:audify_v3/theme/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gradient_slider/gradient_slider.dart';

class CustomGradientSlider extends StatelessWidget {
  const CustomGradientSlider({
    super.key,
    required this.gradientColors,
    required this.value,
    required this.varCond,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.label,
    this.onChanged,
    this.dotColor = Colors.white,
    this.trackHeight = 3,
  });

  final List<Color> gradientColors;
  final double value;
  final double min;
  final double max;
  final double varCond;
  final int? divisions;
  final String? label;
  final Function(double)? onChanged;
  final Color dotColor;
  final double? trackHeight;

  @override
  Widget build(BuildContext context) {
    // final colors = Theme.of(context).colorScheme;
    final colors = context.theme.colors;
    return SliderTheme(
      data: SliderThemeData(
        disabledInactiveTrackColor: colors.secondary,
        // disabledInactiveTrackColor: colors.tertiaryContainer,
        thumbColor: CustomColors.lightPurple,
        thumbShape: _CustomThumbShape(
          radius: 10,
          fillColor: colors.background,
          borderColor: varCond > 0 ? colors.border : colors.mutedForeground,
          borderWidth: 2,
          innerDotColor: onChanged != null ? dotColor : colors.mutedForeground,
          innerDotRadius: 2,
        ),
        trackShape: onChanged != null
            ? GradientSliderTrackShape(
                activeTrackGradient: LinearGradient(
                  colors: varCond > 0
                      ? gradientColors
                      : [colors.secondary, colors.secondary],
                ),
              )
            : null,
        trackHeight: trackHeight,
        inactiveTrackColor: colors.secondary,
        activeTrackColor: varCond > 0 ? CustomColors.purple : colors.secondary,
        rangeThumbShape: RoundRangeSliderThumbShape(enabledThumbRadius: 12),
        valueIndicatorColor: colors.foreground,
        valueIndicatorTextStyle: TextStyle(color: colors.background),
        tickMarkShape: SliderTickMarkShape.noTickMark,
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        onChanged: onChanged,
      ),
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  final double radius; // radio total de la bolita
  final Color borderColor;
  final double borderWidth;
  final Color fillColor;
  final Color innerDotColor;
  final double innerDotRadius;

  const _CustomThumbShape({
    this.radius = 12,
    this.borderColor = Colors.grey,
    this.borderWidth = 2,
    this.fillColor = Colors.blue,
    this.innerDotColor = Colors.white,
    this.innerDotRadius = 4,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(radius + borderWidth);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // 1️⃣ Círculo de relleno (alrededor del puntito)
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fillPaint);

    // 2️⃣ Borde exterior
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawCircle(center, radius, borderPaint);

    // 3️⃣ Puntito en el centro
    final dotPaint = Paint()
      ..color = innerDotColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerDotRadius, dotPaint);
  }
}

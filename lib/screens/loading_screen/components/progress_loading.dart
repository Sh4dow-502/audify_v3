import 'package:audify_v3/providers/loading_provider.dart';
import 'package:audify_v3/theme/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import 'package:step_progress/step_progress.dart';

class ProgressLoading extends StatelessWidget {
  const ProgressLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final step = context.select<LoadingProvider, int>(
      (provider) => provider.step,
    );

    return Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: StepProgress(
          totalSteps: 3,
          stepNodeSize: 15,
          currentStep: step,
          lineTitles: const ["Descarga", "Carga"],
          theme: StepProgressThemeData(
            rippleEffectStyle: RippleEffectStyle(
              animationDuration: Duration(milliseconds: 400),
            ),
            stepAnimationDuration: Duration(milliseconds: 400),
            activeForegroundColor: colors.primary.withValues(alpha: 0.8),
            lineLabelStyle: StepLabelStyle(
              margin: EdgeInsets.only(bottom: 6),
              // textStyle: context.theme.textStyles.bodySmall,
            ),
            // shape: StepNodeShape.square,
            shape: StepNodeShape.heptagon,
            stepLineSpacing: 10,
            stepLineStyle: StepLineStyle(borderRadius: Radius.circular(4)),
            nodeLabelStyle: StepLabelStyle(margin: EdgeInsets.only(bottom: 6)),
            stepNodeStyle: StepNodeStyle(
              activeForegroundColor: CustomColors.purple,
              defaultForegroundColor: colors.foreground,
              // activeIcon: Icon(Icons.check, color: Colors.white, size: 12),
              activeIcon: null,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

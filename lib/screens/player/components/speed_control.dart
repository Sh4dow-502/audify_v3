import 'package:audify_v3/providers/controls_provider.dart';
import 'package:audify_v3/screens/player/widgets/custom_gradient_slider.dart';
import 'package:audify_v3/theme/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';

class SpeedControl extends StatelessWidget {
  const SpeedControl({super.key});

  @override
  Widget build(BuildContext context) {
    final globalSpeed = context.watch<ControlsProvider>().globalSpeed;
    final speedOptions = context.watch<ControlsProvider>().speedOptions;
    return FPopover(
      popoverAnchor: .bottomCenter,
      childAnchor: .topCenter,
      popoverBuilder: (context, _) => Padding(
        padding: .all(10),
        child: Column(
          children: [
            Wrap(
              children: [
                ...speedOptions.map(
                  (speed) => FButton(
                    onPress: () {
                      context.read<ControlsProvider>().setGlobalSpeed(speed);
                    },
                    variant: .secondary,
                    size: .xs,
                    child: Text("${speed}x"),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                FButton.icon(
                  onPress: () {
                    context.read<ControlsProvider>().setGlobalSpeed(
                      globalSpeed - 0.05,
                    );
                  },
                  child: Icon(FLucideIcons.minus),
                ),
                Material(
                  color: Colors.transparent,
                  child: CustomGradientSlider(
                    min: 0.5,
                    max: 1.5,
                    gradientColors: [
                      CustomColors.lightOrange,
                      CustomColors.lightOrange,
                    ],
                    value: globalSpeed,
                    divisions: 20,
                    varCond: 1,
                    onChanged: (value) {
                      context.read<ControlsProvider>().setGlobalSpeed(value);
                    },
                  ),
                ),
                FButton.icon(
                  onPress: () {
                    context.read<ControlsProvider>().setGlobalSpeed(
                      globalSpeed + 0.05,
                    );
                  },
                  child: Icon(FLucideIcons.plus),
                ),
              ],
            ),
          ],
        ),
      ),
      builder: (_, controller, _) => FButton(
        onPress: controller.toggle,
        size: .sm,
        variant: .outline,
        child: Text("${globalSpeed}x", style: context.theme.typography.body.xs),
      ),
    );
  }
}

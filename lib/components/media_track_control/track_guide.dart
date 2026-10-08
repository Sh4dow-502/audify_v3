import 'package:audify_v3/providers/tracks_provider.dart';
import 'package:audify_v3/screens/player/widgets/custom_gradient_slider.dart';
import 'package:audify_v3/theme/custom_colors.dart';
import 'package:audify_v3/utility/get_track_icon.dart';
import 'package:audify_v3/utility/get_track_name.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

class TrackGuide extends StatelessWidget {
  const TrackGuide({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final provider = context.read<TracksProvider>();
    final guideVolume = context.watch<TracksProvider>().voicesVolume;
    final guideMuted = context.watch<TracksProvider>().voicesMuted;

    final iconForVolume = guideVolume > 0.5
        ? HugeIcons.strokeRoundedVolumeHigh
        : guideVolume > 0.3
        ? HugeIcons.strokeRoundedVolumeLow
        : guideVolume > 0.01
        ? HugeIcons.strokeRoundedVolumeMute01
        : HugeIcons.strokeRoundedVolumeMute02;

    final varCond = guideMuted ? 0.0 : 1.0;
    final track = getTrackName('guide');
    final textStyles = context.theme.typography.body;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 0,
      children: [
        FTooltip(
          tipBuilder: (context, _) => Text(track),
          child: Icon(
            getTrackIcon('guide'),
            color: guideMuted ? colors.mutedForeground : colors.foreground,

            size: 18,
          ),
        ),

        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          track,
                          style: textStyles.xs.copyWith(
                            fontWeight: .w700,
                            color: guideMuted
                                ? colors.mutedForeground
                                : colors.foreground,
                            height: 0.1,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "${(guideVolume * 100).toInt()}%",
                      style: textStyles.xs2.copyWith(
                        color: context.theme.colors.mutedForeground,
                        height: 0.1,
                      ),
                    ),
                  ],
                ),
              ),

              Material(
                color: Colors.transparent,
                borderOnForeground: false,
                child: CustomGradientSlider(
                  // gradientColors: [color, color],
                  gradientColors: [
                    CustomColors.lightOrange,
                    CustomColors.lightOrange,
                  ],
                  dotColor: CustomColors.lightOrange,
                  // value: trackState.volume.clamp(0.0, 1.0),
                  value: guideVolume.clamp(0.0, 2.0),
                  max: 2.0,
                  min: 0.0,
                  varCond: varCond,
                  divisions: 100,
                  trackHeight: 2,
                  // label: "${(trackState.volume * 100).toInt()}%",
                  onChanged: (value) {
                    provider.setVoicesVolume(value.clamp(0.0, 2.0));
                    // provider.setTrackVolume(
                    //   'metronome',
                    //   value.clamp(0.0, 1.0),
                    // );
                  },
                ),
              ),
            ],
          ),
        ),
        FButton.icon(
          onPress: () {
            provider.toggleMuteVoices();
          },
          child: HugeIcon(
            icon: guideMuted ? HugeIcons.strokeRoundedVolumeOff : iconForVolume,
            size: 18,
          ),
          // child: Icon(FLucideIcons.volume2),
        ),
      ],
    );
  }
}

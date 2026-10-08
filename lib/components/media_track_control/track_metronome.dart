import 'package:audify_v3/models/track_state.dart';
import 'package:audify_v3/providers/tracks_provider.dart';
import 'package:audify_v3/screens/player/widgets/custom_gradient_slider.dart';
import 'package:audify_v3/theme/custom_colors.dart';
import 'package:audify_v3/utility/get_track_icon.dart';
import 'package:audify_v3/utility/get_track_name.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart' show HugeIcons, HugeIcon;
import 'package:provider/provider.dart';

class TrackMetronome extends StatelessWidget {
  final int bpm;
  const TrackMetronome({super.key, required this.bpm});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final provider = context.read<TracksProvider>();
    final trackState = context.select<TracksProvider, TrackState>(
      (provider) => provider.getTrackState('metronome'),
    );

    final iconForVolume = trackState.volume > 0.5
        ? HugeIcons.strokeRoundedVolumeHigh
        : trackState.volume > 0.3
        ? HugeIcons.strokeRoundedVolumeLow
        : trackState.volume > 0.01
        ? HugeIcons.strokeRoundedVolumeMute01
        : HugeIcons.strokeRoundedVolumeMute02;

    final varCond = trackState.isMuted ? 0.0 : 1.0;
    final track = getTrackName('metronome');
    final textStyles = context.theme.typography.body;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 0,
      children: [
        FTooltip(
          tipBuilder: (context, _) => Text(getTrackName('metronome')),
          child: Icon(
            getTrackIcon('metronome'),
            color: trackState.isMuted
                ? colors.mutedForeground
                : colors.foreground,

            size: 18,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 0,
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
                            color: trackState.isMuted
                                ? colors.mutedForeground
                                : colors.foreground,
                            height: 0.1,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          " ($bpm BPM)",
                          style: textStyles.xs.copyWith(
                            fontWeight: .w500,
                            color: trackState.isMuted
                                ? colors.mutedForeground
                                : colors.foreground,
                            height: 0.1,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "${(trackState.volume * 100).toInt()}%",
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
                    CustomColors.lightPurple,
                    CustomColors.lightPurple,
                  ],
                  dotColor: CustomColors.lightPurple,
                  value: trackState.volume.clamp(0.0, 2.0),
                  max: 2.0,
                  min: 0.0,
                  varCond: varCond,
                  divisions: 100,
                  trackHeight: 2,
                  // label: "${(trackState.volume * 100).toInt()}%",
                  onChanged: (value) {
                    provider.setTrackVolume('metronome', value.clamp(0.0, 2.0));
                  },
                ),
              ),
              // Material(
              //   color: Colors.transparent,
              //   borderOnForeground: false,
              //   child: CustomGradientSlider(
              //     // gradientColors: [color, color],
              //     gradientColors: [
              //       CustomColors.lightPurple,
              //       CustomColors.lightPurple,
              //     ],
              //     dotColor: CustomColors.lightPurple,
              //     value: trackState.volume,
              //     max: 1.0,
              //     min: 0.0,
              //     varCond: varCond,
              //     divisions: 100,
              //     trackHeight: 2,
              //     // label: "${(trackState.volume * 100).toInt()}%",
              //     onChanged: (value) {
              //       provider.setTrackVolume('metronome', value.clamp(0.0, 1.0));
              //     },
              //   ),
              // ),
            ],
          ),
        ),

        FButton.icon(
          onPress: () {
            provider.toggleMuteTrack('metronome');
          },
          child: HugeIcon(
            icon: trackState.isMuted
                ? HugeIcons.strokeRoundedVolumeOff
                : iconForVolume,
            size: 18,
          ),
          // child: Icon(FLucideIcons.volume2),
        ),
      ],
    );
  }
}

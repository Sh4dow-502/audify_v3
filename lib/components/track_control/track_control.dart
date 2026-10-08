import 'package:audify_v3/models/track_state.dart';
import 'package:audify_v3/providers/tracks_provider.dart';
import 'package:audify_v3/screens/player/widgets/custom_gradient_slider.dart';
import 'package:audify_v3/theme/custom_colors.dart';
import 'package:audify_v3/utility/get_track_icon.dart';
import 'package:audify_v3/utility/get_track_name.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

class TrackControl extends StatelessWidget {
  final String trackName;
  const TrackControl({super.key, required this.trackName});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final provider = context.read<TracksProvider>();
    final trackState = context.select<TracksProvider, TrackState>(
      (provider) => provider.getTrackState(trackName),
    );

    final iconForVolume = trackState.volume > 0.5
        ? HugeIcons.strokeRoundedVolumeHigh
        : trackState.volume > 0.3
        ? HugeIcons.strokeRoundedVolumeLow
        : trackState.volume > 0.01
        ? HugeIcons.strokeRoundedVolumeMute01
        : HugeIcons.strokeRoundedVolumeMute02;

    final varCond = trackState.isMuted ? 0.0 : 1.0;
    final track = getTrackName(trackName);
    final textStyles = context.theme.typography.body;
    // final color = getTrackColor(trackName);
    final color = context.theme.colors.primary;
    // final colorDegradado = context.theme.colors.secondary;
    final colorDegradado = color.withValues(alpha: 0.7);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 0,
      children: [
        FTooltip(
          tipBuilder: (context, _) => Text(getTrackName(trackName)),
          child: Icon(
            getTrackIcon(trackName),
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
                  gradientColors: trackName == "metronome"
                      ? [CustomColors.lightPurple, CustomColors.lightPurple]
                      : [colorDegradado, color],
                  dotColor: trackName == "metronome"
                      ? CustomColors.celeste
                      : colors.primary,
                  value: trackState.volume.clamp(0.0, 2.0),
                  max: 2.0,
                  min: 0.0,
                  varCond: varCond,
                  divisions: 100,
                  trackHeight: 2,
                  // label: "${(trackState.volume * 100).toInt()}%",
                  onChanged: (value) {
                    provider.setTrackVolume(trackName, value.clamp(0.0, 2.0));
                  },
                ),
              ),
            ],
          ),
        ),
        FButton.icon(
          onPress: () {
            provider.toggleMuteTrack(trackName);
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

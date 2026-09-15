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

    return Column(
      crossAxisAlignment: .start,
      children: [
        // Text(
        //   getTrackName(trackName),
        //   style: context.theme.typography.body.xs.copyWith(
        //     color: context.theme.colors.mutedForeground,
        //   ),
        // ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FTooltip(
              tipBuilder: (context, _) => Text(getTrackName(trackName)),
              child: Icon(
                getTrackIcon(trackName),
                color: trackState.isMuted
                    ? colors.mutedForeground
                    : colors.foreground,
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: CustomGradientSlider(
                      gradientColors: trackName == "metronome"
                          ? [CustomColors.lightPurple, CustomColors.celeste]
                          : [CustomColors.lightPurple, CustomColors.purple],
                      dotColor: trackName == "metronome"
                          ? CustomColors.celeste
                          : colors.primary,
                      value: trackState.volume,
                      max: 1.0,
                      min: 0.0,
                      varCond: varCond,
                      divisions: 100,
                      trackHeight: 2,
                      label: "${(trackState.volume * 100).toInt()}%",
                      onChanged: (value) {
                        provider.setTrackVolume(
                          trackName,
                          value.clamp(0.0, 1.0),
                        );
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
        ),
      ],
    );
  }
}

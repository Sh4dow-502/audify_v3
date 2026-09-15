import 'package:audify_v3/models/song_entity.dart';
import 'package:audify_v3/providers/audio_provider.dart';
import 'package:audify_v3/screens/player/components/metronome_button.dart';
import 'package:audify_v3/screens/player/components/speed_control.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

class PlayerControl extends StatelessWidget {
  final SongEntity song;
  const PlayerControl({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final provider = context.read<AudioProvider>();
    final isPlaying = context.watch<AudioProvider>().isPlaying;
    final hasReward = context.watch<AudioProvider>().hasReward;
    final hasForward = context.watch<AudioProvider>().hasForward;
    final isFinished = context.watch<AudioProvider>().isFinished;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // spacing: 20,
        children: [
          // const SizedBox(width: 3),
          MetronomeButton(song: song),
          // const SizedBox(width: 5),
          Row(
            children: [
              FButton.icon(
                onPress: hasReward ? () => provider.seekRelative(-5) : null,
                variant: .ghost,
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedBackward02,
                    size: 27,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FButton.icon(
                onPress: () => isFinished
                    ? provider.restart()
                    : provider.togglePlayPause(),
                variant: FButtonVariant.primary,
                style: .delta(
                  decoration: FVariants.all(
                    BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primary,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: HugeIcon(
                    icon: isFinished
                        ? HugeIcons.strokeRoundedReplay
                        : isPlaying
                        ? HugeIcons.strokeRoundedPause
                        : HugeIcons.strokeRoundedPlay,
                    size: 35,
                    color: context.theme.colors.foreground,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FButton.icon(
                onPress: hasForward ? () => provider.seekRelative(5) : null,
                variant: .ghost,
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedForward02,
                    size: 27,
                  ),
                ),
              ),
            ],
          ),
          SpeedControl(),
          // const SizedBox(width: 3),
        ],
      ),
    );
  }
}

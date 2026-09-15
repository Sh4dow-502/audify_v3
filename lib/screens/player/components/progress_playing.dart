import 'package:audify_v3/providers/audio_provider.dart';
import 'package:audify_v3/screens/player/widgets/wave_progress_bar.dart';
import 'package:audify_v3/utility/format_duration.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';

class ProgressPlaying extends StatelessWidget {
  final bool showTime;
  const ProgressPlaying({super.key, this.showTime = true});

  @override
  Widget build(BuildContext context) {
    final textStyles = context.theme.typography.body;
    final currentPos = context.watch<AudioProvider>().currentPosition;
    final totalDur = context.watch<AudioProvider>().totalDuration;

    final double progressPercent = totalDur.inMicroseconds > 0
        ? (currentPos.inMilliseconds / totalDur.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        spacing: 0,
        mainAxisSize: .min,
        children: [
          WaveProgressBar(
            progress: progressPercent,
            duration: totalDur,
            secondaryColor: context.theme.colors.secondary,
            onSeek: (newPosition) async {
              context.read<AudioProvider>().seekAll(newPosition);
            },
          ),
          if (showTime)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: .start,
              children: [
                Text(
                  formatDurationV2(currentPos.inSeconds),
                  // "1:00",
                  style: textStyles.xs.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
                Text(
                  formatDurationV2(totalDur.inSeconds),
                  style: textStyles.xs.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

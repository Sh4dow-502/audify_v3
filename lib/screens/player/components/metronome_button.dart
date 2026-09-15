import 'package:audify_v3/models/song_entity.dart';
import 'package:audify_v3/providers/controls_provider.dart';
import 'package:audify_v3/screens/player/components/metronome_control.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';

class MetronomeButton extends StatelessWidget {
  final SongEntity song;
  const MetronomeButton({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final activeMetronome = context.watch<ControlsProvider>().activeMetronome;
    final colors = context.theme.colors;
    final colorMetronome = activeMetronome ? colors.primary : colors.secondary;
    return GestureDetector(
      onTap: () {
        showFSheet(
          context: context,
          builder: (context) => MetronomeControl(song: song),
          side: .btt,
        );
        // context.read<ControlsProvider>().toggleMetronome();
      },
      child: !activeMetronome
          ? _DisableMetronome()
          : Container(
              decoration: BoxDecoration(
                borderRadius: FBorderRadius().lg,
                border: .all(color: colorMetronome.withValues(alpha: 0.8)),
                color: colorMetronome.withValues(alpha: 0.25),
              ),
              padding: .all(10),
              child: Icon(
                FLucideIcons.metronome,
                color: colorMetronome,
                size: 20,
              ),
            ),
    );
  }
}

class _DisableMetronome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Container(
      decoration: BoxDecoration(
        borderRadius: FBorderRadius().lg,
        border: .all(color: colors.border),
        color: colors.secondary,
      ),
      padding: .all(10),
      child: Icon(
        FLucideIcons.metronome,
        color: colors.mutedForeground.withValues(alpha: 0.8),
      ),
    );
  }
}

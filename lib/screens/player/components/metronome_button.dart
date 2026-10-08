import 'package:audify_v3/models/song_entity.dart';
import 'package:audify_v3/providers/controls_provider.dart';
import 'package:audify_v3/screens/structure_screen/structure_screen.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StructureScreen(song: song)),
        );
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
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedStraightEdge,
                size: 20,
                color: colorMetronome,
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

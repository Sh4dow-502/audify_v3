import 'package:audify_v3/models/song_entity.dart';
import 'package:audify_v3/providers/audio_provider.dart';
import 'package:audify_v3/providers/song_provider.dart';
import 'package:audify_v3/theme/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

class SongSettings extends StatelessWidget {
  final SongEntity song;
  const SongSettings({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final textStyles = context.theme.typography.body;
    final automaticRepay = context.watch<AudioProvider>().automaticReplay;
    return Padding(
      padding: const .symmetric(horizontal: 15, vertical: 25),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: FBorderRadius().lg,
          border: .all(color: context.theme.colors.border),
          color: context.theme.colors.background,
        ),
        padding: .all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Configuración",
              style: textStyles.lg.copyWith(fontWeight: .w600),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Repetición automática", style: textStyles.xs),
                FSwitch(
                  value: automaticRepay,
                  onChange: (value) {
                    context.read<AudioProvider>().setAutomaticReplay(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            FItem(
              title: Text("Info"),
              prefix: HugeIcon(
                icon: HugeIcons.strokeRoundedInformationCircle,
                size: 18,
              ),
              suffix: const Icon(FLucideIcons.chevronRight),
              onPress: () {},
            ),
            const Spacer(),
            ExportButton(song: song),
            const SizedBox(height: 15),
            FButton(onPress: () {}, child: Text("Guardar")),
          ],
        ),
      ),
    );
  }
}

class ExportButton extends StatefulWidget {
  final SongEntity song;
  const ExportButton({super.key, required this.song});

  @override
  State<ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<ExportButton> {
  bool _exported = false;
  @override
  Widget build(BuildContext context) {
    if (_exported) {
      return FButton(
        onPress: () {},
        variant: .outline,
        child: Text(
          "Exportación completada",
          style: context.theme.typography.body.xs.copyWith(
            color: CustomColors.cyanGreen,
          ),
        ),
      );
    }
    return FButton(
      onPress: () async {
        await context.read<SongProvider>().exportSongToPublicDocuments(
          songId: widget.song.songId,
          songName: widget.song.title,
        );
        setState(() {
          _exported = true;
        });
      },
      variant: .outline,
      child: Text("Exportar canción"),
    );
  }
}

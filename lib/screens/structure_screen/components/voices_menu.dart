import 'package:audify_v3/models/song_entity.dart';
import 'package:audify_v3/models/voice_event.dart';
import 'package:audify_v3/providers/audio_provider.dart';
import 'package:audify_v3/providers/structure_provider.dart';
import 'package:audify_v3/utility/get_assets_voices.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';

class VoicesMenu extends StatelessWidget {
  final SongEntity song;
  const VoicesMenu({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final textStyles = context.theme.typography.body;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Añadir sección",
          style: textStyles.lg.copyWith(fontWeight: .bold),
        ),
        const SizedBox(height: 10),
        FutureBuilder(
          future: getVoiceModels(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No voices found');
            } else {
              final voices = snapshot.data!;

              return Wrap(
                spacing: 15,
                runSpacing: 15,
                children: voices.map((voice) {
                  return FButton(
                    onPress: () async {
                      final List<VoiceEvent> events = await context
                          .read<StructureProvider>()
                          .saveEvent(voice, song);

                      if (!context.mounted) return;
                      context.read<AudioProvider>().pauseAll();
                      context.read<AudioProvider>().setVoiceEvents(events);
                    },
                    variant: FButtonVariant.outline,
                    size: .xs,
                    mainAxisSize: .min,
                    suffix: Icon(
                      Icons.add,
                      color: context.theme.colors.mutedForeground,
                    ),
                    prefix: Icon(
                      FLucideIcons.circleDot,
                      color: context.theme.colors.mutedForeground,
                    ),
                    child: Text(voice.name),
                  );
                }).toList(),
              );
            }
          },
        ),
      ],
    );
  }
}

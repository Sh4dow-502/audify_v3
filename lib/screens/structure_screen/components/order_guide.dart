import 'package:audify_v3/main.dart';
import 'package:audify_v3/models/song_entity.dart';
import 'package:audify_v3/providers/audio_provider.dart';
import 'package:audify_v3/providers/structure_provider.dart';
import 'package:audify_v3/utility/get_main_voice_events.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';

class OrderGuide extends StatelessWidget {
  final SongEntity song;
  const OrderGuide({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final events = context.watch<AudioProvider>().voiceEvents;
    final mainEvents = getMainVoiceEvents(events);
    final textStyles = context.theme.typography.body;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Guía de orden de secciones",
          style: textStyles.lg.copyWith(fontWeight: .bold),
        ),
        const SizedBox(height: 10),
        mainEvents.isEmpty
            ? const Text('No hay secciones añadidas')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: mainEvents.map((event) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: FTile(
                      title: Text(
                        event.voice.name,
                        style: textStyles.md.copyWith(fontWeight: .bold),
                      ),
                      subtitle: Text(
                        event.position.toTimeFormat(),
                        style: textStyles.sm.copyWith(
                          fontWeight: .w500,
                          color: context.theme.colors.mutedForeground,
                        ),
                      ),
                      suffix: FButton.icon(
                        onPress: () async {
                          final events = await context
                              .read<StructureProvider>()
                              .deleteEvent(event, song);

                          if (!context.mounted) return;

                          context.read<AudioProvider>().setVoiceEvents(events);
                        },
                        variant: .ghost,
                        child: Icon(FLucideIcons.x),
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }
}

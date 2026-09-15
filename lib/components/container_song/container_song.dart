import 'package:audify_v3/models/song_entity.dart';
import 'package:audify_v3/providers/audio_provider.dart';
import 'package:audify_v3/providers/loading_provider.dart';
import 'package:audify_v3/providers/tracks_provider.dart';
import 'package:audify_v3/screens/loading_screen/loading_screen.dart';
import 'package:audify_v3/theme/custom_colors.dart';
import 'package:audify_v3/utility/format_duration.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';

class ContainerSong extends StatelessWidget {
  final SongEntity song;

  const ContainerSong({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    Color color = colors.primary;

    if (song.category.toLowerCase() == "adoracion") {
      color = CustomColors.celeste;
    } else if (song.category.toLowerCase() == "pop-rock") {
      color = CustomColors.lightPurple;
    }
    return Material(
      child: InkWell(
        onTap: () {
          final songIdProvider = context.read<LoadingProvider>().songId;

          if (songIdProvider != song.songId) {
            context.read<AudioProvider>().initialize();
            context.read<TracksProvider>().initTracks(
              song.sources.keys.toList(),
            );
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoadingScreen(song: song)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  FCard(
                    style: .delta(
                      decoration: .value(
                        BoxDecoration(
                          color: color.withValues(alpha: .12),
                          border: Border.all(
                            color: color.withValues(alpha: .7),
                          ),
                          borderRadius: FBorderRadius().lg,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Icon(FLucideIcons.music2, size: 20, color: color),
                    ),
                  ),
                  if (song.isDownloaded)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: CustomColors.lightGreen,
                          shape: .circle,
                        ),
                        padding: .all(4),
                        child: Icon(FLucideIcons.arrowDownToLine, size: 10),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      song.artist,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.theme.cardStyle.subtitleTextStyle.color,
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          FLucideIcons.layers,
                          size: 11,
                          color: colors.foreground.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "${song.trackCount} tracks",
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.foreground.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          FLucideIcons.clock2,
                          size: 11,
                          color: colors.foreground.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          formatDuration(song.duration.toInt()),
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.foreground.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          FLucideIcons.metronome,
                          size: 11,
                          color: colors.foreground.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "${song.metronome} bpm",
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.foreground.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              FButton.icon(
                onPress: () {
                  final songIdProvider = context.read<LoadingProvider>().songId;

                  if (songIdProvider != song.songId) {
                    context.read<AudioProvider>().initialize();
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoadingScreen(song: song),
                    ),
                  );
                },
                variant: .ghost,
                size: .lg,
                child: Icon(FLucideIcons.chevronRight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

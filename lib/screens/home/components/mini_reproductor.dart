import 'package:audify_v3/models/song_entity.dart';
import 'package:audify_v3/providers/audio_provider.dart';
import 'package:audify_v3/providers/loading_provider.dart';
import 'package:audify_v3/screens/loading_screen/loading_screen.dart';
import 'package:audify_v3/screens/player/components/progress_playing.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

class MiniReproductor extends StatelessWidget {
  const MiniReproductor({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AudioProvider>();
    final init = context.watch<AudioProvider>().isInit;
    final SongEntity? song = context.watch<LoadingProvider>().currentSong;
    final isFinished = context.watch<AudioProvider>().isFinished;
    final isPlaying = context.watch<AudioProvider>().isPlaying;

    if (!init || song == null) {
      return const SizedBox.shrink();
    }
    final colors = context.theme.colors;
    final textStyles = context.theme.typography.body;
    return Container(
      // color: colors.background.withValues(alpha: 0.8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.background.withValues(alpha: 0.85),
            colors.background.withValues(alpha: 0.7),
            colors.background.withValues(alpha: 0.2),
            colors.background.withValues(alpha: 0.0),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoadingScreen(song: song),
              ),
            );
          },
          child: FCard(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: .center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          border: .all(
                            color: colors.primary.withValues(alpha: 0.5),
                          ),
                          borderRadius: FBorderRadius().xl,
                        ),
                        padding: .symmetric(horizontal: 13, vertical: 15),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedMusicNote02,
                          size: 30,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              song.title,
                              maxLines: 2,
                              overflow: .ellipsis,
                              style: textStyles.sm.copyWith(fontWeight: .w600),
                            ),
                            Text(
                              song.artist,
                              maxLines: 1,
                              overflow: .ellipsis,
                              style: textStyles.xs.copyWith(
                                color: colors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      FButton(
                        // variant: .outline,
                        onPress: () => isFinished
                            ? provider.restart()
                            : provider.togglePlayPause(),
                        child: HugeIcon(
                          icon: isFinished
                              ? HugeIcons.strokeRoundedReplay
                              : isPlaying
                              ? HugeIcons.strokeRoundedPause
                              : HugeIcons.strokeRoundedPlay,
                          color: colors.foreground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ProgressPlaying(showTime: false),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

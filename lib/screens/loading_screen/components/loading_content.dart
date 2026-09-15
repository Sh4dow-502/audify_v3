import 'package:audify_v3/models/song_entity.dart';
import 'package:audify_v3/providers/loading_provider.dart';
import 'package:audify_v3/screens/loading_screen/components/progress_loading.dart';
import 'package:audify_v3/theme/custom_colors.dart';
import 'package:audify_v3/utility/format_duration.dart';
import 'package:audify_v3/utility/get_track_icon.dart';
import 'package:audify_v3/utility/get_track_name.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';

class LoadingContent extends StatelessWidget {
  final SongEntity song;
  const LoadingContent({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textStyles = context.theme.typography.body;
    return Column(
      children: [
        FCard(
          child: Padding(
            padding: const EdgeInsets.all(15),

            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  song.title,
                  style: textStyles.md.copyWith(fontWeight: .w600),
                  maxLines: 2,
                  overflow: .ellipsis,
                ),
                Text(
                  song.artist,
                  style: textStyles.sm.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                  maxLines: 1,
                  overflow: .ellipsis,
                ),
                const SizedBox(height: 7),
                Row(
                  spacing: 3,
                  children: [
                    Icon(
                      FLucideIcons.layers,
                      size: 13,
                      color: context.theme.colors.mutedForeground,
                    ),
                    Text(
                      "${song.trackCount} tracks",
                      style: textStyles.xs.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Icon(
                      FLucideIcons.clock,
                      size: 13,
                      color: context.theme.colors.mutedForeground,
                    ),
                    Text(
                      "${formatDuration(song.duration.toInt())} tracks",
                      style: textStyles.xs.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Icon(
                      FLucideIcons.metronome,
                      size: 13,
                      color: context.theme.colors.mutedForeground,
                    ),
                    Text(
                      "${song.metronome} bpm",
                      style: textStyles.xs.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        ProgressLoading(),
        const SizedBox(height: 40),
        Consumer<LoadingProvider>(
          builder: (_, provider, _) {
            final tracksLoaded = provider.tracksLoaded;
            final tracksDownloaded = provider.tracksDownloaded;
            final loadingStep = provider.loadinStep;
            final currentTrackLoading = provider.currentTrackLoading;
            final currentProgressDownloading = provider.downloadProgress;

            return Column(
              crossAxisAlignment: .center,
              children: [
                Wrap(
                  // mainAxisAlignment: .center,
                  spacing: 7,
                  alignment: .center,
                  children: [
                    ...song.sources.entries.map((entry) {
                      final Color trackColor = tracksLoaded.contains(entry.key)
                          ? colors.primary
                          : tracksDownloaded.contains(entry.key)
                          ? CustomColors.success
                          : context.theme.colors.mutedForeground;

                      final Color textColor = tracksLoaded.contains(entry.key)
                          ? colors.primary
                          : tracksDownloaded.contains(entry.key)
                          ? CustomColors.success
                          : context.theme.colors.foreground;
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: FBorderRadius().lg,
                          color: trackColor.withValues(alpha: 0.15),
                          border: .all(
                            color: context.theme.colors.border,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            spacing: 10,
                            children: [
                              Icon(getTrackIcon(entry.key), color: textColor),
                              Text(
                                getTrackName(entry.key),
                                style: textStyles.xs.copyWith(color: textColor),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 40),

                if (loadingStep == "downloading")
                  Text(
                    "Descargando pistas",
                    style: textStyles.xl.copyWith(fontWeight: .bold),
                  ),

                if (loadingStep == "downloading")
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      children: [
                        ...song.sources.entries.map((entry) {
                          String textPercent =
                              "${(currentProgressDownloading).toInt()}%";

                          String textName = getTrackName(entry.key);

                          String text = currentTrackLoading == entry.key
                              ? "$textName $textPercent"
                              : tracksDownloaded.contains(entry.key)
                              ? "$textName 100%"
                              : textName;

                          return Text(
                            text,
                            // "${getTrackName(entry.key)} ${currentTrackLoading == entry.key ? (currentProgressDownloading).toInt() : ""}%",
                            style: textStyles.md.copyWith(
                              color: currentTrackLoading == entry.key
                                  ? colors.secondaryForeground
                                  : tracksDownloaded.contains(entry.key)
                                  ? CustomColors.success
                                  : colors.mutedForeground,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                if (loadingStep == "loading" || loadingStep == "completed")
                  Text(
                    "Cargando pistas",
                    style: textStyles.xl.copyWith(fontWeight: .bold),
                  ),

                if (loadingStep == "loading" || loadingStep == "completed")
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: .center,
                      mainAxisAlignment: .center,
                      children: [
                        ...song.sources.entries.map((entry) {
                          return Row(
                            mainAxisAlignment: .center,
                            spacing: 10,
                            children: [
                              if (currentTrackLoading == entry.key &&
                                  loadingStep == "loading")
                                FCircularProgress(),
                              Text(
                                getTrackName(entry.key),
                                style: textStyles.md.copyWith(
                                  color: currentTrackLoading == entry.key
                                      ? loadingStep == "completed"
                                            ? colors.primary
                                            : colors.secondaryForeground
                                      : tracksLoaded.contains(entry.key)
                                      ? colors.primary
                                      : colors.mutedForeground,
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                if (loadingStep == "completed")
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Text(
                      "Carga completada",
                      style: textStyles.xl.copyWith(
                        color: colors.primary,
                        fontWeight: .bold,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

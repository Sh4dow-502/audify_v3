import 'package:audify_v3/models/song_entity.dart';
import 'package:audify_v3/screens/player/components/media_content.dart';
import 'package:audify_v3/screens/player/components/song_settings.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';

class PlayerScreen extends StatelessWidget {
  final SongEntity song;
  const PlayerScreen({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: Column(
          crossAxisAlignment: .start,
          children: [
            Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.theme.typography.body.xs.copyWith(
                color: context.theme.colors.mutedForeground,
                fontWeight: .w500,
              ),
            ),
          ],
        ),
        titleAlignment: .centerLeft,
        prefixes: [
          FHeaderAction.back(
            onPress: () {
              Navigator.pop(context);
            },
          ),
        ],
        suffixes: [
          FHeaderAction(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedFilterHorizontal,
              // color: context.theme.colors.mutedForeground,
            ),
            onPress: () {
              showFSheet(
                context: context,
                builder: (context) => SongSettings(song: song),
                side: .btt,
              );
            },
          ),
        ],
      ),
      child: MediaContent(song: song),
    );
  }
}

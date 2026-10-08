import 'package:audify_v3/components/media_track_control/media_track_control.dart';
import 'package:audify_v3/components/player_control/player_control.dart';
import 'package:audify_v3/models/song_entity.dart';
import 'package:audify_v3/screens/player/components/progress_playing.dart';
import 'package:flutter/material.dart';

class MediaContent extends StatelessWidget {
  final SongEntity song;
  const MediaContent({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MediaTrackControl(song: song),
        Expanded(child: const SizedBox.shrink()),
        ProgressPlaying(),
        const SizedBox(height: 5),
        PlayerControl(song: song),
        const SizedBox(height: 35),
      ],
    );
  }
}

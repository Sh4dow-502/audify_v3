import 'package:audify_v3/components/media_track_control/track_guide.dart';
import 'package:audify_v3/components/media_track_control/track_metronome.dart';
import 'package:audify_v3/components/track_control/track_control.dart';
import 'package:audify_v3/models/song_entity.dart';
import 'package:audify_v3/utility/order_tracks.dart';
import 'package:flutter/material.dart';

class MediaTrackControl extends StatelessWidget {
  final SongEntity song;
  const MediaTrackControl({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final tracks = song.sources;

    final tracksWithoutMetronome = Map.fromEntries(
      tracks.entries.where((entry) => entry.key != "metronome"),
    );

    final songTracks = orderTracksWithDetails(tracksWithoutMetronome);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        spacing: 15,
        children: [
          ...songTracks.entries.map((track) {
            return TrackControl(trackName: track.key);
          }),
          Divider(),
          TrackMetronome(bpm: song.metronome),
          TrackGuide(),
          // TrackControl(trackName: "metronome"),
        ],
      ),
    );
  }
}

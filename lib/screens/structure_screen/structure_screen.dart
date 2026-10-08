import 'package:audify_v3/components/player_control/player_control.dart';
import 'package:audify_v3/models/song_entity.dart';
import 'package:audify_v3/screens/player/components/progress_playing.dart';
import 'package:audify_v3/screens/structure_screen/components/order_guide.dart';
import 'package:audify_v3/screens/structure_screen/components/voices_menu.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class StructureScreen extends StatelessWidget {
  final SongEntity song;
  const StructureScreen({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: Text("Estructura de la canción"),
        titleAlignment: .centerLeft,
        prefixes: [
          FHeaderAction.back(
            onPress: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                VoicesMenu(song: song),
                const SizedBox(height: 15),
                OrderGuide(song: song),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ProgressPlaying(),
          const SizedBox(height: 10),
          PlayerControl(
            song: song,
            showMetronome: false,
            showSpeedControl: false,
          ),
          const SizedBox(height: 35),
        ],
      ),
    );
  }
}

import 'package:audify_v3/components/filter_component/filter_component.dart';
import 'package:audify_v3/components/list_songs/list_songs.dart';
import 'package:audify_v3/components/search_song/search_song.dart';
import 'package:audify_v3/screens/home/components/mini_reproductor.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        title: Text("Audify"),
        suffixes: [Icon(FLucideIcons.bolt)],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              SearchSong(),
              const SizedBox(height: 5),
              FilterComponent(),
              const SizedBox(height: 5),
              Expanded(child: ListSongs()),
            ],
          ),

          Positioned(bottom: 0, right: 0, left: 0, child: MiniReproductor()),
        ],
      ),
    );
  }
}

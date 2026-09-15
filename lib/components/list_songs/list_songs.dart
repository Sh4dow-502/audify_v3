import 'package:audify_v3/components/container_song/container_song.dart';
import 'package:audify_v3/providers/song_provider.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';

class ListSongs extends StatelessWidget {
  const ListSongs({super.key});

  @override
  Widget build(BuildContext context) {
    final songs = context.watch<SongProvider>().filteredSongs;
    final filter = context.watch<SongProvider>().filter;
    final searchQuery = context.watch<SongProvider>().searchQuery;

    if (songs.isEmpty && searchQuery.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "No se encontraron canciones para la búsqueda '$searchQuery'",
            style: context.theme.cardStyle.subtitleTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (songs.isEmpty && filter.toLowerCase() != "todo") {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "No se encontraron canciones para la categoria '$filter'",
            style: context.theme.cardStyle.subtitleTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 200),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ContainerSong(song: song);
      },
    );
  }
}

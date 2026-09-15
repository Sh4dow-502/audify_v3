import 'package:audify_v3/providers/song_provider.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';

class SearchSong extends StatefulWidget {
  const SearchSong({super.key});

  @override
  State<SearchSong> createState() => _SearchSongState();
}

class _SearchSongState extends State<SearchSong> {
  @override
  Widget build(BuildContext context) {
    return FTextField(
      control: .managed(
        onChange: (value) {
          context.read<SongProvider>().searchSongs(value.text.trim());
        },
      ),
      hint: "Buscar canción",
      maxLines: 1,
      minLines: 1,
      maxLength: 100,
      clearable: (value) => value.text.isNotEmpty,
    );
  }
}

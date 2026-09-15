import 'package:audify_v3/models/song_entity.dart';
import 'package:audify_v3/services/song_service.dart';
import 'package:flutter/material.dart';

class SongProvider extends ChangeNotifier {
  final SongService _service;
  SongProvider(this._service) {
    loadSongs();
  }

  List<SongEntity> _songs = [];
  List<SongEntity> get songs => _songs;

  List<SongEntity> _filteredSongs = [];
  List<SongEntity> get filteredSongs => _filteredSongs;

  final List<String> _filters = ["Todo", "Alabanza", "Adoracion", "Pop-rock"];
  List<String> get filters => _filters;

  String filter = "Todo";
  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  Future<void> loadSongs() async {
    final localSongs = await _service.getLocalSongs();

    _songs = localSongs;
    notifyListeners();

    final songs = await _service.getOnlineSongs();

    final songsWithoutDuplicates = songs.where((song) {
      return !localSongs.any((localSong) => localSong.songId == song.songId);
    }).toList();
    _songs = [...localSongs, ...songsWithoutDuplicates];
    // _songs = await _service.getOnlineSongs();
    _filteredSongs = _songs;
    notifyListeners();
  }

  void applyFilter(String filter) {
    if (filter.toLowerCase() == "todo") {
      _filteredSongs = _songs;
      this.filter = filter;
      notifyListeners();
      return;
    }
    final filteredSongs = _songs
        .where((song) => song.category.toLowerCase() == filter.toLowerCase())
        .toList();
    _filteredSongs = filteredSongs;
    this.filter = filter;
    notifyListeners();
  }

  void searchSongs(String query) {
    _searchQuery = query;
    _applyFiltersAndSearch();
  }

  void _applyFiltersAndSearch() {
    _filteredSongs = _songs.where((song) {
      // 1. Validar filtro de categoría
      final matchesCategory =
          filter.toLowerCase() == "todo" ||
          song.category.toLowerCase() == filter.toLowerCase();

      // 2. Validar búsqueda por título o categoría
      final query = _searchQuery.toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          song.title.toLowerCase().contains(query) ||
          song.category.toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();

    notifyListeners();
  }
}

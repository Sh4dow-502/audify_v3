import 'dart:convert';

import 'package:audify_v3/models/song_entity.dart';
import 'package:flutter/widgets.dart';
import 'package:objectbox/objectbox.dart';
import 'package:http/http.dart' as http;

class SongService {
  final Box<SongEntity> _songBox;
  final apiUrl = "http://192.168.1.130:8000/songs";

  SongService(Store store) : _songBox = store.box<SongEntity>();

  Future<List<SongEntity>> getOnlineSongs() async {
    debugPrint("Fetching online songs from $apiUrl");
    try {
      final response = await http.get(Uri.parse("$apiUrl/all"));
      if (response.statusCode == 200) {
        debugPrint(
          "Successfully fetched online songs. Response: ${response.body}",
        );
        final List data = json.decode(response.body);
        return data.map((item) => SongEntity.fromJson(item)).toList();
      } else {
        debugPrint(
          "Failed to fetch online songs. Status code: ${response.statusCode}",
        );
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching online songs: $e");
      return [];
    }
  }

  Future<List<SongEntity>> getLocalSongs() async {
    return _songBox.getAll();
  }
}

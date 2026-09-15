import 'dart:convert';

import 'package:objectbox/objectbox.dart';

@Entity()
class SongEntity {
  @Id()
  int id;

  @Unique()
  String songId;

  String title;
  String artist;
  String category;
  int metronome;
  double duration;
  int trackCount;
  bool isDownloaded;

  /// JSON string con paths locales
  String sourcesJson;
  String downloadSources;

  SongEntity({
    this.id = 0,
    required this.songId,
    required this.title,
    required this.artist,
    required this.category,
    required this.metronome,
    required this.duration,
    required this.trackCount,
    required this.sourcesJson,
    required this.downloadSources,
    this.isDownloaded = false,
  });

  // Map<String, String> get sources {
  //   try {
  //     if (sourcesJson.isEmpty) return {};
  //     return jsonDecode(sourcesJson);
  //   } catch (e) {
  //     return {};
  //   }
  // }

  // Map<String, Map<String, dynamic>> get sources {
  //   try {
  //     if (sourcesJson.isEmpty) return {};
  //     final decoded = jsonDecode(sourcesJson);
  //     if (decoded is Map) {
  //       // Forzamos a que tanto la clave como el valor sean String de forma segura
  //       return decoded.map(
  //         (key, value) => MapEntry(key.toString(), value.toString()),
  //       );
  //     }
  //     return {};
  //   } catch (e) {
  //     print(
  //       'Error al decodificar sourcesJson: $e',
  //     ); // Esto te dirá si había un error real
  //     return {};
  //   }
  // }
  Map<String, Map<String, dynamic>> get sources {
    try {
      if (sourcesJson.isEmpty) return {};
      final decoded = jsonDecode(sourcesJson);
      if (decoded is Map) {
        // Forzamos a que tanto la clave como el valor sean String de forma segura
        return decoded.map(
          (key, value) =>
              MapEntry(key.toString(), value as Map<String, dynamic>),
        );
      }
      return {};
    } catch (e) {
      print(
        'Error al decodificar sourcesJson: $e',
      ); // Esto te dirá si había un error real
      return {};
    }
  }

  Map<String, String> get downloadSourcesMap {
    try {
      if (downloadSources.isEmpty) return {};
      final decoded = jsonDecode(downloadSources);
      if (decoded is Map) {
        // Forzamos a que tanto la clave como el valor sean String de forma segura
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
      }
      return {};
    } catch (e) {
      print(
        'Error al decodificar downloadSources: $e',
      ); // Esto te dirá si había un error real
      return {};
    }
  }

  set sources(Map<String, String> value) {
    sourcesJson = jsonEncode(value);
  }

  set downloadSourcesMap(Map<String, String> value) {
    downloadSources = jsonEncode(value);
  }

  factory SongEntity.fromJson(Map<String, dynamic> json) {
    // Manejo de sources si viene como Map o como String
    var rawSources = json['sources'];
    String encodedSources = '';
    if (rawSources is Map) {
      encodedSources = jsonEncode(rawSources);
    } else if (rawSources is String) {
      encodedSources = rawSources;
    }

    return SongEntity(
      songId: json['id'] ?? json['mediaId'] ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      category: json['category'] ?? '',
      metronome: json['metronome'] ?? 0,
      duration: (json['duration'] ?? 0).toDouble(),
      trackCount: json['trackcount'] ?? json['trackCount'] ?? 0,
      sourcesJson: encodedSources,
      downloadSources: json['downloadSources'] ?? '',
      isDownloaded: json['isDownloaded'] ?? false,
    );
  }

  String intToTimeLeft(int value) {
    final dur = Duration(seconds: value);
    String twoDigits(int n) => n.toString().padLeft(1, '0');

    final hours = dur.inHours;
    final minutes = dur.inMinutes % 60;
    final seconds = dur.inSeconds % 60;

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else if (seconds == 0) {
      return minutes.toString().padLeft(1, '0');
    } else {
      return '${twoDigits(minutes)}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}

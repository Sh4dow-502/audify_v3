import 'dart:io';

import 'package:audify_v3/models/song_entity.dart';
import 'package:audify_v3/objectbox.g.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class LoadingService {
  final Box<SongEntity> _songBox;
  final apiUrl = "http://192.168.1.130:8000/songs";
  LoadingService(Store store) : _songBox = store.box<SongEntity>();

  Future<Directory> createDir(String songId) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${docsDir.path}/media/$songId');

    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    return mediaDir;
  }

  Future<String> downloadTrack(String songId, String trackName) async {
    final mediaDir = await createDir(songId);
    final sourcesPath = "$apiUrl/$songId/sources/$trackName";
    final response = await http.get(Uri.parse(sourcesPath));
    final file = File("${mediaDir.path}/$trackName.ogg");
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  Future<String> downloadTrackWithProgress(
    String songId,
    String trackName,
    Function(double) onProgress,
  ) async {
    final alreadyDownloaded = await isTrackDownloaded(songId, trackName);

    if (alreadyDownloaded) {
      onProgress(1.0); // Indicate that the download is complete
      return "${(await createDir(songId)).path}/$trackName.ogg";
    }
    final mediaDir = await createDir(songId);
    final sourcesPath = "$apiUrl/$songId/sources/$trackName";
    final request = http.Request('GET', Uri.parse(sourcesPath));
    final response = await request.send();

    final totalBytes = response.contentLength ?? 0;
    int receivedBytes = 0;

    final file = File("${mediaDir.path}/$trackName.ogg");
    final sink = file.openWrite();

    await for (var chunk in response.stream) {
      receivedBytes += chunk.length;
      sink.add(chunk);
      onProgress(receivedBytes / totalBytes);
    }

    await sink.close();
    return file.path;
  }

  Future<void> downloadAllTracks(SongEntity song) async {
    final sources = song.sources;
    for (var trackName in sources.keys) {
      await downloadTrack(song.songId, trackName);
    }
  }

  Future<void> saveSong(SongEntity song) async {
    _songBox.put(song);
  }

  Future<void> completedDownload(String songId) async {
    debugPrint("Marking song $songId as downloaded in the database.");
    final song = _songBox
        .query(SongEntity_.songId.equals(songId))
        .build()
        .findFirst();
    if (song != null) {
      debugPrint("ACUTALIZANDO A COMPLETADO");
      song.isDownloaded = true;
      _songBox.put(song);
    }
  }

  Future<void> deleteSong(SongEntity song) async {
    final mediaDir = await createDir(song.songId);
    if (await mediaDir.exists()) {
      await mediaDir.delete(recursive: true);
    }
    _songBox.remove(song.id);
  }

  Future<void> addTrackToDB(
    String songId,
    String key,
    String pathLocaltrack,
  ) async {
    final song = _songBox
        .query(SongEntity_.songId.equals(songId))
        .build()
        .findFirst();
    if (song != null) {
      song.downloadSourcesMap[key] = pathLocaltrack;
      // song.sources[key] = pathLocaltrack;
      _songBox.put(song);
    }
  }

  Future<bool> isTrackDownloaded(String songId, String trackName) async {
    final mediaDir = await createDir(songId);
    final file = File("${mediaDir.path}/$trackName.ogg");
    return file.exists();
  }

  Future<Map<String, String>> getDownloadedTracks(String songId) async {
    final mediaDir = await createDir(songId);
    final files = mediaDir.listSync();
    final downloadedTracks = <String, String>{};

    for (var file in files) {
      if (file is File && file.path.endsWith('.ogg')) {
        final trackName = file.uri.pathSegments.last.split('.').first;
        downloadedTracks[trackName] = file.path;
      }
    }

    return downloadedTracks;
  }

  SongEntity? getSongById(String songId) {
    return _songBox
        .query(SongEntity_.songId.equals(songId))
        .build()
        .findFirst();
  }
}

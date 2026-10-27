import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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

  Future<void> exportSongByIdAndName({
    required String songId,
    required String songName,
  }) async {
    try {
      // 1. Obtener el directorio de documentos del dispositivo
      final Directory docsDir = await getApplicationDocumentsDirectory();

      // 2. Ruta Origen: Documentos/media/[songId] (según la estructura de tu LoadingService)
      final String sourceFolderPath = p.join(docsDir.path, 'media', songId);
      final Directory sourceDirectory = Directory(sourceFolderPath);

      // Verificar si la carpeta origen existe
      if (!await sourceDirectory.exists()) {
        print('La carpeta origen no existe en: $sourceFolderPath');
        return;
      }

      // 3. Ruta Destino: Documentos/Audify/[songName]
      final String targetFolderPath = p.join(docsDir.path, 'Audify', songName);
      final Directory targetDirectory = Directory(targetFolderPath);

      // Crear la carpeta destino si no existe
      if (!await targetDirectory.exists()) {
        await targetDirectory.create(recursive: true);
        print('Carpeta destino creada en: $targetFolderPath');
      }

      // 4. Listar los archivos (.ogg, etc.) dentro de Documentos/media/[songId]
      final List<FileSystemEntity> entities = await sourceDirectory
          .list()
          .toList();
      final List<File> filesToCopy = entities.whereType<File>().toList();

      if (filesToCopy.isEmpty) {
        print('No se encontraron archivos en la carpeta $sourceFolderPath');
        return;
      }

      // 5. Copiar cada pista a la carpeta Audify/[songName]
      for (final File file in filesToCopy) {
        final String fileName = p.basename(file.path);
        final String destinationFilePath = p.join(targetFolderPath, fileName);
        final File destinationFile = File(destinationFilePath);

        // Si el archivo ya fue exportado previamente, se omite
        if (await destinationFile.exists()) {
          print(
            'El archivo "$fileName" ya existe en "$songName". Omitiendo...',
          );
        } else {
          await file.copy(destinationFilePath);
          print('Copiado exitosamente: $fileName -> $destinationFilePath');
        }
      }
    } catch (e) {
      print('Error al exportar los archivos: $e');
      rethrow;
    }
  }

  Future<void> exportSongToPublicDocuments({
    required String songId,
    required String songName,
  }) async {
    try {
      // 1. Obtener la ruta del directorio privado de la app (Origen)
      final Directory appDocsDir = await getApplicationDocumentsDirectory();
      final String sourceFolderPath = p.join(appDocsDir.path, 'media', songId);
      final Directory sourceDirectory = Directory(sourceFolderPath);

      if (!await sourceDirectory.exists()) {
        print('La carpeta origen no existe en: $sourceFolderPath');
        return;
      }

      // 2. Obtener la ruta pública de Documentos en Android
      Directory? publicDocsDir;

      if (Platform.isAndroid) {
        // /storage/emulated/0/Documents
        publicDocsDir = Directory('/storage/emulated/0/Documents');
        if (!await publicDocsDir.exists()) {
          // Fallback por si acaso la ruta varía en algún dispositivo
          final externalDir = await getExternalStorageDirectory();
          publicDocsDir = externalDir;
        }
      } else {
        // En iOS, el directorio de documentos sí es el visible en la app 'Archivos'
        publicDocsDir = await getApplicationDocumentsDirectory();
      }

      if (publicDocsDir == null) {
        print('No se pudo determinar el directorio de almacenamiento público.');
        return;
      }

      // 3. Definir la carpeta destino: /storage/emulated/0/Documents/Audify/[songName]
      final String targetFolderPath = p.join(
        publicDocsDir.path,
        'Audify',
        songName,
      );
      final Directory targetDirectory = Directory(targetFolderPath);

      if (!await targetDirectory.exists()) {
        await targetDirectory.create(recursive: true);
        print(
          'Carpeta destino creada en almacenamiento público: $targetFolderPath',
        );
      }

      // 4. Obtener archivos descargados en media/[songId]
      final List<FileSystemEntity> entities = await sourceDirectory
          .list()
          .toList();
      final List<File> filesToCopy = entities.whereType<File>().toList();

      if (filesToCopy.isEmpty) {
        print('No se encontraron archivos en la carpeta $sourceFolderPath');
        return;
      }

      // 5. Copiar los archivos a la carpeta pública
      for (final File file in filesToCopy) {
        final String fileName = p.basename(file.path);
        final String destinationFilePath = p.join(targetFolderPath, fileName);
        final File destinationFile = File(destinationFilePath);

        if (await destinationFile.exists()) {
          print(
            'El archivo "$fileName" ya existe en "$songName". Omitiendo...',
          );
        } else {
          await file.copy(destinationFilePath);
          print('Copiado exitosamente a Documentos: $destinationFilePath');
        }
      }
    } catch (e) {
      print('Error al exportar los archivos: $e');
      rethrow;
    }
  }
}

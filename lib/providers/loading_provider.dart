import 'package:audify_v3/models/song_entity.dart';
import 'package:audify_v3/services/audio_service.dart';
import 'package:audify_v3/services/loading_service.dart';
import 'package:flutter/material.dart';

class LoadingProvider extends ChangeNotifier {
  final AudioService _audioService;
  final LoadingService _loadingService;

  LoadingProvider(this._audioService, this._loadingService) {
    debugPrint('LoadingProvider creado');
    debugPrint('AudioService: $_audioService');
    debugPrint('LoadingService: $_loadingService');
  }

  String _songId = "";
  List<String> _loadingSongs = [];
  String _currentTrackLoading = "";
  List<String> _tracksDownloaded = [];
  List<String> _tracksLoaded = [];
  Map<String, Map<String, dynamic>> tracksSong = {};
  String loadinStep = "downloading";
  double downloadProgress = 0.0;
  bool songDownloaded = false;
  int step = 0;

  List<String> get tracksDownloaded => _tracksDownloaded;
  List<String> get tracksLoaded => _tracksLoaded;
  String get songId => _songId;
  String get currentTrackLoading => _currentTrackLoading;
  List<String> get loadingSongs => _loadingSongs;
  SongEntity? get currentSong => _loadingService.getSongById(_songId);

  Future<void> initLoading(SongEntity song, {Function()? incrementStep}) async {
    if (_songId == song.songId) {
      loadinStep = "completed";
      notifyListeners();
      return;
    }
    _songId = song.songId;
    _loadingSongs = [];
    _tracksDownloaded = [];
    _tracksLoaded = [];
    loadinStep = "downloading";
    tracksSong = song.sources;
    _currentTrackLoading = "";
    step = 0;
    notifyListeners();
    await _audioService.disposeAll();

    if (!song.isDownloaded) {
      loadinStep = "downloading";
      songDownloaded = false;
      notifyListeners();
      await initDownloadProcess();
      await _loadingService.saveSong(song);
      await _loadingService.completedDownload(song.songId);
      songDownloaded = true;
      loadinStep = "loading";
      step += 1;
      notifyListeners();
      await initLoadingProcess();
      loadinStep = "completed";
      notifyListeners();
      step += 1;
    }

    if (song.isDownloaded) {
      debugPrint("MARCANDO COMO LOADING");
      _tracksDownloaded = song.sources.keys.toList();
      loadinStep = "loading";
      songDownloaded = true;
      step += 1;
      notifyListeners();

      await initLoadingProcess();
      loadinStep = "completed";
      notifyListeners();
      step += 1;
    }
  }

  Future<void> initDownloadProcess() async {
    try {
      for (var track in tracksSong.entries) {
        debugPrint("Downloading track: ${track.key} from ${track.value}");
        _currentTrackLoading = track.key;
        notifyListeners();
        final value = track.value;
        final isActive = value["active"] ?? false;
        if (isActive) {
          await _loadingService.downloadTrackWithProgress(
            songId,
            track.key,
            updateDownloadProgress,
          );

          _tracksDownloaded = List.from(_tracksDownloaded)..add(track.key);
          notifyListeners();
        }
      }
      // await _loadingService.completedDownload(songId);
    } catch (e) {
      debugPrint("Error downloading track: $e");
    }
  }

  Future<void> initLoadingProcess() async {
    await _audioService.disposeAll();
    final tracksSong = await _loadingService.getDownloadedTracks(_songId);
    try {
      for (var track in tracksSong.entries) {
        debugPrint("Loading track: ${track.key} from ${track.value}");
        _currentTrackLoading = track.key;
        notifyListeners();
        await _audioService.loadTrack(track.key, track.value);
        _audioService.setTrackVolume(track.key, 0.8);

        _tracksLoaded = List.from(_tracksLoaded)..add(track.key);
        await _loadingService.addTrackToDB(songId, track.key, track.value);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading track: $e");
    }
  }

  void updateDownloadProgress(double progress) {
    downloadProgress = progress * 100;
    notifyListeners();
  }
}

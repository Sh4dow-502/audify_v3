import 'package:audify_v3/models/track_state.dart';
import 'package:audify_v3/services/audio_service.dart';
import 'package:flutter/material.dart';

class TracksProvider extends ChangeNotifier {
  final AudioService _audioService;

  TracksProvider(this._audioService);

  final Map<String, TrackState> _trackStates = {};

  double _voicesVolume = 1.0;
  double get voicesVolume => _voicesVolume;

  bool _voicesMuted = false;
  bool get voicesMuted => _voicesMuted;

  /// Inicializa o resetea el estado de una lista de tracks para una nueva canción.
  void initTracks(List<String> trackIds) {
    _trackStates.clear();
    for (var id in trackIds) {
      _trackStates[id] = const TrackState(volume: 1.0, isMuted: false);
    }
    _voicesVolume = 1.0;
    setVoicesVolume(_voicesVolume);
    notifyListeners();
  }

  TrackState getTrackState(String trackId) {
    return _trackStates[trackId] ?? const TrackState();
  }

  void setTrackVolume(String trackId, double volume) {
    final currentState = getTrackState(trackId);

    // Si ajusta el slider mientras estaba muteado, lo desmuteamos automáticamente
    final newState = currentState.copyWith(volume: volume, isMuted: false);

    _trackStates[trackId] = newState;
    _audioService.setTrackVolume(trackId, newState.effectiveVolume);
    notifyListeners();
  }

  void setVoicesVolume(double volume) {
    _audioService.setVoicesVolume(volume);
    _voicesVolume = volume;
    notifyListeners();
  }

  void toggleMuteVoices() {
    _voicesMuted = !_voicesMuted;

    _audioService.setVoicesVolume(_voicesMuted ? 0.0 : _voicesVolume);

    notifyListeners();
  }

  void toggleMuteTrack(String trackId) {
    final currentState = getTrackState(trackId);
    final newMuted = !currentState.isMuted;

    final newState = currentState.copyWith(isMuted: newMuted);
    _trackStates[trackId] = newState;

    // Enviamos el volumen efectivo (0.0 si está muteado, o su volumen original)
    _audioService.setTrackVolume(trackId, newState.effectiveVolume);
    notifyListeners();
  }
}

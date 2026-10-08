import 'dart:async';

import 'package:audify_v3/models/voice_event.dart';
import 'package:audify_v3/services/audio_service.dart';
import 'package:flutter/material.dart';

class AudioProvider extends ChangeNotifier {
  final AudioService _audioService;
  static const _safetyMargin = Duration(milliseconds: 300);
  bool isPlaying = false;
  bool _init = false;
  AudioProvider(this._audioService);

  bool _automaticReplay = false;
  bool get automaticReplay => _automaticReplay;

  List<VoiceEvent> _voiceEvents = [];
  int _nextVoiceEventIndex = 0;

  List<VoiceEvent> get voiceEvents => _voiceEvents;

  Duration _currentPosition = Duration.zero;
  Duration get currentPosition => _currentPosition;
  Timer? _ticker;
  Duration get totalDuration => _audioService.getDuration();

  bool get isInit => _init;

  bool get isFinished {
    if (totalDuration == Duration.zero) return false;
    return currentPosition >= (totalDuration - _safetyMargin);
  }

  bool get hasReward {
    return currentPosition >= const Duration(seconds: 5);
  }

  bool get hasForward {
    if (totalDuration == Duration.zero) return false;
    final remaining = totalDuration - currentPosition;
    return remaining >= const Duration(seconds: 5);
  }

  void initialize() {
    _currentPosition = Duration.zero;
    _init = false;
    isPlaying = false;
    _stopPositionTicker();
    notifyListeners();
  }

  void setVoiceEvents(List<VoiceEvent> events) {
    debugPrint(
      'AudioProvider: setVoiceEvents called with ${events.length} events',
    );
    _voiceEvents = [...events]
      ..sort((a, b) => a.position.compareTo(b.position));

    _nextVoiceEventIndex = 0;
    notifyListeners();
  }

  void _checkVoiceEvents(Duration position) {
    while (_nextVoiceEventIndex < _voiceEvents.length &&
        position >= _voiceEvents[_nextVoiceEventIndex].position) {
      final event = _voiceEvents[_nextVoiceEventIndex];

      print(
        "REPRODUCIENDO VOZ: ${event.voice.name}, id: ${event.voice.id} en ${event.position.inMilliseconds} ms",
      );
      _audioService.playVoice(event.voice.name.toLowerCase());

      _nextVoiceEventIndex++;
    }
  }

  void _updateNextVoiceEvent(Duration position) {
    _nextVoiceEventIndex = _voiceEvents.indexWhere(
      (event) => event.position > position,
    );

    if (_nextVoiceEventIndex == -1) {
      _nextVoiceEventIndex = _voiceEvents.length;
    }
  }

  void _startPositionTicker() {
    _ticker?.cancel();

    _ticker = Timer.periodic(const Duration(milliseconds: 30), (_) async {
      if (!isPlaying) return;

      final pos = await _audioService.getPosition();

      // 🔊 Revisar eventos de voz
      _checkVoiceEvents(pos);

      final total = totalDuration;

      if (total > Duration.zero && pos >= (total - _safetyMargin)) {
        if (automaticReplay) {
          restart();
          return;
        }

        _stopPositionTicker();

        _audioService.seekAll(total - _safetyMargin);

        _audioService.pauseAll();

        _currentPosition = total;
        isPlaying = false;

        notifyListeners();
        return;
      }

      _currentPosition = pos;
      notifyListeners();
    });
  }

  // void _startPositionTicker() {
  //   _ticker?.cancel();
  //   _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) async {
  //     if (!isPlaying) return;
  //
  //     final pos = await _audioService.getPosition();
  //
  //     final total = totalDuration;
  //
  //     if (total > Duration.zero && pos >= (total - _safetyMargin)) {
  //       if (automaticReplay) {
  //         restart();
  //         return;
  //       }
  //       _stopPositionTicker();
  //
  //       // 1. Pausamos C++ exactamente en el margen de seguridad
  //       _audioService.seekAll(total - _safetyMargin);
  //       _audioService.pauseAll();
  //       // _stopPositionTicker();
  //       // pauseAll();
  //       // _audioService.pauseAll(); // Pausamos directo en C++
  //       _currentPosition = total; // Forzamos la UI a mostrar final completo
  //       isPlaying = false;
  //       notifyListeners();
  //       return;
  //     }
  //     _currentPosition = pos;
  //     notifyListeners();
  //   });
  // }

  void _stopPositionTicker() {
    _ticker?.cancel();
  }

  void pauseAll() {
    _audioService.pauseAll();
    _stopPositionTicker();
    isPlaying = false;
    notifyListeners();
  }

  void playAll() {
    _audioService.playAll();
    isPlaying = true;
    notifyListeners();
  }

  void seekAll(Duration position) {
    Duration targetPosition = position;
    final total = totalDuration;

    // Si arrastran el slider hasta el fondo, congelamos la posición un instante antes del final
    if (total > Duration.zero && targetPosition >= (total - _safetyMargin)) {
      if (automaticReplay) {
        restart();
        return;
      }
      targetPosition = total - _safetyMargin;
      _updateNextVoiceEvent(targetPosition);
      _audioService.seekAll(targetPosition);
      _audioService.pauseAll();
      _currentPosition = total; // Para visualmente renderizar la barra llena
      isPlaying = false;
      _stopPositionTicker();
      notifyListeners();
      return;
    }

    _updateNextVoiceEvent(targetPosition);

    _audioService.seekAll(targetPosition);
    _currentPosition = targetPosition;
    notifyListeners();
  }

  void togglePlayPause() {
    if (!isPlaying && _init == false) {
      debugPrint("Reproduciendo por primera vez");
      _audioService.playAll();
      _startPositionTicker();
      _init = true;
      // _audioService.pause();
    } else {
      _audioService.resumeAll();
      _startPositionTicker();
    }

    if (isPlaying && _init == true) {
      _audioService.pauseAll();
      _stopPositionTicker();
    }

    isPlaying = !isPlaying;
    notifyListeners();
  }

  void seekRelative(int seconds) {
    // Usamos el estado local sincronizado _currentPosition
    final newPosition = _currentPosition + Duration(seconds: seconds);
    final totalDur = totalDuration;

    if (newPosition < Duration.zero) {
      seekAll(Duration.zero);
    } else if (newPosition >= totalDur) {
      seekAll(totalDur);
      pauseAll();
    } else {
      seekAll(newPosition);
    }
  }

  void restart() {
    debugPrint("Reiniciando reproducción");

    _audioService.seekAll(Duration.zero);
    _audioService.resumeAll();

    _currentPosition = Duration.zero;

    _nextVoiceEventIndex = 0;

    isPlaying = true;
    _init = true;

    _startPositionTicker();
    notifyListeners();
  }

  // void restart() {
  //   debugPrint("Reiniciando reproducción");
  //   _audioService.seekAll(Duration.zero);
  //   _audioService.resumeAll();
  //
  //   _currentPosition = Duration.zero;
  //   isPlaying = true;
  //   _init = true;
  //
  //   _startPositionTicker();
  //   notifyListeners();
  // }

  void setAutomaticReplay(bool value) {
    _automaticReplay = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopPositionTicker();
    super.dispose();
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

class AudioService extends ChangeNotifier {
  final SoLoud _soLoud = SoLoud.instance;
  final Map<String, AudioSource> _loadedSources = {};
  final Map<String, SoundHandle> _activeHandles = {};

  Future<void> init() async {
    try {
      if (!_soLoud.isInitialized) {
        await _soLoud.init();
      }

      debugPrint('SoLoud initialized');
    } catch (e) {
      debugPrint('Error initializing SoLoud: $e');
    }
  }

  Future<void> loadTrack(String id, String filePath) async {
    if (filePath.isEmpty) {
      return;
    }
    try {
      final source = await _soLoud.loadFile(filePath);
      _loadedSources[id] = source;
    } catch (e) {
      debugPrint('Error loading track $id: $e');
    }
  }

  // En AudioService.dart
  void playAll([Map<String, double>? effectiveVolumes]) {
    for (var entry in _loadedSources.entries) {
      final id = entry.key;
      final source = entry.value;

      if (_activeHandles.containsKey(id)) {
        _soLoud.stop(_activeHandles[id]!);
      }

      final handle = _soLoud.play(source, paused: true);
      _activeHandles[id] = handle;

      if (effectiveVolumes != null && effectiveVolumes.containsKey(id)) {
        _soLoud.setVolume(handle, effectiveVolumes[id]!);
      }
    }

    for (var handle in _activeHandles.values) {
      _soLoud.setPause(handle, false);
    }
  }

  // En AudioService.dart
  // void playAll([Map<String, double>? volumes]) {
  //   for (var entry in _loadedSources.entries) {
  //     final id = entry.key;
  //     final source = entry.value;
  //
  //     if (_activeHandles.containsKey(id)) {
  //       _soLoud.stop(_activeHandles[id]!);
  //     }
  //
  //     final handle = _soLoud.play(source, paused: true);
  //     _activeHandles[id] = handle;
  //
  //     // Aplicar volumen preexistente o 1.0 si no se ha definido
  //     if (volumes != null && volumes.containsKey(id)) {
  //       _soLoud.setVolume(handle, volumes[id]!);
  //     }
  //   }
  //
  //   for (var handle in _activeHandles.values) {
  //     _soLoud.setPause(handle, false);
  //   }
  // }

  // void playAll() {
  //   for (var entry in _loadedSources.entries) {
  //     final id = entry.key;
  //     final source = entry.value;
  //
  //     if (_activeHandles.containsKey(id)) {
  //       _soLoud.stop(_activeHandles[id]!);
  //     }
  //
  //     final handle = _soLoud.play(source, paused: true);
  //     _activeHandles[id] = handle;
  //   }
  //
  //   for (var handle in _activeHandles.values) {
  //     _soLoud.setPause(handle, false);
  //   }
  // if (_loadedSources.isEmpty) return;
  //
  // for (var entry in _loadedSources.entries) {
  //   final id = entry.key;
  //   final sources = entry.value;
  //   final existingHandle = _activeHandles[id];
  //
  //   if (existingHandle != null) {
  //     _soLoud.stop(existingHandle);
  //   }
  //
  //   final handle = _soLoud.play(sources, paused: true);
  //   _activeHandles[id] = handle;
  // }
  //
  // for (var handle in _activeHandles.values) {
  //   _soLoud.setPause(handle, false);
  // }
  // }

  void pauseAll() {
    for (var handle in _activeHandles.values) {
      _soLoud.setPause(handle, true);
    }
  }

  void resumeAll() {
    for (var handle in _activeHandles.values) {
      _soLoud.setPause(handle, false);
    }
  }

  void setGlobalSpeed(double speed) {
    for (var handle in _activeHandles.values) {
      _soLoud.setRelativePlaySpeed(handle, speed);
    }
  }

  void setTrackVolume(String id, double volume) {
    final handle = _activeHandles[id];
    if (handle != null) {
      _soLoud.setVolume(handle, volume);
    }
  }

  void seekAll(Duration position) {
    for (var handle in _activeHandles.values) {
      _soLoud.seek(handle, position);
    }
  }

  Future<void> disposeAll() async {
    // 1. Detener la reproducción de los handles de audio activos
    for (var handle in _activeHandles.values) {
      _soLoud.stop(handle);
    }
    _activeHandles.clear();

    // 2. Liberar las fuentes de sonido de la memoria nativa de C++
    for (var source in _loadedSources.values) {
      await _soLoud.disposeSource(source);
    }
    _loadedSources.clear();

    debugPrint(
      "🧹 AudioService: Memoria de pistas e instancias completamente liberada.",
    );
  }

  void toggleMutedTrack(String id) {
    final handle = _activeHandles[id];
    if (handle != null) {
      final currentVolume = _soLoud.getVolume(handle);
      if (currentVolume > 0) {
        _soLoud.setVolume(handle, 0);
      } else {
        _soLoud.setVolume(
          handle,
          currentVolume,
        ); // Restablecer al volumen original
      }
    }
  }

  Future<Duration> getPosition() async {
    if (_loadedSources.isEmpty || _activeHandles.isEmpty) {
      return Duration.zero;
    }

    final handle = _activeHandles.values.first;
    // Si el handle sigue vivo, pedimos la posición
    if (_soLoud.getIsValidVoiceHandle(handle)) {
      return _soLoud.getPosition(handle);
    }

    return Duration.zero;
  }

  Duration getDuration() {
    if (_loadedSources.isEmpty) return Duration.zero;

    // Obtenemos la duración directamente del AudioSource cargado, no del SoundHandle
    final firstTrack = _loadedSources.values.first;
    return _soLoud.getLength(firstTrack);
  }

  double getTrackVolume(String trackId) {
    final track = _activeHandles[trackId];
    return track != null ? _soLoud.getVolume(track) : 0.0;
  }

  void clearAll() {
    for (var handle in _activeHandles.values) {
      _soLoud.stop(handle);
    }
    _activeHandles.clear();
  }
}

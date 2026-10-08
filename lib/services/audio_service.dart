import 'package:audify_v3/utility/get_assets_voices.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

class AudioService extends ChangeNotifier {
  final SoLoud _soLoud = SoLoud.instance;
  final Map<String, AudioSource> _loadedSources = {};
  final Map<String, SoundHandle> _activeHandles = {};
  final Map<String, AudioSource> _voices = {};
  final Map<String, SoundHandle> _voiceHandles = {};
  double _voicesVolume = 1.0;

  Future<void> init() async {
    debugPrint('🟢 INIT AudioService instance: $hashCode');

    try {
      if (!_soLoud.isInitialized) {
        await _soLoud.init();
      }

      final assetsVoices = await getVoiceModels();

      for (final voice in assetsVoices) {
        try {
          debugPrint('Loading voice: "${voice.id}" -> "${voice.asset}"');

          final source = await _soLoud.loadAsset(voice.asset);

          _voices[voice.id] = source;

          debugPrint('✓ Loaded: "${voice.id}"');
        } catch (e) {
          debugPrint('✗ Failed: "${voice.id}" -> $e');
        }
      }

      debugPrint('Voices loaded: ${_voices.length}');
      debugPrint('Keys: ${_voices.keys}');
      debugPrint('AudioService instance: $hashCode');
    } catch (e) {
      debugPrint('Error initializing SoLoud: $e');
    }
  }

  Future<void> playVoice(String voiceName) async {
    debugPrint('🔵 PLAY VOICE instance: $hashCode');
    debugPrint('🔵 voiceName: "$voiceName"');
    debugPrint('🔵 available keys: ${_voices.keys}');
    debugPrint('🔵 containsKey: ${_voices.containsKey(voiceName)}');

    final source = _voices[voiceName];

    if (source == null) {
      debugPrint('❌ Voice "$voiceName" NOT FOUND');
      return;
    }

    final existingHandle = _voiceHandles[voiceName];

    if (existingHandle != null &&
        _soLoud.getIsValidVoiceHandle(existingHandle)) {
      _soLoud.stop(existingHandle);
    }

    final handle = _soLoud.play(source);

    _voiceHandles[voiceName] = handle;

    _soLoud.setVolume(handle, _voicesVolume);
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

  void setVoicesVolume(double volume) {
    _voicesVolume = volume.clamp(0.0, 2.0);

    for (final handle in _voiceHandles.values) {
      if (_soLoud.getIsValidVoiceHandle(handle)) {
        _soLoud.setVolume(handle, _voicesVolume);
      }
    }
  }

  double getVoicesVolume() {
    final handle = _activeHandles['uno'];
    return handle != null ? _soLoud.getVolume(handle) : 0.0;
  }

  void seekAll(Duration position) {
    for (var handle in _activeHandles.values) {
      _soLoud.seek(handle, position);
    }
  }

  Future<void> disposeAll() async {
    // Detener tracks
    for (final handle in _activeHandles.values) {
      if (_soLoud.getIsValidVoiceHandle(handle)) {
        _soLoud.stop(handle);
      }
    }

    _activeHandles.clear();

    // Detener voces
    for (final handle in _voiceHandles.values) {
      if (_soLoud.getIsValidVoiceHandle(handle)) {
        _soLoud.stop(handle);
      }
    }

    _voiceHandles.clear();

    // Liberar tracks
    for (final source in _loadedSources.values) {
      await _soLoud.disposeSource(source);
    }

    _loadedSources.clear();

    // // Liberar voces
    // for (final source in _voices.values) {
    //   await _soLoud.disposeSource(source);
    // }
    //
    // _voices.clear();

    debugPrint('🧹 AudioService: Memoria de audio completamente liberada.');
  }

  void toggleMutedVoices() {
    _voices.forEach((id, source) {
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
    });
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

  Duration getTrackDuration(String trackId) {
    // El Track Ya esta iniciado con _soLoud.loadAsset por lo que podemos obtener la duración directamente del AudioSource
    //
    final source = _loadedSources[trackId] ?? _voices[trackId];
    final duration = source != null ? _soLoud.getLength(source) : Duration.zero;
    return duration;
  }

  double getTrackVolume(String trackId) {
    final track = _activeHandles[trackId];
    return track != null ? _soLoud.getVolume(track) : 0.0;
  }

  Future<void> clearAll() async {
    // Detener tracks
    for (final handle in _activeHandles.values) {
      if (_soLoud.getIsValidVoiceHandle(handle)) {
        _soLoud.stop(handle);
      }
    }

    _activeHandles.clear();

    // Liberar tracks
    for (final source in _loadedSources.values) {
      await _soLoud.disposeSource(source);
    }

    _loadedSources.clear();

    debugPrint('🧹 Tracks liberados.');
  }
}

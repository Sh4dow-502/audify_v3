import 'package:audify_v3/models/song_entity.dart';
import 'package:audify_v3/models/voice_event.dart';
import 'package:audify_v3/models/voice_model.dart';
import 'package:audify_v3/services/audio_service.dart';
import 'package:audify_v3/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class StructureProvider extends ChangeNotifier {
  final AudioService _audioService;
  final DatabaseService _databaseService;

  StructureProvider(this._audioService, this._databaseService);
  Future<List<VoiceEvent>> saveEvent(VoiceModel voice, SongEntity song) async {
    if (song.metronome <= 0) {
      debugPrint('⚠️ BPM inválido (${song.metronome}). No se genera guía.');
      return song.voiceEvents;
    }

    _audioService.pauseAll();
    final Duration currentPosition = await _audioService.getPosition();

    // ─────────────────────────────────────────────────────────────────────
    //  CALIBRACIÓN
    // ─────────────────────────────────────────────────────────────────────
    //
    //  kPositionReadAheadMs
    //    Read-ahead del reproductor de la CANCIÓN (buffer decodificado que va
    //    adelantado del audio audible). Se descuenta ANTES del snap para que
    //    el grid elija el beat correcto. Ya calibrado en 200 → NO tocar.
    //
    //  kEventLatencyMs
    //    Latencia extra del reproductor de VOZ respecto al de la canción.
    //    Se RESTA a las posiciones finales de los eventos.
    //      · Si los eventos suenan TARDE  → subir (40, 60, 80…).
    //      · Si los eventos suenan TEMPRANO → bajar.
    //    Rango típico: 0–200 ms. Empezá en 60 y subí de a 20.
    //
    const int kPositionReadAheadMs = 140;
    const int kEventLatencyMs = 140; // ← calibrá ESTE

    // ─── Métricas (µs) ────────────────────────────────────────────────────
    final double beatUs = 60000000.0 / song.metronome;
    final int beatMs = (beatUs / 1000).round();

    // ─── Snap al beat más cercano (con read-ahead descontado) ─────────────
    final int pressUs =
        currentPosition.inMicroseconds - kPositionReadAheadMs * 1000;
    final int targetBeatUs = ((pressUs / beatUs).round() * beatUs).round();

    // ─── Grid del conteo ──────────────────────────────────────────────────
    //   1 = −4 · 2 = −3 · 3 = −2 · 4 = −1 · 0 = downbeat (música)
    final int unoUs = targetBeatUs - (4 * beatUs).round();
    final int dosUs = targetBeatUs - (3 * beatUs).round();
    final int tresUs = targetBeatUs - (2 * beatUs).round();
    final int cuatroUs = targetBeatUs - (1 * beatUs).round();

    // ─── Voz principal ────────────────────────────────────────────────────
    final Duration voiceDuration = _audioService.getTrackDuration(
      voice.name.toLowerCase(),
    );
    final int voiceDurationUs = voiceDuration.inMicroseconds;
    const double naturalGapInBeats = 0.15;
    final int gapUs = (beatUs * naturalGapInBeats).round();
    final int beatsForVoice = ((voiceDurationUs + gapUs) / beatUs).ceil();
    final int voiceIntroUs = unoUs - (beatsForVoice * beatUs).round();

    // ─── Compensación de latencia de EVENTO (sub-beat, uniforme) ──────────
    final int eventShiftUs = kEventLatencyMs * 1000;
    final List<int> rawPositions = [
      voiceIntroUs - eventShiftUs,
      unoUs - eventShiftUs,
      dosUs - eventShiftUs,
      tresUs - eventShiftUs,
      cuatroUs - eventShiftUs,
    ];

    // ─── Normalizar a ≥ 0 (sin romper el grid) ────────────────────────────
    final int minUs = rawPositions.reduce((a, b) => a < b ? a : b);
    final int shiftUs = minUs < 0 ? -minUs : 0;

    // ─── Construcción ─────────────────────────────────────────────────────
    final String groupId = const Uuid().v4();
    VoiceEvent build(VoiceModel v, int rawUs) => VoiceEvent(
      id: const Uuid().v4(),
      groupId: groupId,
      position: Duration(microseconds: rawUs + shiftUs),
      voice: v,
    );

    final List<VoiceEvent> newEvents = [
      build(voice, rawPositions[0]),
      build(VoiceModel(id: 'uno', name: 'uno', asset: ''), rawPositions[1]),
      build(VoiceModel(id: 'dos', name: 'dos', asset: ''), rawPositions[2]),
      build(VoiceModel(id: 'tres', name: 'tres', asset: ''), rawPositions[3]),
      build(
        VoiceModel(id: 'cuatro', name: 'cuatro', asset: ''),
        rawPositions[4],
      ),
    ];

    final List<VoiceEvent> merged = List.of(song.voiceEvents)
      ..addAll(newEvents);
    song.voiceEvents = merged;
    await _databaseService.saveSong(song);

    // ─── Diagnóstico ──────────────────────────────────────────────────────
    debugPrint('═══ GRID MUSICAL ═══');
    debugPrint(
      'BPM ${song.metronome} · beat $beatMs ms · '
      'readAhead $kPositionReadAheadMs · eventLatency $kEventLatencyMs ms',
    );
    debugPrint(
      'raw ${currentPosition.inMicroseconds ~/ 1000} ms  →  '
      'audible ${pressUs ~/ 1000} ms  →  snap ${targetBeatUs ~/ 1000} ms  '
      '(Δ ${(currentPosition.inMicroseconds - targetBeatUs) ~/ 1000} ms)',
    );
    debugPrint(
      'Intro @ ${(rawPositions[0] + shiftUs) ~/ 1000} ms ($beatsForVoice beats)',
    );
    debugPrint('"1"   @ ${(rawPositions[1] + shiftUs) ~/ 1000} ms');
    debugPrint('"2"   @ ${(rawPositions[2] + shiftUs) ~/ 1000} ms');
    debugPrint('"3"   @ ${(rawPositions[3] + shiftUs) ~/ 1000} ms');
    debugPrint('"4"   @ ${(rawPositions[4] + shiftUs) ~/ 1000} ms');

    return song.voiceEvents;
  }

  // Future<List<VoiceEvent>> saveEvent(VoiceModel voice, SongEntity song) async {
  //   if (song.metronome <= 0) {
  //     debugPrint('La canción no tiene un BPM válido');
  //     return [];
  //   }
  //
  //   _audioService.pauseAll();
  //   final currentPosition = await _audioService.getPosition();
  //   // 1. Duración exacta de 1 beat en milisegundos (precisión flotante)
  //   // final double beatMs = 60000 / song.metronome;
  //   // final double currentMs = currentPosition.inMilliseconds.toDouble();
  //   //
  //   // // 2. Cuantización estricta al Beat más cercano en la rejilla (Grid Target)
  //   // final int targetBeatMs = (currentMs / beatMs).round() * beatMs.round();
  //   //
  //   // // ⚡ COMPENSACIÓN DE LATENCIA (Ajuste de respuesta de salida de audio)
  //   // const int latencyOffset = 0;
  //   //
  //   // // 3. Posiciones exactas del conteo (Beats -5, -4, -3, -2)
  //   // final int msUno = targetBeatMs - (5 * beatMs).round() - latencyOffset;
  //   // final int msDos = targetBeatMs - (4 * beatMs).round() - latencyOffset;
  //   // final int msTres = targetBeatMs - (3 * beatMs).round() - latencyOffset;
  //   // final int msCuatro = targetBeatMs - (2 * beatMs).round() - latencyOffset;
  //
  //   final double beatMs = 60000.0 / song.metronome;
  //   final double currentMs = currentPosition.inMicroseconds / 1000.0;
  //
  //   // Beat más cercano
  //   final double targetBeatMs = (currentMs / beatMs).round() * beatMs;
  //
  //   // Conteo:
  //   // UNO    = -4 beats
  //   // DOS    = -3 beats
  //   // TRES   = -2 beats
  //   // CUATRO = -1 beat
  //   // final int msUno = (targetBeatMs - (4 * beatMs)).round();
  //
  //   // final int msDos = (targetBeatMs - (3 * beatMs)).round();
  //
  //   // final int msTres = (targetBeatMs - (2 * beatMs)).round();
  //
  //   // final int msCuatro = (targetBeatMs - beatMs).round();
  //   final int msCuatro = (currentMs - beatMs).round();
  //   final int msTres = (currentMs - (2 * beatMs)).round();
  //   final msDos = (currentMs - (3 * beatMs)).round();
  //   final msUno = (currentMs - (4 * beatMs)).round();
  //   // 4. SUPERCÁLCULO DE LA VOZ PRINCIPAL (Sin silencios)
  //   final Duration voiceDuration = _audioService.getTrackDuration(
  //     voice.name.toLowerCase(),
  //   );
  //   final int voiceDurationMs = voiceDuration.inMilliseconds;
  //
  //   // Calculamos cuántos beats completos (músicos) representa la duración de esta voz.
  //   // Al no tener silencios, asignamos la cantidad de compases/beats necesarios.
  //   int voiceBeats = (voiceDurationMs / beatMs).round();
  //   if (voiceBeats < 1) voiceBeats = 1; // Mínimo 1 beat de espacio rítmico
  //
  //   // La voz se ancla X beats atrás del Beat -5 ("Uno") para que empiece justo en un pulso
  //   final int msVoiceIntro = msUno - (voiceBeats * beatMs).round();
  //
  //   final String sharedGroupId = const Uuid().v4();
  //
  //   final List<VoiceEvent> eventsSong = [
  //     VoiceEvent(
  //       id: const Uuid().v4(),
  //       groupId: sharedGroupId,
  //       position: Duration(milliseconds: msVoiceIntro > 0 ? msVoiceIntro : 0),
  //       voice: voice,
  //     ),
  //     VoiceEvent(
  //       id: const Uuid().v4(),
  //       groupId: sharedGroupId,
  //       position: Duration(milliseconds: msUno > 0 ? msUno : 0),
  //       voice: VoiceModel(id: 'uno', name: 'uno', asset: ''),
  //     ),
  //     VoiceEvent(
  //       id: const Uuid().v4(),
  //       groupId: sharedGroupId,
  //       position: Duration(milliseconds: msDos > 0 ? msDos : 0),
  //       voice: VoiceModel(id: 'dos', name: 'dos', asset: ''),
  //     ),
  //     VoiceEvent(
  //       id: const Uuid().v4(),
  //       groupId: sharedGroupId,
  //       position: Duration(milliseconds: msTres > 0 ? msTres : 0),
  //       voice: VoiceModel(id: 'tres', name: 'tres', asset: ''),
  //     ),
  //     VoiceEvent(
  //       id: const Uuid().v4(),
  //       groupId: sharedGroupId,
  //       position: Duration(milliseconds: msCuatro > 0 ? msCuatro : 0),
  //       voice: VoiceModel(id: 'cuatro', name: 'cuatro', asset: ''),
  //     ),
  //   ];
  //
  //   final events = song.voiceEvents;
  //   events.addAll(eventsSong);
  //   song.voiceEvents = events;
  //
  //   await _databaseService.saveSong(song);
  //
  //   debugPrint('--- GRID MUSICAL GENERADO ---');
  //   debugPrint('Beat Target (Marca): $targetBeatMs ms');
  //   debugPrint(
  //     'Voz Principal ("${voice.name}"): $msVoiceIntro ms ($voiceBeats beat/s)',
  //   );
  //   debugPrint('Conteo 1, 2, 3, 4: $msUno, $msDos, $msTres, $msCuatro ms');
  //
  //   return song.voiceEvents;
  // }
  //
  // Future<List<VoiceEvent>> saveEvent(VoiceModel voice, SongEntity song) async {
  //   if (song.metronome <= 0) {
  //     debugPrint('La canción no tiene un BPM válido');
  //     return [];
  //   }
  //   _audioService.pauseAll();
  //   final currentPosition = await _audioService.getPosition();
  //
  //   final double beatMs = 60000 / song.metronome;
  //   final int currentMs = currentPosition.inMilliseconds;
  //
  //   // 1. Cuantización al beat más cercano
  //   final int targetBeatMs = (currentMs / beatMs).round() * beatMs.toInt();
  //
  //   // ⚡ OFFSET DE COMPENSACIÓN DE LATENCIA (Ajustable)
  //   const int latencyOffset = 0;
  //
  //   // 2. Obtener duración real del audio de la voz (ej: "final_intro_por_4")
  //   // Supongamos que _audioService devuelve Duration
  //   final voiceDuration = _audioService.getTrackDuration(
  //     voice.name.toLowerCase(),
  //   );
  //   final int voiceDurationMs = voiceDuration.inMilliseconds;
  //
  //   // 3. Determinar cuántos beats enteros necesita la voz para no sobreescribir el "uno"
  //   // CEIL asegura que no pisemos el conteo si el audio dura ej. 2.1 beats.
  //   final int voiceBeats = (voiceDurationMs / beatMs).ceil();
  //
  //   // Si la voz es muy corta, le asignamos como mínimo 1 beat de espacio
  //   final int effectiveVoiceBeats = voiceBeats > 0 ? voiceBeats : 1;
  //
  //   // 4. Tiempos exactos alineados a la rejilla de tempo (Grid)
  //   final int msUno = targetBeatMs - (5 * beatMs).toInt() - latencyOffset;
  //   final int msDos = targetBeatMs - (4 * beatMs).toInt() - latencyOffset;
  //   final int msTres = targetBeatMs - (3 * beatMs).toInt() - latencyOffset;
  //   final int msCuatro = targetBeatMs - (2 * beatMs).toInt() - latencyOffset;
  //
  //   // La voz arranca X beats antes del "uno"
  //   final int msVoiceIntro = msUno - (effectiveVoiceBeats * beatMs).toInt();
  //
  //   final String sharedGroupId = const Uuid().v4();
  //
  //   final List<VoiceEvent> eventsSong = [
  //     VoiceEvent(
  //       id: const Uuid().v4(),
  //       groupId: sharedGroupId,
  //       position: Duration(milliseconds: msVoiceIntro > 0 ? msVoiceIntro : 0),
  //       voice: voice,
  //     ),
  //     VoiceEvent(
  //       id: const Uuid().v4(),
  //       groupId: sharedGroupId,
  //       position: Duration(milliseconds: msUno > 0 ? msUno : 0),
  //       voice: VoiceModel(id: 'uno', name: 'uno', asset: ''),
  //     ),
  //     VoiceEvent(
  //       id: const Uuid().v4(),
  //       groupId: sharedGroupId,
  //       position: Duration(milliseconds: msDos > 0 ? msDos : 0),
  //       voice: VoiceModel(id: 'dos', name: 'dos', asset: ''),
  //     ),
  //     VoiceEvent(
  //       id: const Uuid().v4(),
  //       groupId: sharedGroupId,
  //       position: Duration(milliseconds: msTres > 0 ? msTres : 0),
  //       voice: VoiceModel(id: 'tres', name: 'tres', asset: ''),
  //     ),
  //     VoiceEvent(
  //       id: const Uuid().v4(),
  //       groupId: sharedGroupId,
  //       position: Duration(milliseconds: msCuatro > 0 ? msCuatro : 0),
  //       voice: VoiceModel(id: 'cuatro', name: 'cuatro', asset: ''),
  //     ),
  //   ];
  //
  //   final events = song.voiceEvents;
  //   events.addAll(eventsSong);
  //   song.voiceEvents = events;
  //   _databaseService.saveSong(song);
  //
  //   debugPrint('Eventos calculados dinámicamente según la duración del audio.');
  //
  //   return song.voiceEvents;
  // }

  // Future<List<VoiceEvent>> saveEvent(VoiceModel voice, SongEntity song) async {
  //   if (song.metronome <= 0) {
  //     debugPrint('La canción no tiene un BPM válido');
  //     return [];
  //   }
  //   _audioService.pauseAll();
  //   final currentPosition = await _audioService.getPosition();
  //
  //   final beatMs = (60000 / song.metronome).round();
  //   final currentMs = currentPosition.inMilliseconds;
  //
  //   // Cuantización a la cuadrícula del beat
  //   final int targetBeatMs = (currentMs / beatMs).round() * beatMs;
  //
  //   // ⚡ OFFSET DE COMPENSACIÓN DE LATENCIA (Ajustable)
  //   // Si la voz o el conteo aún se sienten un pelo tarde, restamos unos milisegundos
  //   // para dispararlos un instante antes y que al oído humano impacten exactamente a tiempo.
  //   const int latencyOffset =
  //       0; // Prueba subiendo a 45 o bajando a 25 según lo sientas
  //
  //   final int msVoiceIntro =
  //       targetBeatMs - (7.2 * beatMs).toInt() - latencyOffset;
  //   final int msUno = targetBeatMs - (5 * beatMs) - latencyOffset;
  //   final int msDos = targetBeatMs - (4 * beatMs) - latencyOffset;
  //   final int msTres = targetBeatMs - (3 * beatMs) - latencyOffset;
  //   final int msCuatro = targetBeatMs - (2 * beatMs) - latencyOffset;
  //
  //   final String sharedGroupId = Uuid().v4();
  //
  //   final List<VoiceEvent> eventsSong = [
  //     VoiceEvent(
  //       id: Uuid().v4(),
  //       groupId: sharedGroupId,
  //       position: Duration(milliseconds: msVoiceIntro > 0 ? msVoiceIntro : 0),
  //       voice: voice,
  //     ),
  //     VoiceEvent(
  //       id: Uuid().v4(),
  //       groupId: sharedGroupId,
  //       position: Duration(milliseconds: msUno > 0 ? msUno : 0),
  //       voice: VoiceModel(id: 'uno', name: 'uno', asset: ''),
  //     ),
  //     VoiceEvent(
  //       id: Uuid().v4(),
  //       groupId: sharedGroupId,
  //       position: Duration(milliseconds: msDos > 0 ? msDos : 0),
  //       voice: VoiceModel(id: 'dos', name: 'dos', asset: ''),
  //     ),
  //     VoiceEvent(
  //       id: Uuid().v4(),
  //       groupId: sharedGroupId,
  //       position: Duration(milliseconds: msTres > 0 ? msTres : 0),
  //       voice: VoiceModel(id: 'tres', name: 'tres', asset: ''),
  //     ),
  //     VoiceEvent(
  //       id: Uuid().v4(),
  //       groupId: sharedGroupId,
  //       position: Duration(milliseconds: msCuatro > 0 ? msCuatro : 0),
  //       voice: VoiceModel(id: 'cuatro', name: 'cuatro', asset: ''),
  //     ),
  //   ];
  //
  //   final events = song.voiceEvents;
  //   events.addAll(eventsSong);
  //   song.voiceEvents = events;
  //   _databaseService.saveSong(song);
  //
  //   debugPrint('Eventos con compensación de latencia guardados correctamente.');
  //
  //   return song.voiceEvents;
  // }

  Future<List<VoiceEvent>> deleteEvent(
    VoiceEvent voiceEvent,
    SongEntity song,
  ) async {
    final events = song.voiceEvents;

    // Buscamos el índice exacto donde empieza el bloque que comparte este groupId
    // final index = events.indexWhere(
    //   (event) => event.groupId == voiceEvent.groupId,
    // );
    final index = events.indexWhere(
      (event) =>
          event.position.inMilliseconds == voiceEvent.position.inMilliseconds &&
          event.voice.id == voiceEvent.voice.id,
    );
    print('Índice real del bloque: $index');

    if (index != -1) {
      int countToRemove = 5;
      int endIndex = (index + countToRemove).clamp(0, events.length);

      events.removeRange(index, endIndex);
      song.voiceEvents = events;
      _databaseService.saveSong(song);

      print(
        "Se eliminó el bloque completo de 5 eventos a partir del índice $index",
      );
      return song.voiceEvents;
    } else {
      print("No se encontró el grupo de eventos de voz.");
    }

    return song.voiceEvents;
  }
}

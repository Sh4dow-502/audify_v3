import 'package:audify_v3/main.dart';
import 'package:audify_v3/models/voice_model.dart';
import 'package:flutter/services.dart';

Future<List<VoiceModel>> getVoiceModels() async {
  // 1. Cargamos el manifiesto de assets de forma oficial y moderna
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

  // 2. Obtenemos todas las rutas y filtramos las que inicien con nuestra carpeta
  final assetPaths = manifest.listAssets();
  final voicePaths = assetPaths
      .where((path) => path.startsWith('assets/voices/'))
      .toList();

  // 3. Mapeamos cada ruta a tu objeto VoiceModel
  return voicePaths.map((path) {
    // Opcional: Extraer el nombre del archivo sin extensión (ej. "audio_1.mp3" -> "audio_1")
    final fileName = path.split('/').last;
    final nameWithoutExtension = fileName.split('.').first;

    return VoiceModel(
      id: nameWithoutExtension,
      name: nameWithoutExtension
          .capitalize(), // Usando la extensión para capitalizar
      asset: path,
    );
  }).toList();
}

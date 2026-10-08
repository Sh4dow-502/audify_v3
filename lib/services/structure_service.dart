import 'package:audify_v3/models/song_entity.dart';
import 'package:audify_v3/objectbox.g.dart';

class StructureService {
  final Box<SongEntity> _songBox;
  StructureService(Store store) : _songBox = store.box<SongEntity>();

  Future<void> saveSong(SongEntity song) async {
    _songBox.put(song);
  }
}

import 'package:audify_v3/models/song_entity.dart';
import 'package:audify_v3/objectbox.g.dart';

class DatabaseService {
  final Box<SongEntity> _songBox;
  DatabaseService(Store store) : _songBox = store.box<SongEntity>();

  Future<SongEntity?> getSongById(String songId) async {
    return _songBox
        .query(SongEntity_.songId.equals(songId))
        .build()
        .findFirst();
  }

  Future<void> saveSong(SongEntity song) async {
    _songBox.put(song);
  }
}

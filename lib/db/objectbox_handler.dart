import 'package:audify_v3/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ObjectBox {
  late final Store store;

  ObjectBox._create(this.store);

  /// Crea una instancia de ObjectBox y abre el Store
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = openStore(directory: p.join(docsDir.path, "obx-db"));
    return ObjectBox._create(await store);
  }
}

import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../data/local/favorite_entity.dart';
import '../data/local/name_entity.dart';

/// Owns the single Isar instance. Add new collection schemas to [_schemas].
class DatabaseService extends GetxService {
  static const List<CollectionSchema<dynamic>> _schemas = [
    NameEntitySchema,
    FavoriteEntitySchema,
  ];

  late final Isar isar;

  Future<DatabaseService> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(_schemas, directory: dir.path, name: 'habesha');
    return this;
  }

  @override
  void onClose() {
    isar.close();
    super.onClose();
  }
}

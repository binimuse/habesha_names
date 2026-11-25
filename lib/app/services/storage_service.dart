import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Lightweight key-value storage for preferences (theme, language, flags).
/// Structured app data belongs in Isar, not here.
class StorageService extends GetxService {
  late final GetStorage _box;

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    return this;
  }

  T? read<T>(String key) => _box.read<T>(key);

  Future<void> write(String key, Object value) => _box.write(key, value);

  Future<void> remove(String key) => _box.remove(key);
}

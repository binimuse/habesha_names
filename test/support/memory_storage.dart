import 'package:habesha_names/app/services/storage_service.dart';

/// [StorageService] backed by a map (no GetStorage / path_provider).
class MemoryStorageService extends StorageService {
  final Map<String, Object> values = {};

  @override
  Future<StorageService> init() async => this;

  @override
  T? read<T>(String key) => values[key] as T?;

  @override
  Future<void> write(String key, Object value) async => values[key] = value;

  @override
  Future<void> remove(String key) async => values.remove(key);
}

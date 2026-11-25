import '../models/name_model.dart';

/// On-device store of names (Isar in the app, in-memory in tests).
abstract interface class NamesLocalSource {
  Future<int> count();
  Future<List<NameModel>> getAll();
  Future<void> upsertAll(List<NameModel> names);
  Future<void> deleteByIds(List<String> ids);
}

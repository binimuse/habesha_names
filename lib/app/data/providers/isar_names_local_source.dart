import 'package:isar_community/isar.dart';

import '../local/name_entity.dart';
import '../models/name_model.dart';
import 'names_local_source.dart';

class IsarNamesLocalSource implements NamesLocalSource {
  IsarNamesLocalSource(this._isar);

  final Isar _isar;

  IsarCollection<NameEntity> get _names => _isar.nameEntitys;

  @override
  Future<int> count() => _names.count();

  @override
  Future<List<NameModel>> getAll() async {
    final List<NameEntity> rows = await _names.where().findAll();
    return [for (final NameEntity r in rows) r.toModel()];
  }

  @override
  Future<void> upsertAll(List<NameModel> names) async {
    if (names.isEmpty) return;
    await _isar.writeTxn(
      () => _names.putAll([for (final n in names) NameEntity.fromModel(n)]),
    );
  }

  @override
  Future<void> deleteByIds(List<String> ids) async {
    if (ids.isEmpty) return;
    await _isar.writeTxn(() => _names.deleteAllByNameId(ids));
  }
}

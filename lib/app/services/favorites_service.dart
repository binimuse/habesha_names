import 'dart:async';

import 'package:get/get.dart';

import '../data/models/favorite.dart';
import '../data/repositories/favorites_repository.dart';
import 'analytics_service.dart';

/// Reactive bridge between [FavoritesRepository] and the UI (hearts,
/// Favorites tab). Syncs in the background shortly after each change.
class FavoritesService extends GetxService {
  FavoritesService(this._repo);

  static const Duration _syncDelay = Duration(seconds: 2);

  final FavoritesRepository _repo;
  final RxList<Favorite> items = <Favorite>[].obs;
  final RxSet<String> ids = <String>{}.obs;

  StreamSubscription<List<Favorite>>? _sub;
  Timer? _syncTimer;

  Future<FavoritesService> init() async {
    _sub = _repo.changes.listen(_apply);
    _apply(await _repo.getAll());
    unawaited(_repo.sync());
    return this;
  }

  bool isFavorite(String nameId) => ids.contains(nameId);

  Favorite? byId(String nameId) =>
      items.firstWhereOrNull((f) => f.nameId == nameId);

  Future<void> add(String nameId) async {
    await _repo.add(nameId);
    unawaited(AnalyticsService.maybe?.favorite(nameId, added: true));
    _changed();
  }

  Future<bool> toggle(String nameId) async {
    final bool now = await _repo.toggle(nameId);
    unawaited(AnalyticsService.maybe?.favorite(nameId, added: now));
    _changed();
    return now;
  }

  /// Removes and returns the removed favorite (for undo).
  Future<Favorite?> remove(String nameId) async {
    final Favorite? removed = byId(nameId);
    await _repo.remove(nameId);
    unawaited(AnalyticsService.maybe?.favorite(nameId, added: false));
    _changed();
    return removed;
  }

  Future<void> restore(Favorite favorite) async {
    await _repo.restore(favorite);
    _changed();
  }

  /// Removes every favorite; returns them (with notes) for undo.
  Future<List<Favorite>> clearAll() async {
    final List<Favorite> removed = items.toList();
    for (final Favorite f in removed) {
      await _repo.remove(f.nameId);
    }
    _changed();
    return removed;
  }

  Future<void> restoreAll(List<Favorite> favorites) async {
    for (final Favorite f in favorites) {
      await _repo.restore(f);
    }
    _changed();
  }

  Future<void> setNote(String nameId, String note) async {
    await _repo.setNote(nameId, note);
    _changed();
  }

  void _apply(List<Favorite> list) {
    items.assignAll(list);
    ids
      ..clear()
      ..addAll(list.map((f) => f.nameId));
  }

  /// Reflect our own change right away (the repo stream arrives a microtask
  /// later), then sync in the background.
  void _changed() {
    _apply(_repo.current);
    _scheduleSync();
  }

  void _scheduleSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer(_syncDelay, () => unawaited(_repo.sync()));
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    _sub?.cancel();
    super.onClose();
  }
}

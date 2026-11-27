import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/base/async_controller.dart';
import '../../../data/models/favorite.dart';
import '../../../data/models/name_model.dart';
import '../../../data/repositories/names_repository.dart';
import '../../../routes/app_nav.dart';
import '../../../services/favorites_service.dart';
import '../../../translations/locale_keys.dart';

class FavoriteEntry {
  const FavoriteEntry(this.favorite, this.name);

  final Favorite favorite;
  final NameModel name;
}

class FavoritesController extends AsyncListController<FavoriteEntry> {
  FavoritesController(this._favorites, this._names);

  static const int compareCount = 2;

  final FavoritesService _favorites;
  final NamesRepository _names;

  final RxBool selecting = false.obs;
  final RxList<String> selected = <String>[].obs;

  bool get canCompare => selected.length == compareCount;

  @override
  Stream<void> get refreshTrigger => _favorites.items.stream;

  @override
  Future<List<FavoriteEntry>> fetch() async {
    final List<Favorite> favs = _favorites.items.toList();
    final Map<String, NameModel> names = {
      for (final NameModel n in await _names.getByIds(
        favs.map((f) => f.nameId),
      ))
        n.id: n,
    };
    return [
      for (final Favorite f in favs)
        if (names[f.nameId] case final NameModel n) FavoriteEntry(f, n),
    ];
  }

  // Compare mode ---------------------------------------------------------------

  void startCompare() {
    selected.clear();
    selecting.value = true;
  }

  void cancelCompare() {
    selecting.value = false;
    selected.clear();
  }

  /// Keeps at most two; picking a third replaces the oldest pick.
  void toggleSelected(String nameId) {
    if (selected.remove(nameId)) return;
    if (selected.length >= compareCount) selected.removeAt(0);
    selected.add(nameId);
  }

  void compare() {
    if (!canCompare) return;
    final String first = selected[0];
    final String second = selected[1];
    cancelCompare();
    AppNav.openCompare(first, second);
  }

  // Item actions ---------------------------------------------------------------

  void onTap(FavoriteEntry e, String heroTag) {
    if (selecting.value) {
      toggleSelected(e.name.id);
    } else {
      AppNav.openName(e.name, heroTag: heroTag);
    }
  }

  Future<void> saveNote(String nameId, String note) =>
      _favorites.setNote(nameId, note);

  bool get hasFavorites => _favorites.items.isNotEmpty;

  /// Asks first, clears everything, then offers Undo (notes come back too).
  Future<void> clearAll() async {
    final int count = _favorites.items.length;
    if (count == 0) return;
    final BuildContext? ctx = Get.context;
    final ScaffoldMessengerState? messenger = ctx == null
        ? null
        : ScaffoldMessenger.maybeOf(ctx);
    final bool? ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text(LocaleKeys.favoritesClearTitle.tr),
        content: Text(
          LocaleKeys.favoritesClearMessage.trParams({'count': '$count'}),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(LocaleKeys.favoritesCancel.tr),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text(LocaleKeys.favoritesClearConfirm.tr),
          ),
        ],
      ),
    );
    if (ok != true) return;
    cancelCompare();
    final List<Favorite> removed = await _favorites.clearAll();
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.favoritesCleared.tr),
          action: SnackBarAction(
            label: LocaleKeys.favoritesUndo.tr,
            onPressed: () => _favorites.restoreAll(removed),
          ),
        ),
      );
  }

  /// Removes with an Undo snackbar.
  Future<void> remove(String nameId) async {
    final BuildContext? ctx = Get.context;
    final ScaffoldMessengerState? messenger = ctx == null
        ? null
        : ScaffoldMessenger.maybeOf(ctx);
    final Favorite? removed = await _favorites.remove(nameId);
    selected.remove(nameId);
    if (removed == null || messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.favoritesRemoved.tr),
          action: SnackBarAction(
            label: LocaleKeys.favoritesUndo.tr,
            onPressed: () => _favorites.restore(removed),
          ),
        ),
      );
  }
}

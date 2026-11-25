import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/base/async_controller.dart';
import '../../../core/text/alphabets.dart';
import '../../../core/utils/labels.dart';
import '../../../data/models/gender.dart';
import '../../../data/models/name_filter.dart';
import '../../../data/models/name_model.dart';
import '../../../data/models/vocabulary.dart';
import '../../../data/repositories/names_repository.dart';
import '../../../services/analytics_service.dart';
import '../../../routes/app_nav.dart';

enum IndexScript { latin, geez }

/// Syllable choices offered in the filter sheet.
enum SyllableBucket {
  short(1, 2),
  medium(3, 3),
  long(4, null);

  const SyllableBucket(this.min, this.max);

  final int min;
  final int? max;

  static SyllableBucket? of(NameFilter f) {
    for (final SyllableBucket b in values) {
      if (f.minSyllables == b.min && f.maxSyllables == b.max) return b;
    }
    return null;
  }
}

/// Named `NameSearchController` to avoid clashing with Flutter's
/// material `SearchController`.
class NameSearchController extends AsyncListController<NameModel> {
  NameSearchController(this._names);

  static const Duration _debounce = Duration(milliseconds: 300);

  final NamesRepository _names;

  final TextEditingController textController = TextEditingController();
  final RxString query = ''.obs;

  /// Applied filter (includes the letter picked in the index).
  final Rx<NameFilter> filter = NameFilter.none.obs;

  /// Being edited in the filter sheet; applied on "Show names".
  final Rx<NameFilter> draft = NameFilter.none.obs;

  final Rx<IndexScript> script =
      (Labels.isAmharic ? IndexScript.geez : IndexScript.latin).obs;
  final RxList<String> themeOptions = <String>[].obs;

  bool get hasQuery => query.value.trim().isNotEmpty;

  /// Nothing typed or filtered: show the browse prompt.
  bool get isIdle => !hasQuery && filter.value.isEmpty;

  List<String> get letters =>
      script.value == IndexScript.latin ? Alphabets.latin : Alphabets.geez;

  List<String> get languageOptions => Vocabulary.languages;
  List<String> get faithOptions => Vocabulary.faiths;

  @override
  bool get loadOnInit => false;

  @override
  Stream<void> get refreshTrigger => _names.changes;

  @override
  void onInit() {
    super.onInit();
    debounce<String>(query, (_) => load(), time: _debounce);
    _loadThemeOptions();
  }

  @override
  Future<List<NameModel>> fetch() async {
    if (hasQuery) {
      final List<NameModel> hits = await _names.search(
        query.value,
        filter: filter.value,
      );
      unawaited(
        AnalyticsService.maybe?.search(
          query.value.trim(),
          results: hits.length,
        ),
      );
      return hits;
    }
    if (!filter.value.isEmpty) return _names.filter(filter.value);
    return const [];
  }

  // Query ----------------------------------------------------------------------

  void onQueryChanged(String value) => query.value = value;

  void clearQuery() {
    textController.clear();
    query.value = '';
  }

  // Letter index ---------------------------------------------------------------

  void toggleScript() {
    script.value = script.value == IndexScript.latin
        ? IndexScript.geez
        : IndexScript.latin;
  }

  /// Tapping the selected letter again clears it.
  void selectLetter(String letter) {
    final String? current = filter.value.firstLetter;
    applyFilter(
      filter.value.copyWith(
        firstLetter: () => current == letter ? null : letter,
      ),
    );
  }

  // Filters --------------------------------------------------------------------

  void applyFilter(NameFilter value) {
    filter.value = value;
    load();
  }

  void clearFilters() => applyFilter(NameFilter.none);

  void openDraft() => draft.value = filter.value;

  void applyDraft() => applyFilter(draft.value);

  void resetDraft() =>
      draft.value = NameFilter(firstLetter: draft.value.firstLetter);

  void toggleDraftGender(Gender g) => draft.value = draft.value.copyWith(
    genders: _toggle(draft.value.genders, g),
  );

  void toggleDraftLanguage(String code) => draft.value = draft.value.copyWith(
    languages: _toggle(draft.value.languages, code),
  );

  void toggleDraftFaith(String code) => draft.value = draft.value.copyWith(
    faiths: _toggle(draft.value.faiths, code),
  );

  void toggleDraftTheme(String code) => draft.value = draft.value.copyWith(
    themes: _toggle(draft.value.themes, code),
  );

  void toggleDraftSyllables(SyllableBucket bucket) {
    final bool same = SyllableBucket.of(draft.value) == bucket;
    draft.value = draft.value.copyWith(
      minSyllables: () => same ? null : bucket.min,
      maxSyllables: () => same ? null : bucket.max,
    );
  }

  void setDraftEasyAbroad(bool value) =>
      draft.value = draft.value.copyWith(easyAbroad: () => value ? true : null);

  void openName(NameModel name, String heroTag) =>
      AppNav.openName(name, heroTag: heroTag);

  // ---------------------------------------------------------------------------

  Future<void> _loadThemeOptions() async {
    try {
      final groups = await _names.themeGroups(minNames: 1);
      themeOptions.assignAll(groups.map((g) => g.theme));
    } catch (_) {
      // Filter sheet just shows no themes.
    }
  }

  static Set<T> _toggle<T>(Set<T> set, T value) =>
      set.contains(value) ? ({...set}..remove(value)) : {...set, value};

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}

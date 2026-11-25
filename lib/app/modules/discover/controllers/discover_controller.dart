import 'package:get/get.dart';

import '../../../core/base/async_controller.dart';
import '../../../data/models/name_filter.dart';
import '../../../data/models/name_model.dart';
import '../../../data/repositories/names_repository.dart';
import '../../../routes/app_nav.dart';
import '../../../services/preferences_service.dart';
import '../../shell/controllers/shell_controller.dart';

class DiscoverData {
  const DiscoverData({
    required this.nameOfDay,
    required this.forYou,
    required this.themes,
    this.trending = const [],
  });

  final NameModel? nameOfDay;
  final List<NameModel> forYou;
  final List<ThemeGroup> themes;
  final List<NameModel> trending;
}

class DiscoverController extends AsyncController<DiscoverData> {
  DiscoverController(this._names, this._prefs);

  static const int _forYouCount = 12;

  final NamesRepository _names;
  final PreferencesService _prefs;

  @override
  Stream<void> get refreshTrigger => _names.changes;

  @override
  void onInit() {
    super.onInit();
    ever(_prefs.prefs, (_) => load(silent: true));
  }

  @override
  Future<DiscoverData> fetch() async {
    final NameFilter filter = _prefs.prefs.value.toFilter();
    final NameModel? today = await _names.nameOfTheDay(
      DateTime.now(),
      filter: filter,
    );
    final List<NameModel> matching = await _names.filter(filter);
    List<ThemeGroup> themes = await _names.themeGroups(filter: filter);
    if (themes.isEmpty) themes = await _names.themeGroups();
    final List<NameModel> trending = await _names.trending();
    return DiscoverData(
      nameOfDay: today,
      forYou: matching
          .where((n) => n.id != today?.id)
          .take(_forYouCount)
          .toList(),
      themes: themes,
      trending: trending,
    );
  }

  @override
  bool isEmptyValue(DiscoverData value) =>
      value.nameOfDay == null && value.forYou.isEmpty;

  void openName(NameModel name, String heroTag) =>
      AppNav.openName(name, heroTag: heroTag);

  void seeAllForYou() =>
      Get.find<ShellController>().showInSearch(_prefs.prefs.value.toFilter());

  void seeTheme(String theme) =>
      Get.find<ShellController>().showInSearch(NameFilter(themes: {theme}));
}

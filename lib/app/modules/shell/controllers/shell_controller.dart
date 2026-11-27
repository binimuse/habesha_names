import 'dart:async';

import 'package:get/get.dart';

import '../../../data/models/couple.dart';
import '../../../data/models/name_filter.dart';
import '../../../data/models/name_model.dart';
import '../../../data/repositories/names_repository.dart';
import '../../../routes/app_nav.dart';
import '../../../routes/app_pages.dart';
import '../../../services/analytics_service.dart';
import '../../../services/notifications_service.dart';
import '../../../services/partner_service.dart';
import '../../search/controllers/search_controller.dart';

enum ShellTab { discover, search, swipe, favorites, studio }

class ShellController extends GetxController {
  ShellController(this._partner);

  final PartnerService _partner;
  StreamSubscription<NameMatch>? _matchSub;

  final Rx<ShellTab> currentTab = ShellTab.discover.obs;

  bool get isOnFirstTab => currentTab.value == ShellTab.discover;

  @override
  void onInit() {
    super.onInit();
    _matchSub = _partner.newMatches.listen(_announceMatch);
    if (Get.isRegistered<NotificationsService>()) {
      ever(Get.find<NotificationsService>().pendingNameId, _openFromPush);
    }
  }

  @override
  void onReady() {
    super.onReady();
    // A notification may have launched the app before the shell existed.
    if (Get.isRegistered<NotificationsService>()) {
      _openFromPush(Get.find<NotificationsService>().pendingNameId.value);
    }
  }

  Future<void> _openFromPush(String? nameId) async {
    if (nameId == null) return;
    Get.find<NotificationsService>().pendingNameId.value = null;
    final NameModel? n = await Get.find<NamesRepository>().getById(nameId);
    if (n != null) await AppNav.openName(n);
  }

  void selectIndex(int index) => _select(ShellTab.values[index]);

  void _select(ShellTab tab) => currentTab.value = tab;

  /// Android back: return to Discover before leaving the app.
  void onBackFromOtherTab() => _select(ShellTab.discover);

  /// Jumps to the Search tab showing names that match [filter].
  void showInSearch(NameFilter filter) {
    Get.find<NameSearchController>()
      ..clearQuery()
      ..applyFilter(filter);
    _select(ShellTab.search);
  }

  /// "It's a match!" — one at a time.
  void _announceMatch(NameMatch match) {
    unawaited(
      AnalyticsService.maybe?.match(match.nameId, superLike: match.superLike),
    );
    if (Get.currentRoute == Routes.match) return;
    Get.toNamed<void>(Routes.match, arguments: match);
  }

  @override
  void onClose() {
    _matchSub?.cancel();
    super.onClose();
  }
}

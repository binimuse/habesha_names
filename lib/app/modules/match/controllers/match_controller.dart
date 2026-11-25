import 'package:get/get.dart';

import '../../../core/base/async_controller.dart';
import '../../../data/models/couple.dart';
import '../../../data/models/name_model.dart';
import '../../../data/repositories/names_repository.dart';
import '../../../routes/app_nav.dart';
import '../../../services/partner_service.dart';

/// "It's a match!" for the [NameMatch] passed as route arguments.
class MatchController extends AsyncController<NameModel?> {
  MatchController(this.match, this._names, this._partner);

  final NamesRepository _names;
  final PartnerService _partner;

  final NameMatch? match;

  static const String heroTag = 'match/name';

  @override
  Future<NameModel?> fetch() async {
    final NameMatch? m = match;
    if (m == null) return null;
    await _partner.markSeen([m.nameId]);
    return _names.getById(m.nameId);
  }

  @override
  bool isEmptyValue(NameModel? value) => value == null;

  void viewName() {
    final NameModel? n = state;
    if (n == null) return;
    Get.back<void>();
    AppNav.openName(n, heroTag: heroTag);
  }

  void keepSwiping() => Get.back<void>();
}

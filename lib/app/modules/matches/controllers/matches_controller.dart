import '../../../core/base/async_controller.dart';
import '../../../data/models/couple.dart';
import '../../../data/models/name_model.dart';
import '../../../data/repositories/names_repository.dart';
import '../../../routes/app_nav.dart';
import '../../../services/partner_service.dart';

class MatchEntry {
  const MatchEntry(this.match, this.name);

  final NameMatch match;
  final NameModel name;
}

class MatchesController extends AsyncListController<MatchEntry> {
  MatchesController(this._partner, this._names);

  final PartnerService _partner;
  final NamesRepository _names;

  @override
  Stream<void> get refreshTrigger => _partner.matches.stream;

  @override
  Future<List<MatchEntry>> fetch() async {
    final List<NameMatch> matches = _partner.matches.toList();
    final Map<String, NameModel> names = {
      for (final NameModel n in await _names.getByIds(
        matches.map((m) => m.nameId),
      ))
        n.id: n,
    };
    // Everything on screen counts as seen.
    await _partner.markSeen(matches.map((m) => m.nameId));
    return [
      for (final NameMatch m in matches)
        if (names[m.nameId] case final NameModel n) MatchEntry(m, n),
    ];
  }

  void open(MatchEntry e, String heroTag) =>
      AppNav.openName(e.name, heroTag: heroTag);
}

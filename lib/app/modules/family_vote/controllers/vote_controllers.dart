import 'dart:async';

import 'package:get/get.dart';

import '../../../core/base/async_controller.dart';
import '../../../data/models/family_vote.dart';
import '../../../data/models/name_model.dart';
import '../../../data/repositories/names_repository.dart';
import '../../../routes/app_pages.dart';
import '../../../services/favorites_service.dart';
import '../../../services/vote_service.dart';
import '../../../translations/locale_keys.dart';

/// Pick 2–6 favorites, create the vote, share the link, open results.
class VoteCreateController extends AsyncListController<NameModel> {
  VoteCreateController(this._votes, this._favorites, this._names);

  final VoteService _votes;
  final FavoritesService _favorites;
  final NamesRepository _names;

  final RxList<String> selected = <String>[].obs;
  final RxBool creating = false.obs;
  final RxnString errorKey = RxnString();

  bool get isAvailable => _votes.isAvailable;
  bool get canCreate =>
      selected.length >= FamilyVote.minOptions &&
      selected.length <= FamilyVote.maxOptions &&
      !creating.value;

  @override
  Future<List<NameModel>> fetch() =>
      _names.getByIds(_favorites.items.map((f) => f.nameId));

  void toggle(String id) {
    if (selected.remove(id)) return;
    if (selected.length < FamilyVote.maxOptions) selected.add(id);
  }

  Future<void> create() async {
    errorKey.value = null;
    if (!canCreate) {
      errorKey.value = LocaleKeys.votePickMore;
      return;
    }
    creating.value = true;
    try {
      final List<NameModel> names = [
        for (final NameModel n in state ?? const [])
          if (selected.contains(n.id)) n,
      ];
      final String id = await _votes.create(
        names,
        title: LocaleKeys.voteQuestion.tr,
      );
      unawaited(_votes.share(id));
      await Get.offNamed<void>(Routes.voteResults, arguments: id);
    } on VoteException {
      errorKey.value = LocaleKeys.voteUnavailable;
    } catch (_) {
      errorKey.value = LocaleKeys.partnerErrorGeneric;
    } finally {
      creating.value = false;
    }
  }
}

/// Live results for one vote (route argument: the vote id).
class VoteResultsController extends GetxController {
  VoteResultsController(this.voteId, this._votes);

  final String voteId;
  final VoteService _votes;

  final Rxn<FamilyVote> vote = Rxn<FamilyVote>();
  final RxList<Ballot> ballots = <Ballot>[].obs;
  final RxBool loading = true.obs;
  final RxBool missing = false.obs;

  StreamSubscription<FamilyVote?>? _voteSub;
  StreamSubscription<List<Ballot>>? _ballotSub;

  VoteTally? get tally {
    final FamilyVote? v = vote.value;
    return v == null ? null : VoteTally(v, ballots);
  }

  String get link => VoteService.linkFor(voteId);

  @override
  void onInit() {
    super.onInit();
    _voteSub = _votes
        .watchVote(voteId)
        .listen(
          (v) {
            loading.value = false;
            missing.value = v == null;
            vote.value = v;
          },
          onError: (Object _) {
            loading.value = false;
            missing.value = true;
          },
        );
    _ballotSub = _votes.watchBallots(voteId).listen(ballots.assignAll);
  }

  Future<void> share() => _votes.share(voteId);

  Future<void> closeVoting() => _votes.close(voteId);

  @override
  void onClose() {
    _voteSub?.cancel();
    _ballotSub?.cancel();
    super.onClose();
  }
}

/// The user's votes.
class VotesController extends GetxController {
  VotesController(this._votes);

  final VoteService _votes;

  RxList<FamilyVote> get votes => _votes.myVotes;
  bool get isAvailable => _votes.isAvailable;

  @override
  void onInit() {
    super.onInit();
    unawaited(_votes.watchMine());
  }

  void open(FamilyVote v) =>
      Get.toNamed<void>(Routes.voteResults, arguments: v.id);

  void create() => Get.toNamed<void>(Routes.voteCreate);
}

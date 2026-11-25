import 'dart:async';

import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../core/utils/app_share.dart';
import '../core/constants/app_constants.dart';
import '../data/models/family_vote.dart';
import '../data/models/name_model.dart';
import '../data/providers/vote_remote.dart';
import '../translations/locale_keys.dart';

class VoteException implements Exception {
  const VoteException(this.reason);

  final String reason;

  @override
  String toString() => 'VoteException($reason)';
}

/// Family vote: create a ballot from favorites, share a web link, watch
/// results live.
class VoteService extends GetxService {
  VoteService(this._remote);

  final VoteRemote _remote;

  final RxList<FamilyVote> myVotes = <FamilyVote>[].obs;
  StreamSubscription<List<FamilyVote>>? _mineSub;

  bool get isAvailable => _remote.isAvailable;

  /// Public web page for [voteId] (Firebase Hosting, no install needed).
  static String linkFor(String voteId) => '${AppConfig.voteBaseUrl}$voteId';

  Future<void> watchMine() async {
    if (!isAvailable || _mineSub != null) return;
    final String? uid = await _remote.ensureUid();
    if (uid == null) return;
    _mineSub = _remote.watchMine(uid).listen(myVotes.assignAll);
  }

  Future<String> create(List<NameModel> names, {required String title}) async {
    if (names.length < FamilyVote.minOptions ||
        names.length > FamilyVote.maxOptions) {
      throw const VoteException('options');
    }
    if (!isAvailable) throw const VoteException('unavailable');
    final String? uid = await _remote.ensureUid();
    if (uid == null) throw const VoteException('unavailable');
    final String id = await _remote.create(
      ownerUid: uid,
      title: title,
      options: [for (final n in names) VoteOption.fromName(n)],
    );
    unawaited(watchMine());
    return id;
  }

  Stream<FamilyVote?> watchVote(String id) => _remote.watchVote(id);
  Stream<List<Ballot>> watchBallots(String id) => _remote.watchBallots(id);

  Future<void> close(String id) => _remote.setOpen(id, open: false);

  Future<void> share(String voteId) => AppShare.share(
    'vote_link',
    voteId,
    ShareParams(
      text: LocaleKeys.voteShareText.trParams({'link': linkFor(voteId)}),
    ),
  );

  @override
  void onClose() {
    _mineSub?.cancel();
    super.onClose();
  }
}

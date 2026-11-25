import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../data/models/couple.dart';
import '../data/providers/partner_remote_source.dart';
import 'storage_service.dart';

/// Partner link: create / join a 6-digit code, share likes, receive matches.
class PartnerService extends GetxService {
  PartnerService(this._remote, this._storage);

  static const String _kCode = 'partner.code';
  static const String _kSeen = 'partner.seen_matches';

  final PartnerRemoteSource _remote;
  final StorageService _storage;

  final Rxn<Couple> couple = Rxn<Couple>();
  final RxList<NameMatch> matches = <NameMatch>[].obs;
  final RxSet<String> seenMatchIds = <String>{}.obs;
  final RxBool busy = false.obs;

  String? _uid;
  String? _code;
  final Set<String> _announced = {};
  StreamSubscription<Couple?>? _coupleSub;
  StreamSubscription<List<NameMatch>>? _matchSub;
  final StreamController<NameMatch> _newMatches =
      StreamController<NameMatch>.broadcast();

  /// Emits each match the user hasn't seen yet, once per session.
  Stream<NameMatch> get newMatches => _newMatches.stream;

  bool get isAvailable => _remote.isAvailable;
  String? get code => _code;
  bool get hasCode => _code != null;
  bool get isLinked => couple.value?.isComplete ?? false;
  int get unseenCount =>
      matches.where((m) => !seenMatchIds.contains(m.nameId)).length;

  Future<PartnerService> init() async {
    seenMatchIds.addAll([
      for (final Object? v in _storage.read<List<dynamic>>(_kSeen) ?? const [])
        if (v is String) v,
    ]);
    _announced.addAll(seenMatchIds);
    final String? saved = _storage.read<String>(_kCode);
    if (saved != null && isAvailable) unawaited(_connect(saved));
    return this;
  }

  /// Returns the new code.
  Future<String> create() => _guard(() async {
    final String uid = await _requireUid();
    final String code = await _remote.createCouple(uid);
    await _connect(code);
    return code;
  });

  Future<void> join(String input) => _guard(() async {
    final String code = CoupleCode.normalize(input);
    if (!CoupleCode.isValid(code)) {
      throw const PartnerException(PartnerError.invalidCode);
    }
    final String uid = await _requireUid();
    couple.value = await _remote.joinCouple(code, uid);
    await _connect(code);
  });

  Future<void> leave() => _guard(() async {
    final String? code = _code;
    final String? uid = _uid;
    if (code != null && uid != null) await _remote.leaveCouple(code, uid);
    await _disconnect();
  });

  /// Shares a like with the partner. Silently ignored when not linked.
  Future<void> recordLike(String nameId, {bool superLike = false}) async {
    final (String? code, String? uid) = (_code, _uid);
    if (code == null || uid == null) return;
    try {
      await _remote.setLike(code, uid, nameId, superLike: superLike);
    } catch (error) {
      debugPrint('Partner like failed: $error');
    }
  }

  Future<void> removeLike(String nameId) async {
    final (String? code, String? uid) = (_code, _uid);
    if (code == null || uid == null) return;
    try {
      await _remote.deleteLike(code, uid, nameId);
    } catch (error) {
      debugPrint('Partner unlike failed: $error');
    }
  }

  Future<void> markSeen(Iterable<String> nameIds) async {
    seenMatchIds.addAll(nameIds);
    _announced.addAll(nameIds);
    await _storage.write(_kSeen, seenMatchIds.toList());
  }

  // ---------------------------------------------------------------------------

  Future<T> _guard<T>(Future<T> Function() body) async {
    busy.value = true;
    try {
      return await body();
    } on PartnerException {
      rethrow;
    } catch (error) {
      debugPrint('Partner action failed: $error');
      throw const PartnerException(PartnerError.unknown);
    } finally {
      busy.value = false;
    }
  }

  Future<String> _requireUid() async {
    if (!isAvailable) throw const PartnerException(PartnerError.unavailable);
    final String? uid = _uid ?? await _remote.ensureUid();
    if (uid == null) throw const PartnerException(PartnerError.unavailable);
    return _uid = uid;
  }

  Future<void> _connect(String code) async {
    final String? uid = _uid ?? await _remote.ensureUid();
    if (uid == null) return;
    _uid = uid;
    await _cancelSubs();
    _code = code;
    await _storage.write(_kCode, code);
    _coupleSub = _remote.watchCouple(code).listen((c) {
      if (c == null || !c.members.contains(uid)) {
        unawaited(_disconnect()); // removed, or the couple was deleted
      } else {
        couple.value = c;
      }
    });
    _matchSub = _remote.watchMatches(code).listen(_onMatches);
  }

  void _onMatches(List<NameMatch> list) {
    matches.assignAll(list);
    for (final NameMatch m in list) {
      if (_announced.add(m.nameId) && !_newMatches.isClosed) {
        _newMatches.add(m);
      }
    }
  }

  Future<void> _disconnect() async {
    await _cancelSubs();
    _code = null;
    couple.value = null;
    matches.clear();
    await _storage.remove(_kCode);
  }

  Future<void> _cancelSubs() async {
    await _coupleSub?.cancel();
    await _matchSub?.cancel();
    _coupleSub = null;
    _matchSub = null;
  }

  @override
  void onClose() {
    _cancelSubs();
    _newMatches.close();
    super.onClose();
  }
}

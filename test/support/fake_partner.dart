import 'dart:async';

import 'package:habesha_names/app/data/models/couple.dart';
import 'package:habesha_names/app/data/providers/partner_remote_source.dart';

/// In-memory "Firestore + onSwipe function" shared by both partners.
class FakeServer {
  final Map<String, List<String>> couples = {};
  final Map<String, Map<String, bool>> likes = {}; // code → "uid_name" → super
  final Map<String, List<NameMatch>> matches = {};
  final Map<String, StreamController<Couple?>> _coupleCtl = {};
  final Map<String, StreamController<List<NameMatch>>> _matchCtl = {};
  int nextCode = 123456;

  StreamController<Couple?> coupleCtl(String c) =>
      _coupleCtl[c] ??= StreamController<Couple?>.broadcast();
  StreamController<List<NameMatch>> matchCtl(String c) =>
      _matchCtl[c] ??= StreamController<List<NameMatch>>.broadcast();

  void pushCouple(String code) => coupleCtl(code).add(
    couples[code] == null
        ? null
        : Couple(code: code, members: [...couples[code]!]),
  );

  /// What the Cloud Function does.
  void onSwipe(String code, String nameId) {
    final List<String> members = couples[code] ?? const [];
    final Map<String, bool> l = likes[code] ?? const {};
    if (members.length == 2 &&
        members.every((u) => l.containsKey('${u}_$nameId')) &&
        !(matches[code] ?? const []).any((m) => m.nameId == nameId)) {
      matches[code] = [
        NameMatch(
          nameId: nameId,
          createdAt: DateTime.utc(2026),
          superLike: members.any((u) => l['${u}_$nameId'] == true),
        ),
        ...?matches[code],
      ];
      matchCtl(code).add(matches[code]!);
    }
  }
}

class FakeRemote implements PartnerRemoteSource {
  FakeRemote(this.server, this.uid);

  final FakeServer server;
  final String? uid;

  @override
  bool isAvailable = true;

  @override
  Future<String?> ensureUid() async => uid;

  @override
  Future<String> createCouple(String uid) async {
    final String code = '${server.nextCode++}';
    server.couples[code] = [uid];
    return code;
  }

  @override
  Future<Couple> joinCouple(String code, String uid) async {
    final List<String>? m = server.couples[code];
    if (m == null) throw const PartnerException(PartnerError.notFound);
    if (!m.contains(uid)) {
      if (m.length >= 2) throw const PartnerException(PartnerError.full);
      m.add(uid);
      server.pushCouple(code);
    }
    return Couple(code: code, members: [...m]);
  }

  @override
  Future<void> leaveCouple(String code, String uid) async {
    server.couples[code]?.remove(uid);
    server.pushCouple(code);
  }

  @override
  Stream<Couple?> watchCouple(String code) async* {
    yield server.couples[code] == null
        ? null
        : Couple(code: code, members: [...server.couples[code]!]);
    yield* server.coupleCtl(code).stream;
  }

  @override
  Stream<List<NameMatch>> watchMatches(String code) async* {
    yield [...?server.matches[code]];
    yield* server.matchCtl(code).stream;
  }

  @override
  Future<void> setLike(
    String code,
    String uid,
    String nameId, {
    required bool superLike,
  }) async {
    (server.likes[code] ??= {})['${uid}_$nameId'] = superLike;
    server.onSwipe(code, nameId);
  }

  @override
  Future<void> deleteLike(String code, String uid, String nameId) async =>
      server.likes[code]?.remove('${uid}_$nameId');
}

import 'package:flutter_test/flutter_test.dart';
import 'package:habesha_names/app/data/models/couple.dart';
import 'package:habesha_names/app/services/partner_service.dart';

import '../support/fake_partner.dart';
import '../support/memory_storage.dart';

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 5));

void main() {
  late FakeServer server;
  late PartnerService alice;
  late PartnerService bob;

  Future<PartnerService> service(String? uid) =>
      PartnerService(FakeRemote(server, uid), MemoryStorageService()).init();

  setUp(() async {
    server = FakeServer();
    alice = await service('alice');
    bob = await service('bob');
  });

  test('code format helpers', () {
    for (int i = 0; i < 50; i++) {
      expect(CoupleCode.isValid(CoupleCode.generate()), isTrue);
    }
    expect(CoupleCode.normalize(' 123-456 '), '123456');
    expect(CoupleCode.isValid('12345'), isFalse);
    expect(CoupleCode.isValid('12a456'), isFalse);
  });

  test('create → waiting; partner joins → linked on both sides', () async {
    final String code = await alice.create();
    await settle();
    expect(alice.hasCode, isTrue);
    expect(alice.isLinked, isFalse);

    await bob.join(code);
    await settle();
    expect(bob.isLinked, isTrue);
    expect(alice.isLinked, isTrue);
    expect(alice.couple.value!.members, ['alice', 'bob']);
  });

  test('join errors: invalid, unknown, full', () async {
    await expectLater(
      bob.join('12'),
      throwsA(
        isA<PartnerException>().having(
          (e) => e.error,
          'error',
          PartnerError.invalidCode,
        ),
      ),
    );
    await expectLater(
      bob.join('999999'),
      throwsA(
        isA<PartnerException>().having(
          (e) => e.error,
          'error',
          PartnerError.notFound,
        ),
      ),
    );
    final String code = await alice.create();
    await bob.join(code);
    final PartnerService carol = await service('carol');
    await expectLater(
      carol.join(code),
      throwsA(
        isA<PartnerException>().having(
          (e) => e.error,
          'error',
          PartnerError.full,
        ),
      ),
    );
  });

  test('unavailable without sign-in', () async {
    final PartnerService offline = await service(null);
    await expectLater(
      offline.create(),
      throwsA(
        isA<PartnerException>().having(
          (e) => e.error,
          'error',
          PartnerError.unavailable,
        ),
      ),
    );
  });

  test('both like a name → match is announced once to each partner', () async {
    final String code = await alice.create();
    await bob.join(code);
    await settle();
    final List<String> aliceSaw = [];
    final List<String> bobSaw = [];
    alice.newMatches.listen((m) => aliceSaw.add(m.nameId));
    bob.newMatches.listen((m) => bobSaw.add(m.nameId));

    await alice.recordLike('hiwot');
    await bob.recordLike('selam');
    await settle();
    expect(alice.matches, isEmpty);

    await bob.recordLike('hiwot', superLike: true);
    await settle();
    expect(alice.matches.single.nameId, 'hiwot');
    expect(alice.matches.single.superLike, isTrue);
    expect(aliceSaw, ['hiwot']);
    expect(bobSaw, ['hiwot']);
    expect(alice.unseenCount, 1);

    await alice.markSeen(['hiwot']);
    expect(alice.unseenCount, 0);
  });

  test('undo removes the like so no match happens', () async {
    final String code = await alice.create();
    await bob.join(code);
    await alice.recordLike('hana');
    await alice.removeLike('hana');
    await bob.recordLike('hana');
    await settle();
    expect(bob.matches, isEmpty);
  });

  test('likes before linking are ignored; leave disconnects', () async {
    await alice.recordLike('hiwot'); // no code yet: no-op
    expect(server.likes, isEmpty);

    final String code = await alice.create();
    await bob.join(code);
    await settle();
    await bob.leave();
    await settle();
    expect(bob.hasCode, isFalse);
    expect(alice.isLinked, isFalse);
  });

  test('being removed from the couple disconnects', () async {
    final String code = await alice.create();
    await bob.join(code);
    await settle();
    server.couples[code]!.remove('bob');
    server.pushCouple(code);
    await settle();
    expect(bob.hasCode, isFalse);
    expect(bob.couple.value, isNull);
  });

  test('reconnects to the saved code on restart', () async {
    final MemoryStorageService storage = MemoryStorageService();
    final PartnerService first = await PartnerService(
      FakeRemote(server, 'alice'),
      storage,
    ).init();
    final String code = await first.create();
    final PartnerService again = await PartnerService(
      FakeRemote(server, 'alice'),
      storage,
    ).init();
    await settle();
    expect(again.code, code);
    expect(again.couple.value, isNotNull);
  });
}

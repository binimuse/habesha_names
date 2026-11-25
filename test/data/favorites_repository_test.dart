import 'package:flutter_test/flutter_test.dart';
import 'package:habesha_names/app/data/models/favorite.dart';
import 'package:habesha_names/app/data/models/sync_result.dart';
import 'package:habesha_names/app/data/providers/favorites_sources.dart';
import 'package:habesha_names/app/data/repositories/favorites_repository.dart';

class _Local implements FavoritesLocalSource {
  final Map<String, StoredFavorite> rows = {};

  @override
  Future<List<StoredFavorite>> getAll() async => rows.values.toList();

  @override
  Future<void> putAll(List<StoredFavorite> items) async {
    for (final StoredFavorite s in items) {
      rows[s.favorite.nameId] = s;
    }
  }
}

class _Remote implements FavoritesRemoteSource {
  @override
  bool isAvailable = true;
  String? uid = 'u1';
  final Map<String, Favorite> server = {};
  final List<DateTime?> pulledSince = [];
  int pushes = 0;

  @override
  Future<String?> ensureUid() async => uid;

  @override
  Future<List<Favorite>> pullChangedSince(String uid, DateTime? since) async {
    pulledSince.add(since);
    return [
      for (final Favorite f in server.values)
        if (since == null || f.updatedAt.isAfter(since)) f,
    ];
  }

  @override
  Future<void> push(String uid, List<Favorite> items) async {
    pushes++;
    for (final Favorite f in items) {
      server[f.nameId] = f;
    }
  }
}

class _SyncState implements FavoritesSyncState {
  final Map<String, DateTime> pulled = {};

  @override
  DateTime? lastPulledAt(String uid) => pulled[uid];

  @override
  Future<void> setLastPulledAt(String uid, DateTime value) async =>
      pulled[uid] = value;
}

void main() {
  late _Local local;
  late _Remote remote;
  late _SyncState state;
  late DateTime now;
  late FavoritesRepository repo;

  FavoritesRepository build() => FavoritesRepository(
    local: local,
    remote: remote,
    syncState: state,
    clock: () => now,
  );

  setUp(() {
    local = _Local();
    remote = _Remote();
    state = _SyncState();
    now = DateTime.utc(2026, 11, 1, 12);
    repo = build();
  });

  void tick() => now = now.add(const Duration(minutes: 1));

  group('local changes', () {
    test('add / toggle / remove', () async {
      await repo.add('hiwot');
      expect(repo.isFavorite('hiwot'), isTrue);
      tick();
      expect(await repo.toggle('hiwot'), isFalse);
      expect(repo.isFavorite('hiwot'), isFalse);
      tick();
      expect(await repo.toggle('hiwot'), isTrue);
    });

    test('removal is a tombstone, hidden from the list', () async {
      await repo.add('selam');
      tick();
      await repo.remove('selam');
      expect(await repo.getAll(), isEmpty);
      expect(local.rows['selam']!.favorite.deleted, isTrue);
      expect(local.rows['selam']!.dirty, isTrue);
    });

    test('newest first, persisted across restarts', () async {
      await repo.add('a');
      tick();
      await repo.add('b');
      expect((await repo.getAll()).map((f) => f.nameId), ['b', 'a']);
      expect((await build().getAll()).map((f) => f.nameId), ['b', 'a']);
    });

    test('notes are trimmed; restore keeps note and created date', () async {
      await repo.add('hana');
      final DateTime created = now;
      tick();
      await repo.setNote('hana', '  Grandma\'s name  ');
      final Favorite withNote = (await repo.getAll()).single;
      expect(withNote.note, "Grandma's name");

      tick();
      await repo.remove('hana');
      tick();
      await repo.restore(withNote);
      final Favorite restored = (await repo.getAll()).single;
      expect(restored.note, "Grandma's name");
      expect(restored.createdAt, created);
      expect(restored.updatedAt, now);
    });

    test('changes stream emits the active list', () async {
      final List<List<Favorite>> events = [];
      repo.changes.listen(events.add);
      await repo.add('x');
      await Future<void>.delayed(Duration.zero);
      expect(events.single.single.nameId, 'x');
    });
  });

  group('sync', () {
    test('skipped when Firebase or sign-in is unavailable', () async {
      remote.isAvailable = false;
      expect((await repo.sync()).status, SyncStatus.skipped);
      remote
        ..isAvailable = true
        ..uid = null;
      expect((await repo.sync()).status, SyncStatus.skipped);
    });

    test('pushes dirty items (incl. removals) and marks them clean', () async {
      await repo.add('a');
      await repo.add('b');
      tick();
      await repo.remove('b');

      final SyncResult r = await repo.sync();
      expect(r.status, SyncStatus.success);
      expect(remote.server.keys, containsAll(['a', 'b']));
      expect(remote.server['b']!.deleted, isTrue);
      expect(local.rows.values.every((s) => !s.dirty), isTrue);

      await repo.sync();
      expect(remote.pushes, 1, reason: 'nothing dirty the second time');
    });

    test('pulls newer server changes (other device) and tombstones', () async {
      await repo.add('a');
      await repo.sync();
      tick();
      remote.server['a'] = remote.server['a']!.copyWith(
        deleted: true,
        updatedAt: now,
      );
      remote.server['z'] = Favorite(
        nameId: 'z',
        note: 'from tablet',
        createdAt: now,
        updatedAt: now,
      );

      await repo.sync();
      expect((await repo.getAll()).map((f) => f.nameId), ['z']);
      expect(repo.isFavorite('a'), isFalse);
      expect(state.pulled['u1'], now);
    });

    test(
      'last write wins: a newer local edit beats an older server copy',
      () async {
        await repo.add('a');
        await repo.sync();
        final DateTime serverEdit = now.add(const Duration(minutes: 1));
        remote.server['a'] = remote.server['a']!.copyWith(
          note: 'server',
          updatedAt: serverEdit,
        );
        now = serverEdit.add(const Duration(minutes: 1));
        await repo.setNote('a', 'local, newer');

        await repo.sync();
        expect((await repo.getAll()).single.note, 'local, newer');
        expect(remote.server['a']!.note, 'local, newer');
      },
    );

    test('a newer server copy replaces an older local edit', () async {
      await repo.add('a');
      await repo.sync();
      tick();
      await repo.setNote('a', 'local, older');
      final DateTime serverEdit = now.add(const Duration(minutes: 5));
      remote.server['a'] = remote.server['a']!.copyWith(
        note: 'server, newer',
        updatedAt: serverEdit,
      );

      await repo.sync();
      expect((await repo.getAll()).single.note, 'server, newer');
      expect(remote.server['a']!.note, 'server, newer');
    });

    test('only asks for changes since the last pull', () async {
      remote.server['a'] = Favorite(
        nameId: 'a',
        createdAt: now,
        updatedAt: now,
      );
      await repo.sync();
      await repo.sync();
      expect(remote.pulledSince, [null, now]);
    });
  });
}

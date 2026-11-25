import 'package:flutter_test/flutter_test.dart';
import 'package:habesha_names/app/data/models/gender.dart';
import 'package:habesha_names/app/data/models/name_model.dart';
import 'package:habesha_names/app/data/providers/names_remote_source.dart';
import 'package:habesha_names/app/data/models/sync_result.dart';
import 'package:habesha_names/app/data/repositories/names_repository.dart';

import '../support/fakes.dart';

void main() {
  group('first launch seeding', () {
    test('empty DB is seeded from the bundled names', () async {
      final RepoHarness h = RepoHarness();
      expect(await h.repo.getAll(), hasLength(sampleNames.length));
      expect(h.local.rows, hasLength(sampleNames.length));
      expect(h.syncState.seedVersion, 1);
    });

    test('lastSyncedAt starts at the newest seeded updated_at', () async {
      final DateTime newest = DateTime.utc(2026, 5, 5);
      final RepoHarness h = RepoHarness(
        seed: [
          ...sampleNames,
          name('new', updatedAt: newest),
        ],
      );
      await h.repo.ensureReady();
      expect(h.syncState.lastSyncedAt, newest);
    });

    test(
      'second launch with the same seed version does not re-import',
      () async {
        final RepoHarness h = RepoHarness();
        await h.repo.ensureReady();
        final int writes = h.local.upsertCalls;

        await h.build().ensureReady(); // app restart
        expect(h.local.upsertCalls, writes);
      },
    );

    test('newer bundled version merges, keeping rows synced later', () async {
      final RepoHarness h = RepoHarness();
      await h.repo.ensureReady();
      // A sync already brought a newer Hiwot.
      final NameModel synced = name(
        'hiwot',
        meaningEn: 'from server',
        updatedAt: DateTime.utc(2026, 6, 1),
      );
      h.local.rows['hiwot'] = synced;

      h.seed
        ..version = 2
        ..names = [
          ...sampleNames.where((n) => n.id != 'hiwot'),
          name('hiwot', meaningEn: 'old seed', updatedAt: t0),
          name('lidya', updatedAt: DateTime.utc(2026, 3, 1)),
        ];
      final NamesRepository restarted = h.build();
      expect((await restarted.getById('hiwot'))!.meaningEn, 'from server');
      expect(await restarted.getById('lidya'), isNotNull);
      expect(h.syncState.seedVersion, 2);
    });

    test('a failed init can be retried', () async {
      final RepoHarness h = RepoHarness();
      h.seed.failNext = const FormatException('corrupt asset');
      final NamesRepository repo = h.build();

      await expectLater(repo.getAll(), throwsFormatException);
      expect(await repo.getAll(), hasLength(sampleNames.length));
    });
  });

  group('getById / similar', () {
    late NamesRepository repo;
    setUp(() => repo = RepoHarness().repo);

    test('getById', () async {
      expect((await repo.getById('tsehay'))!.nameGeez, 'ፀሐይ');
      expect(await repo.getById('missing'), isNull);
    });

    test(
      'similar: curated ids first, never itself, gender compatible',
      () async {
        final List<NameModel> r = await repo.similar('hiwot');
        expect(r.first.id, 'hayat'); // curated
        expect(r.map((n) => n.id), isNot(contains('hiwot')));
        expect(r.where((n) => n.gender == Gender.boy), isEmpty);
      },
    );

    test('similar ranks shared themes highly', () async {
      final List<NameModel> r = await repo.similar('birhan', limit: 2);
      // Birhan (light): Nuria and Tsehay share the "light" theme.
      expect(r.map((n) => n.id).toSet(), {'nuria', 'tsehay'});
    });

    test('similar respects limit and unknown ids', () async {
      expect(await repo.similar('hiwot', limit: 3), hasLength(3));
      expect(await repo.similar('missing'), isEmpty);
    });
  });

  group('syncFromFirestore', () {
    test('is skipped when Firebase is unavailable', () async {
      final RepoHarness h = RepoHarness(remote: false);
      final SyncResult r = await h.repo.syncFromFirestore();
      expect(r.status, SyncStatus.skipped);
      expect(h.remote.requestedSince, isEmpty);
    });

    test('asks only for changes since the last sync', () async {
      final RepoHarness h = RepoHarness();
      await h.repo.syncFromFirestore();
      expect(h.remote.requestedSince.single, t0); // newest seeded date
    });

    test('applies upserts and deletes, then advances lastSyncedAt', () async {
      final RepoHarness h = RepoHarness();
      final DateTime later = DateTime.utc(2026, 7, 1);
      h.remote.next = RemoteNameChanges(
        upserts: [
          name('hiwot', meaningEn: 'Life (updated)', updatedAt: later),
          name('lidya', geez: 'ልድያ', updatedAt: later),
        ],
        deletedIds: const ['gemechu'],
        maxUpdatedAt: later,
      );

      final List<void> events = [];
      h.repo.changes.listen(events.add);

      final SyncResult r = await h.repo.syncFromFirestore();
      expect(r.status, SyncStatus.success);
      expect(r.upserted, 2);
      expect(r.deleted, 1);
      expect((await h.repo.getById('hiwot'))!.meaningEn, 'Life (updated)');
      expect(await h.repo.getById('gemechu'), isNull);
      expect(h.syncState.lastSyncedAt, later);

      // The search index is rebuilt too.
      expect((await h.repo.search('ልድያ')).single.id, 'lidya');
      await Future<void>.delayed(Duration.zero);
      expect(events, hasLength(1));
    });

    test('ignores server rows older than what is stored', () async {
      final RepoHarness h = RepoHarness(); // seeded hiwot has updatedAt t0
      final DateTime older = DateTime.utc(2025);
      h.remote.next = RemoteNameChanges(
        upserts: [name('hiwot', meaningEn: 'stale', updatedAt: older)],
        maxUpdatedAt: older,
      );
      final SyncResult r = await h.repo.syncFromFirestore();
      expect(r.upserted, 0);
      expect((await h.repo.getById('hiwot'))!.meaningEn, 'Life');
    });

    test('failures are reported, not thrown, and keep local data', () async {
      final RepoHarness h = RepoHarness();
      h.remote.error = Exception('offline');
      final SyncResult r = await h.repo.syncFromFirestore();
      expect(r.status, SyncStatus.failed);
      expect(await h.repo.getAll(), hasLength(sampleNames.length));
    });

    test('concurrent calls share one request', () async {
      final RepoHarness h = RepoHarness();
      await h.repo.ensureReady();
      final List<SyncResult> results = await Future.wait([
        h.repo.syncFromFirestore(),
        h.repo.syncFromFirestore(),
      ]);
      expect(h.remote.requestedSince, hasLength(1));
      expect(identical(results[0], results[1]), isTrue);
    });
  });
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habesha_names/app/data/models/family_vote.dart';
import 'package:habesha_names/app/data/models/gender.dart';
import 'package:habesha_names/app/data/models/name_model.dart';
import 'package:habesha_names/app/data/providers/store_gateway.dart';
import 'package:habesha_names/app/data/providers/vote_remote.dart';
import 'package:habesha_names/app/modules/reels/controllers/reels_audio.dart';
import 'package:habesha_names/app/modules/reveal_video/controllers/reveal_encoding.dart';
import 'package:habesha_names/app/modules/reveal_video/controllers/reveal_video_controller.dart';
import 'package:habesha_names/app/modules/reveal_video/views/reveal_video_view.dart';
import 'package:habesha_names/app/modules/share_card/controllers/share_card_controller.dart';
import 'package:habesha_names/app/modules/share_card/widgets/share_card_art.dart';
import 'package:habesha_names/app/services/purchase_service.dart';
import 'package:habesha_names/app/services/vote_service.dart';
import 'package:habesha_names/app/theme/app_theme.dart';
import 'package:habesha_names/app/translations/app_translations.dart';

import '../services/ads_purchase_test.dart' show FakeStore;
import '../support/fakes.dart';
import '../support/memory_storage.dart';

// -- Reels ---------------------------------------------------------------------

class FakePlayer implements ReelsPlayer {
  FakePlayer(this.log);
  final List<String> log;
  String? url;

  @override
  Future<void> load(String u) async => log.add('load $u');
  @override
  Future<void> play() async => log.add('play');
  @override
  Future<void> pause() async => log.add('pause');
  @override
  Future<void> dispose() async => log.add('dispose');
}

NameModel withAudio(String id) => NameModel(
  id: id,
  nameLatin: id,
  nameGeez: 'ስ',
  gender: Gender.girl,
  updatedAt: t0,
  audioUrl: 'https://x/$id.mp3',
);

// -- Votes ---------------------------------------------------------------------

class FakeVoteRemote implements VoteRemote {
  @override
  bool isAvailable = true;
  final List<List<VoteOption>> created = [];

  @override
  Future<String?> ensureUid() async => 'owner';

  @override
  Future<String> create({
    required String ownerUid,
    required String title,
    required List<VoteOption> options,
  }) async {
    created.add(options);
    return 'vote${created.length}';
  }

  @override
  Stream<FamilyVote?> watchVote(String id) => const Stream.empty();
  @override
  Stream<List<Ballot>> watchBallots(String id) => const Stream.empty();
  @override
  Stream<List<FamilyVote>> watchMine(String uid) => const Stream.empty();
  @override
  Future<void> setOpen(String id, {required bool open}) async {}
}

class FakeEncoder implements VideoEncoder {
  String? framesDir;
  List<String> frames = [];

  @override
  Future<bool> encode({
    required String framesDir,
    required String output,
  }) async {
    this.framesDir = framesDir;
    frames = Directory(
      framesDir,
    ).listSync().map((f) => f.uri.pathSegments.last).toList()..sort();
    await File(output).writeAsString('mp4');
    return true;
  }
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  group('ReelsAudio preloading', () {
    test(
      'keeps current + next 3 loaded, plays current, frees the rest',
      () async {
        final List<String> log = [];
        final ReelsAudio audio = ReelsAudio(create: () => FakePlayer(log));
        final List<NameModel> deck = [
          for (int i = 0; i < 8; i++) withAudio('n$i'),
        ];

        await audio.focus(deck, 0, play: true);
        expect(audio.loadedIds.toSet(), {'n0', 'n1', 'n2', 'n3'});
        expect(log.last, 'play');

        final int played = log.lastIndexOf('play');
        await audio.focus(deck, 2, play: false);
        expect(audio.loadedIds.toSet(), {'n2', 'n3', 'n4', 'n5'});
        expect(log.where((l) => l == 'dispose'), hasLength(2));
        expect(log[played + 1], 'pause'); // stopped before being released
        expect(log.lastIndexOf('play'), played); // muted → nothing new plays

        await audio.dispose();
        expect(audio.loadedIds, isEmpty);
      },
    );

    test('names without audio are skipped', () async {
      final ReelsAudio audio = ReelsAudio(create: () => FakePlayer([]));
      await audio.focus([sampleNames.first, withAudio('a')], 0, play: true);
      expect(audio.loadedIds, ['a']);
    });
  });

  group('Family vote', () {
    final FamilyVote vote = FamilyVote(
      id: 'v',
      ownerUid: 'o',
      title: 'Which?',
      open: true,
      createdAt: t0,
      options: const [
        VoteOption(nameId: 'hiwot', latin: 'Hiwot', geez: 'ሕይወት'),
        VoteOption(nameId: 'selam', latin: 'Selam', geez: 'ሰላም'),
        VoteOption(nameId: 'hana', latin: 'Hana', geez: 'ሐና'),
      ],
    );

    test('tally counts, orders and names voters; ignores bad choices', () {
      final VoteTally t = VoteTally(vote, const [
        Ballot(voterId: '1', voterName: 'Almaz', choice: 'selam'),
        Ballot(voterId: '2', voterName: 'Kebede', choice: 'selam'),
        Ballot(voterId: '3', voterName: 'Abeba', choice: 'hiwot'),
        Ballot(voterId: '4', voterName: 'X', choice: 'unknown'),
      ]);
      expect(t.total, 3);
      expect(t.options.map((o) => o.option.nameId), ['selam', 'hiwot', 'hana']);
      expect(t.options.first.voters, ['Almaz', 'Kebede']);
      expect(t.leaders, {'selam'});
      expect(VoteTally(vote, const []).leaders, isEmpty);
    });

    test('ties share the lead', () {
      final VoteTally t = VoteTally(vote, const [
        Ballot(voterId: '1', voterName: 'A', choice: 'hana'),
        Ballot(voterId: '2', voterName: 'B', choice: 'hiwot'),
      ]);
      expect(t.leaders, {'hana', 'hiwot'});
    });

    test('create needs 2–6 names and Firebase', () async {
      final FakeVoteRemote remote = FakeVoteRemote();
      final VoteService s = VoteService(remote);
      await expectLater(
        s.create(sampleNames.take(1).toList(), title: 't'),
        throwsA(isA<VoteException>()),
      );
      await expectLater(
        s.create(sampleNames.take(7).toList(), title: 't'),
        throwsA(isA<VoteException>()),
      );
      expect(await s.create(sampleNames.take(3).toList(), title: 't'), 'vote1');
      expect(remote.created.single.map((o) => o.nameId), [
        'hiwot',
        'hayat',
        'tsehay',
      ]);
      expect(VoteService.linkFor('abc'), endsWith('/v/abc'));
      remote.isAvailable = false;
      await expectLater(
        s.create(sampleNames.take(2).toList(), title: 't'),
        throwsA(isA<VoteException>()),
      );
    });
  });

  group('Reveal video', () {
    test('encoder attempts: hardware H.264 first, MPEG-4 fallback', () {
      final List<List<String>> a = RevealEncoding.attempts(
        framesDir: '/tmp/f',
        output: '/tmp/o.mp4',
        ios: false,
      );
      expect(a, hasLength(2));
      expect(a[0], containsAllInOrder(['-c:v', 'h264_mediacodec']));
      expect(a[1], containsAllInOrder(['-c:v', 'mpeg4']));
      expect(a[0], containsAllInOrder(['-i', '/tmp/f/f_%04d.png']));
      expect(a[0].last, '/tmp/o.mp4');
      expect(
        RevealEncoding.attempts(framesDir: 'd', output: 'o', ios: true)[0],
        contains('h264_videotoolbox'),
      );
      expect(RevealSpec.frames, 180);
      expect(RevealSpec.frameName(7), 'f_0007.png');
    });

    test('timeline: everything hidden at 0, shown at 1, in order', () {
      for (final double Function(double) f in [
        RevealTimeline.intro,
        RevealTimeline.latin,
        RevealTimeline.geez,
        RevealTimeline.meaning,
      ]) {
        expect(f(0), 0);
        expect(f(1), 1);
      }
      expect(RevealTimeline.latin(0.3), lessThan(1));
      expect(RevealTimeline.meaning(0.3), 0);
    });

    testWidgets('export renders frames, encodes and shares', (t) async {
      Get.testMode = true;
      addTearDown(Get.reset);
      final Directory tmp = Directory.systemTemp.createTempSync('reveal');
      addTearDown(() => tmp.deleteSync(recursive: true));
      final FakeEncoder encoder = FakeEncoder();
      String? shared;
      final RevealVideoController c = Get.put(
        RevealVideoController(
          sampleNames.first,
          encoder: encoder,
          tempDir: () async => tmp,
          share: (p) async => shared = p,
          frames: 4,
        ),
      );
      await t.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: AppTranslations.english,
          theme: AppTheme.light(AppTranslations.english),
          home: const RevealVideoView(),
        ),
      );
      await t.runAsync(GoogleFonts.pendingFonts);
      await t.pump();

      // Frames render on pump; file IO and image encoding need real time.
      unawaited(c.export());
      for (int i = 0; i < 400 && (c.exporting.value || i == 0); i++) {
        await t.pump();
        await t.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 15)),
        );
      }
      await t.pump();
      expect(c.failed.value, isFalse);
      expect(encoder.frames, [
        'f_0000.png',
        'f_0001.png',
        'f_0002.png',
        'f_0003.png',
      ]);
      expect(shared, endsWith('habesha-hiwot-reveal.mp4'));
      expect(Directory(encoder.framesDir!).existsSync(), isFalse); // cleaned up
    });
  });

  group('Share card', () {
    test('premium templates are locked until Premium', () async {
      final FakeStore store = FakeStore();
      final PurchaseService p = await PurchaseService(
        store,
        MemoryStorageService(),
      ).init();
      final ShareCardController c = ShareCardController(sampleNames.first, p);
      expect(c.isLocked(ShareCardTemplate.classic), isFalse);
      expect(c.isLocked(ShareCardTemplate.tilet), isTrue);
      store.emit(StorePurchaseStatus.purchased);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(c.isLocked(ShareCardTemplate.night), isFalse);
      p.onClose();
    });

    testWidgets('all templates render without overflow', (t) async {
      await t.binding.setSurfaceSize(const Size(390, 2400));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: AppTranslations.amharic,
          theme: AppTheme.dark(AppTranslations.amharic),
          home: Scaffold(
            body: ListView(
              children: [
                for (final ShareCardTemplate tpl in ShareCardTemplate.values)
                  ShareCardArt(name: sampleNames.first, template: tpl),
              ],
            ),
          ),
        ),
      );
      await t.runAsync(GoogleFonts.pendingFonts);
      await t.pumpAndSettle();
      expect(find.byType(ShareCardArt), findsNWidgets(3));
      expect(t.takeException(), isNull);
    });
  });
}

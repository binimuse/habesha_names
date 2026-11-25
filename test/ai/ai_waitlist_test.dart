import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habesha_names/app/data/models/ai_feature.dart';
import 'package:habesha_names/app/data/providers/ai_waitlist_remote.dart';
import 'package:habesha_names/app/modules/discover/controllers/ai_waitlist_controller.dart';
import 'package:habesha_names/app/modules/discover/widgets/ai_teaser_card.dart';
import 'package:habesha_names/app/services/ai_waitlist_service.dart';
import 'package:habesha_names/app/theme/app_theme.dart';
import 'package:habesha_names/app/translations/app_translations.dart';

import '../support/memory_storage.dart';

class FakeWaitlistRemote implements AiWaitlistRemote {
  @override
  bool isAvailable = true;
  String? uid = 'u1';
  final List<Map<String, Object>> entries = [];
  final List<String> events = [];
  final List<String> topics = [];
  bool failWrite = false;
  bool failFcm = false;

  @override
  Future<String?> ensureUid() async => uid;

  @override
  Future<void> addEntry({
    required String uid,
    required String text,
    required String language,
    required List<AiFeature> features,
  }) async {
    if (failWrite) throw Exception('offline');
    entries.add({
      'uid': uid,
      'text': text,
      'language': language,
      'features': [for (final f in features) f.code],
    });
  }

  @override
  Future<void> logJoin({
    required String language,
    required List<AiFeature> features,
  }) async => events.add('ai_waitlist_join');

  @override
  Future<void> subscribeToLaunch() async {
    if (failFcm) throw Exception('permission denied');
    topics.add('ai_launch');
  }
}

void main() {
  late FakeWaitlistRemote remote;
  late MemoryStorageService storage;
  late AiWaitlistService service;

  setUp(() {
    remote = FakeWaitlistRemote();
    storage = MemoryStorageService();
    service = AiWaitlistService(remote, storage)..onInit();
  });

  group('AiWaitlistService', () {
    test('join writes the entry, logs, subscribes and remembers', () async {
      await service.join(
        text: '  Orthodox girl name that means light ',
        chosen: {AiFeature.facePreview, AiFeature.nameFinder},
        language: 'am',
      );
      expect(remote.entries.single, {
        'uid': 'u1',
        'text': 'Orthodox girl name that means light',
        'language': 'am',
        'features': ['name_finder', 'face_preview'],
      });
      expect(remote.events, ['ai_waitlist_join']);
      expect(remote.topics, ['ai_launch']);
      expect(service.joined.value, isTrue);

      final AiWaitlistService restarted = AiWaitlistService(remote, storage)
        ..onInit();
      expect(restarted.joined.value, isTrue);
      expect(restarted.features, [AiFeature.nameFinder, AiFeature.facePreview]);
    });

    test('an empty description is allowed; long text is capped', () async {
      await service.join(
        text: 'x' * 900,
        chosen: {AiFeature.nameFinder},
        language: 'en',
      );
      expect(
        (remote.entries.single['text']! as String).length,
        AiWaitlistService.maxTextLength,
      );
    });

    test('FCM permission denied still counts as joined', () async {
      remote.failFcm = true;
      await service.join(
        text: '',
        chosen: {AiFeature.nameFinder},
        language: 'en',
      );
      expect(service.joined.value, isTrue);
      expect(remote.entries, hasLength(1));
    });

    test('write failure / offline / no features → not joined', () async {
      remote.failWrite = true;
      await expectLater(
        service.join(text: '', chosen: {AiFeature.nameFinder}, language: 'en'),
        throwsA(isA<AiWaitlistException>()),
      );
      remote
        ..failWrite = false
        ..isAvailable = false;
      await expectLater(
        service.join(text: '', chosen: {AiFeature.nameFinder}, language: 'en'),
        throwsA(isA<AiWaitlistException>()),
      );
      remote.isAvailable = true;
      await expectLater(
        service.join(text: '', chosen: {}, language: 'en'),
        throwsA(isA<AiWaitlistException>()),
      );
      expect(service.joined.value, isFalse);
      expect(remote.topics, isEmpty);
    });
  });

  group('Teaser card + sheet', () {
    Future<void> pump(WidgetTester t) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      Get.testMode = true;
      Get.put(AiWaitlistController(service));
      await t.binding.setSurfaceSize(const Size(390, 900));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: AppTranslations.english,
          theme: AppTheme.light(AppTranslations.english),
          home: const MediaQuery(
            // No repeating shimmer, so the test can settle.
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: Padding(padding: EdgeInsets.all(20), child: AiTeaserCard()),
            ),
          ),
        ),
      );
      await t.runAsync(GoogleFonts.pendingFonts);
      await t.pumpAndSettle();
    }

    tearDown(Get.reset);

    testWidgets('join flow, then "You\'re on the list" with no text field', (
      t,
    ) async {
      await pump(t);
      expect(
        find.text('✨ Coming soon: AI name finder and baby face preview'),
        findsOneWidget,
      );

      await t.tap(find.byType(AiTeaserCard));
      await t.pumpAndSettle();
      expect(find.text('Tell us what name you’re looking for'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await t.enterText(find.byType(TextField), 'Name that means light');
      await t.tap(find.text('Baby face preview'));
      await t.tap(find.text('Notify me'));
      await t.pumpAndSettle();

      expect(find.text('Thank you!'), findsOneWidget);
      expect(remote.entries.single['features'], [
        'name_finder',
        'face_preview',
      ]);

      await t.tap(find.text('Close'));
      await t.pumpAndSettle();
      expect(find.text('You’re on the list'), findsOneWidget); // card subtitle

      await t.tap(find.byType(AiTeaserCard));
      await t.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      expect(
        find.text('We’ll notify you when these features launch.'),
        findsOneWidget,
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('unchecking everything disables Notify me', (t) async {
      await pump(t);
      await t.tap(find.byType(AiTeaserCard));
      await t.pumpAndSettle();
      await t.tap(find.text('AI name finder')); // the default choice
      await t.pumpAndSettle();
      final FilledButton button = t.widget(
        find.ancestor(
          of: find.text('Notify me'),
          matching: find.byWidgetPredicate((w) => w is FilledButton),
        ),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('offline shows an error and keeps the form', (t) async {
      remote.isAvailable = false;
      await pump(t);
      await t.tap(find.byType(AiTeaserCard));
      await t.pumpAndSettle();
      await t.tap(find.text('Notify me'));
      await t.pumpAndSettle();
      expect(find.textContaining('Couldn’t join right now'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}

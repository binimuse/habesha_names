import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';

import '../../../core/base/async_controller.dart';
import '../../../data/models/gender.dart';
import '../../../data/models/name_filter.dart';
import '../../../data/models/name_model.dart';
import '../../../data/providers/seen_names_store.dart';
import '../../../data/repositories/names_repository.dart';
import '../../../data/search/swipe_deck.dart';
import '../../../routes/app_nav.dart';
import '../../../routes/app_pages.dart';
import '../../../services/ads_service.dart';
import '../../../services/analytics_service.dart';
import '../../../services/favorites_service.dart';
import '../../../services/partner_service.dart';
import '../../../services/preferences_service.dart';

enum SwipeChoice {
  like,
  superLike,
  skip;

  static SwipeChoice fromDirection(CardSwiperDirection d) =>
      d.isCloseTo(CardSwiperDirection.right)
      ? like
      : d.isCloseTo(CardSwiperDirection.top)
      ? superLike
      : skip;

  CardSwiperDirection get direction => switch (this) {
    like => CardSwiperDirection.right,
    superLike => CardSwiperDirection.top,
    skip => CardSwiperDirection.left,
  };

  bool get isPositive => this != skip;
}

/// Swipe deck. Right = like (favorite), up = super-like, left = skip.
/// Likes are shared with a linked partner; matches come from the server.
class SwipeController extends AsyncListController<NameModel> {
  SwipeController(
    this._names,
    this._prefs,
    this._favorites,
    this._seen,
    this._partner,
  );

  final NamesRepository _names;
  final PreferencesService _prefs;
  final FavoritesService _favorites;
  final SeenNamesStore _seen;
  final PartnerService _partner;

  /// Drives the card stack (buttons, undo).
  final CardSwiperController swiper = CardSwiperController();

  /// Same shuffle for the whole session.
  final int _seed = Random().nextInt(1 << 31);
  final List<(NameModel, SwipeChoice)> _history = [];
  late Set<String> _seenIds = _seen.load();

  /// Index of the card on top.
  final RxInt index = 0.obs;
  final RxBool finished = false.obs;
  final RxBool canUndo = false.obs;

  /// Quick filters on top of the onboarding preferences.
  final RxSet<Gender> genders = <Gender>{}.obs;
  final RxBool easyAbroad = false.obs;

  /// Increments on every like / super-like to replay the heart burst.
  final RxInt burst = 0.obs;
  final Rx<SwipeChoice> burstKind = SwipeChoice.like.obs;

  List<NameModel> get deck => state ?? const [];
  int get remaining => max(0, deck.length - index.value);
  bool get hasSeenAll => _seenIds.isNotEmpty;
  NameModel? get current =>
      index.value < deck.length ? deck[index.value] : null;

  bool get partnerLinked => _partner.isLinked;
  int get unseenMatches => _partner.unseenCount;

  @override
  Stream<void> get refreshTrigger => _names.changes;

  @override
  void onInit() {
    super.onInit();
    ever(_prefs.prefs, (_) => load(silent: true));
  }

  NameFilter get effectiveFilter {
    final NameFilter base = _prefs.prefs.value.toFilter();
    return base.copyWith(
      genders: genders.isEmpty ? null : genders.toSet(),
      easyAbroad: () => easyAbroad.value ? true : null,
    );
  }

  @override
  Future<List<NameModel>> fetch() async {
    final List<NameModel> deck = SwipeDeck.build(
      await _names.filter(effectiveFilter),
      seen: _seenIds,
      exclude: _favorites.ids.toSet(),
      seed: _seed,
    );
    index.value = 0;
    finished.value = false;
    _history.clear();
    canUndo.value = false;
    return deck;
  }

  // Quick filters ---------------------------------------------------------------

  void toggleGender(Gender g) {
    genders.contains(g) ? genders.remove(g) : genders.add(g);
    load();
  }

  void toggleEasyAbroad() {
    easyAbroad.toggle();
    load();
  }

  // Swiper callbacks ------------------------------------------------------------

  /// Called by the card stack for drags and button swipes alike.
  bool onSwipe(int previous, int? next, CardSwiperDirection direction) {
    if (previous >= deck.length) return false;
    final NameModel name = deck[previous];
    final SwipeChoice choice = SwipeChoice.fromDirection(direction);
    _history.add((name, choice));
    canUndo.value = true;
    index.value = next ?? deck.length;
    unawaited(
      choice == SwipeChoice.skip
          ? HapticFeedback.selectionClick()
          : HapticFeedback.mediumImpact(),
    );
    if (choice.isPositive) {
      burstKind.value = choice;
      burst.value++;
    }
    if (Get.isRegistered<AdsService>()) Get.find<AdsService>().onSwipe();
    unawaited(AnalyticsService.maybe?.swipe(name.id, direction: choice.name));
    unawaited(_record(name, choice));
    return true;
  }

  bool onUndo(int? previous, int current, CardSwiperDirection direction) {
    if (_history.isEmpty) return false;
    final (NameModel name, SwipeChoice choice) = _history.removeLast();
    canUndo.value = _history.isNotEmpty;
    index.value = current;
    finished.value = false;
    unawaited(HapticFeedback.lightImpact());
    unawaited(_unrecord(name, choice));
    return true;
  }

  void onEnd() => finished.value = true;

  // Buttons ---------------------------------------------------------------------

  void swipe(SwipeChoice choice) {
    if (current != null) swiper.swipe(choice.direction);
  }

  /// Works after the last card too (the swiper remembers its history).
  void undo() {
    if (canUndo.value) swiper.undo();
  }

  Future<void> startOver() async {
    _seenIds = {};
    await _seen.save(_seenIds);
    await load();
  }

  void openCurrent() {
    final NameModel? n = current;
    if (n != null) AppNav.openName(n, heroTag: heroTagFor(n));
  }

  void openPartner() => Get.toNamed<void>(Routes.partner);

  static String heroTagFor(NameModel n) => 'swipe/${n.id}';

  // ---------------------------------------------------------------------------

  Future<void> _record(NameModel name, SwipeChoice choice) async {
    _seenIds = {..._seenIds, name.id};
    await _seen.save(_seenIds);
    if (choice.isPositive) {
      await _favorites.add(name.id);
      await _partner.recordLike(
        name.id,
        superLike: choice == SwipeChoice.superLike,
      );
    }
  }

  Future<void> _unrecord(NameModel name, SwipeChoice choice) async {
    _seenIds = {..._seenIds}..remove(name.id);
    await _seen.save(_seenIds);
    if (choice.isPositive) {
      await _favorites.remove(name.id);
      await _partner.removeLike(name.id);
    }
  }

  @override
  void onClose() {
    swiper.dispose();
    super.onClose();
  }
}

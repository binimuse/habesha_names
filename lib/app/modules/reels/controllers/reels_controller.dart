import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/app_share.dart';
import '../../../core/base/async_controller.dart';
import '../../../core/utils/labels.dart';
import '../../../data/models/gender.dart';
import '../../../data/models/name_filter.dart';
import '../../../data/models/name_model.dart';
import '../../../data/models/rarity.dart';
import '../../../data/repositories/names_repository.dart';
import '../../../routes/app_nav.dart';
import '../../../translations/locale_keys.dart';
import 'reels_audio.dart';

enum ReelsChip { modern, rare, boy, girl }

/// Vertical feed: one name per page, autoplaying pronunciation.
class ReelsController extends AsyncListController<NameModel> {
  ReelsController(this._names, {ReelsAudio? audio})
    : audio = audio ?? ReelsAudio();

  final NamesRepository _names;
  final ReelsAudio audio;

  final PageController pageController = PageController();
  final RxInt page = 0.obs;
  final RxBool muted = false.obs;
  final RxSet<ReelsChip> chips = <ReelsChip>{}.obs;

  /// Only plays while the Reels tab is visible.
  bool _active = false;
  final int _seed = Random().nextInt(1 << 31);

  List<NameModel> get deck => state ?? const [];

  @override
  Stream<void> get refreshTrigger => _names.changes;

  NameFilter get filter => NameFilter(
    modern: chips.contains(ReelsChip.modern) ? true : null,
    rarities: chips.contains(ReelsChip.rare) ? const {Rarity.rare} : const {},
    genders: {
      if (chips.contains(ReelsChip.boy)) Gender.boy,
      if (chips.contains(ReelsChip.girl)) Gender.girl,
    },
  );

  @override
  Future<List<NameModel>> fetch() async {
    final List<NameModel> list = [...await _names.filter(filter)]
      ..shuffle(Random(_seed));
    page.value = 0;
    if (pageController.hasClients) pageController.jumpToPage(0);
    unawaited(_focus(list, 0));
    return list;
  }

  void toggleChip(ReelsChip chip) {
    chips.contains(chip) ? chips.remove(chip) : chips.add(chip);
    load();
  }

  void onPageChanged(int index) {
    page.value = index;
    unawaited(_focus(deck, index));
  }

  void toggleMute() {
    muted.toggle();
    unawaited(muted.value ? audio.pause() : _focus(deck, page.value));
  }

  /// Called by the shell when the tab becomes visible / hidden.
  void setActive(bool value) {
    if (_active == value) return;
    _active = value;
    unawaited(value ? _focus(deck, page.value) : audio.pause());
  }

  Future<void> share(NameModel n) => AppShare.share(
    'name',
    n.id,
    ShareParams(
      text: LocaleKeys.detailShareText.trParams({
        'latin': n.nameLatin,
        'geez': n.nameGeez,
        'meaning': Labels.meaning(n),
      }),
    ),
  );

  void open(NameModel n) => AppNav.openName(n, heroTag: heroTagFor(n));

  static String heroTagFor(NameModel n) => 'reels/${n.id}';

  Future<void> _focus(List<NameModel> list, int index) =>
      audio.focus(list, index, play: _active && !muted.value);

  @override
  void onClose() {
    pageController.dispose();
    unawaited(audio.dispose());
    super.onClose();
  }
}

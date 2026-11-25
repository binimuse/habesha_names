import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/app_share.dart';
import '../../../core/base/async_controller.dart';
import '../../../core/utils/labels.dart';
import '../../../data/models/name_model.dart';
import '../../../data/repositories/names_repository.dart';
import '../../../routes/app_nav.dart';
import '../../../routes/app_pages.dart';
import '../../../services/audio_service.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/name_card.dart';

class NameDetailData {
  const NameDetailData(this.name, this.similar);

  final NameModel name;
  final List<NameModel> similar;
}

class NameNotFoundException implements Exception {
  const NameNotFoundException();

  static const String code = 'name_not_found';

  @override
  String toString() => code;
}

class NameDetailController extends AsyncController<NameDetailData> {
  NameDetailController(this.args, this._names, this._audio);

  static const int _similarCount = 8;

  final NameDetailArgs args;
  final NamesRepository _names;
  final AudioService _audio;

  String get heroTag => args.heroTag ?? nameHeroTag('detail', args.id);

  /// Section for Hero tags of the similar-names row on *this* page.
  String get similarSection => 'similar-${args.tag}';

  bool get isPlaying => _audio.activeId.value == args.id;
  bool get isAudioLoading => isPlaying && _audio.isLoading.value;

  @override
  void onInit() {
    final NameModel? passed = args.name;
    if (passed != null) {
      change(NameDetailData(passed, const []), status: RxStatus.success());
    }
    super.onInit();
  }

  @override
  Future<NameDetailData> fetch() async {
    final NameModel? name = await _names.getById(args.id) ?? args.name;
    if (name == null) throw const NameNotFoundException();
    return NameDetailData(
      name,
      await _names.similar(name.id, limit: _similarCount),
    );
  }

  @override
  bool isEmptyValue(NameDetailData value) => false;

  Future<void> togglePronunciation() async {
    final String? url = state?.name.audioUrl;
    if (url == null) return;
    if (isPlaying) return _audio.stop();
    final bool ok = await _audio.play(args.id, url);
    if (!ok) _toast(LocaleKeys.detailAudioError.tr);
  }

  Future<void> share() async {
    final NameModel? n = state?.name;
    if (n == null) return;
    await AppShare.share(
      'name',
      n.id,
      ShareParams(
        subject: n.nameLatin,
        text: LocaleKeys.detailShareText.trParams({
          'latin': n.nameLatin,
          'geez': n.nameGeez,
          'meaning': Labels.meaning(n),
        }),
      ),
    );
  }

  void openShareCard() {
    final NameModel? n = state?.name;
    if (n != null) Get.toNamed<void>(Routes.shareCard, arguments: n);
  }

  void openRevealVideo() {
    final NameModel? n = state?.name;
    if (n != null) Get.toNamed<void>(Routes.revealVideo, arguments: n);
  }

  void openFullName() {
    final NameModel? n = state?.name;
    if (n != null) Get.toNamed<void>(Routes.fullName, arguments: n);
  }

  void openSimilar(NameModel name, String heroTag) =>
      AppNav.openName(name, heroTag: heroTag);

  void _toast(String message) {
    final BuildContext? ctx = Get.context;
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void onClose() {
    if (isPlaying) _audio.stop();
    super.onClose();
  }
}

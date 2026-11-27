import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../data/models/ai_feature.dart';
import '../../../translations/locale_keys.dart';
import '../../discover/controllers/ai_waitlist_controller.dart';

/// Name-style chips on the AI Name Finder card.
enum StudioStyle {
  traditional(LocaleKeys.studioStyleTraditional),
  modern(LocaleKeys.studioStyleModern),
  biblical(LocaleKeys.studioStyleBiblical),
  islamic(LocaleKeys.studioStyleIslamic),
  nature(LocaleKeys.studioStyleNature),
  easyAbroad(LocaleKeys.studioStyleEasyAbroad);

  const StudioStyle(this.labelKey);

  final String labelKey;
}

/// AI Studio tab: the two AI tools are interactive previews only. Any
/// attempt to run them opens "Coming soon" with the waitlist, prefilled
/// with what the user picked.
class StudioController extends GetxController {
  StudioController(this._waitlist);

  final AiWaitlistController _waitlist;

  // AI Name Finder
  /// 'girl' | 'boy' | null (either).
  final RxnString gender = RxnString();
  final RxSet<StudioStyle> styles = <StudioStyle>{}.obs;
  final TextEditingController prompt = TextEditingController();

  // Baby Face Preview
  final RxString babyGender = 'girl'.obs;

  /// Which feature the "Coming soon" sheet is about.
  final Rx<AiFeature> soonFeature = AiFeature.nameFinder.obs;

  bool get onWaitlist => _waitlist.joined;

  void toggleStyle(StudioStyle s) =>
      styles.contains(s) ? styles.remove(s) : styles.add(s);

  /// Prepares the "Coming soon" sheet for [feature]. For the name finder,
  /// the waitlist note is prefilled from the user's description.
  void prepareComingSoon(AiFeature feature) {
    soonFeature.value = feature;
    _waitlist.chosen.assignAll({feature});
    if (feature == AiFeature.nameFinder && prompt.text.trim().isNotEmpty) {
      _waitlist.text.text = prompt.text.trim();
    }
  }

  @override
  void onClose() {
    prompt.dispose();
    super.onClose();
  }
}

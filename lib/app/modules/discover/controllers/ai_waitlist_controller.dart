import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../data/models/ai_feature.dart';
import '../../../services/ai_waitlist_service.dart';
import '../../../translations/locale_keys.dart';

/// State of the "Coming soon" card and its bottom sheet.
class AiWaitlistController extends GetxController {
  AiWaitlistController(this._service);

  final AiWaitlistService _service;

  final TextEditingController text = TextEditingController();
  final RxSet<AiFeature> chosen = <AiFeature>{AiFeature.nameFinder}.obs;
  final RxnString errorKey = RxnString();

  /// Joined during this sheet session → show "Thank you!".
  final RxBool justJoined = false.obs;

  bool get joined => _service.joined.value;
  bool get busy => _service.busy.value;
  List<AiFeature> get joinedFeatures => _service.features;
  bool get canSubmit => chosen.isNotEmpty && !busy;

  /// Called when the sheet opens.
  void open() {
    errorKey.value = null;
    justJoined.value = false;
  }

  void toggle(AiFeature f) {
    chosen.contains(f) ? chosen.remove(f) : chosen.add(f);
    if (chosen.isNotEmpty && errorKey.value == LocaleKeys.aiPickFeature) {
      errorKey.value = null;
    }
  }

  Future<void> submit() async {
    errorKey.value = null;
    if (chosen.isEmpty) {
      errorKey.value = LocaleKeys.aiPickFeature;
      return;
    }
    try {
      await _service.join(
        text: text.text,
        chosen: chosen.toSet(),
        language: Get.locale?.languageCode ?? 'en',
      );
      justJoined.value = true;
      text.clear();
    } on AiWaitlistException {
      errorKey.value = LocaleKeys.aiErrorOffline;
    }
  }

  @override
  void onClose() {
    text.dispose();
    super.onClose();
  }
}

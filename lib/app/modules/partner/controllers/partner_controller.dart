import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/app_share.dart';
import '../../../data/models/couple.dart';
import '../../../routes/app_pages.dart';
import '../../../services/partner_service.dart';
import '../../../translations/locale_keys.dart';

class PartnerController extends GetxController {
  PartnerController(this._partner);

  final PartnerService _partner;

  final TextEditingController codeInput = TextEditingController();

  /// Translation key of the last error, if any.
  final RxnString errorKey = RxnString();

  bool get isAvailable => _partner.isAvailable;
  bool get busy => _partner.busy.value;
  bool get hasCode => _partner.hasCode && _partner.couple.value != null;
  bool get isLinked => _partner.isLinked;
  String get code => _partner.code ?? '';
  int get matchCount => _partner.matches.length;

  Future<void> create() => _run(_partner.create);

  Future<void> join() => _run(() => _partner.join(codeInput.text));

  Future<void> leave() => _run(_partner.leave);

  Future<void> copyCode() async {
    await Clipboard.setData(ClipboardData(text: code));
    final BuildContext? ctx = Get.context;
    if (ctx != null && ctx.mounted) {
      ScaffoldMessenger.of(ctx)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(LocaleKeys.partnerCopied.tr)));
    }
  }

  Future<void> shareCode() => AppShare.share(
    'partner_code',
    'partner',
    ShareParams(text: LocaleKeys.partnerShareText.trParams({'code': code})),
  );

  void openMatches() => Get.toNamed<void>(Routes.matches);

  Future<void> _run(Future<Object?> Function() action) async {
    errorKey.value = null;
    try {
      await action();
    } on PartnerException catch (e) {
      errorKey.value = switch (e.error) {
        PartnerError.invalidCode => LocaleKeys.partnerErrorInvalid,
        PartnerError.notFound => LocaleKeys.partnerErrorNotFound,
        PartnerError.full => LocaleKeys.partnerErrorFull,
        PartnerError.unavailable => LocaleKeys.partnerUnavailableTitle,
        PartnerError.unknown => LocaleKeys.partnerErrorGeneric,
      };
    }
  }

  @override
  void onClose() {
    codeInput.dispose();
    super.onClose();
  }
}

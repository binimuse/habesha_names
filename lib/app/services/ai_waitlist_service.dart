import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../data/models/ai_feature.dart';
import '../data/providers/ai_waitlist_remote.dart';
import 'storage_service.dart';

class AiWaitlistException implements Exception {
  const AiWaitlistException(this.reason);

  final String reason;

  @override
  String toString() => 'AiWaitlistException($reason)';
}

/// "Coming soon" AI features waitlist. Remembers on the device that the user
/// joined (and for which features) so the form isn't shown again.
class AiWaitlistService extends GetxService {
  AiWaitlistService(this._remote, this._storage);

  static const String _kJoined = 'ai_waitlist.joined';
  static const String _kFeatures = 'ai_waitlist.features';
  static const int maxTextLength = 500;

  final AiWaitlistRemote _remote;
  final StorageService _storage;

  final RxBool joined = false.obs;
  final RxList<AiFeature> features = <AiFeature>[].obs;
  final RxBool busy = false.obs;

  @override
  void onInit() {
    super.onInit();
    joined.value = _storage.read<bool>(_kJoined) ?? false;
    features.assignAll([
      for (final Object? c
          in _storage.read<List<dynamic>>(_kFeatures) ?? const [])
        if (c is String) ?AiFeature.fromCode(c),
    ]);
  }

  /// Saves the entry, logs analytics and subscribes to the launch topic.
  /// Only the Firestore write is required; the rest is best-effort so a
  /// denied notification permission doesn't lose the sign-up.
  Future<void> join({
    required String text,
    required Set<AiFeature> chosen,
    required String language,
  }) async {
    if (chosen.isEmpty) throw const AiWaitlistException('no_features');
    if (!_remote.isAvailable) throw const AiWaitlistException('unavailable');
    busy.value = true;
    try {
      final String? uid = await _remote.ensureUid();
      if (uid == null) throw const AiWaitlistException('unavailable');
      final List<AiFeature> list = [
        for (final AiFeature f in AiFeature.values)
          if (chosen.contains(f)) f,
      ];
      final String trimmed = text.trim();
      await _remote.addEntry(
        uid: uid,
        text: trimmed.length > maxTextLength
            ? trimmed.substring(0, maxTextLength)
            : trimmed,
        language: language,
        features: list,
      );
      await _bestEffort(
        'analytics',
        () => _remote.logJoin(language: language, features: list),
      );
      await _bestEffort('fcm', _remote.subscribeToLaunch);

      features.assignAll(list);
      joined.value = true;
      await _storage.write(_kJoined, true);
      await _storage.write(_kFeatures, [for (final f in list) f.code]);
    } on AiWaitlistException {
      rethrow;
    } catch (error) {
      debugPrint('AI waitlist join failed: $error');
      throw const AiWaitlistException('failed');
    } finally {
      busy.value = false;
    }
  }

  static Future<void> _bestEffort(
    String what,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error) {
      debugPrint('AI waitlist $what step failed (ignored): $error');
    }
  }
}

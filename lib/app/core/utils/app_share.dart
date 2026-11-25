import 'dart:async';

import 'package:share_plus/share_plus.dart';

import '../../services/analytics_service.dart';

/// Opens the system share sheet and logs the `share` analytics event.
abstract final class AppShare {
  static Future<void> share(
    String contentType,
    String itemId,
    ShareParams params,
  ) {
    unawaited(AnalyticsService.maybe?.share(contentType, itemId));
    return SharePlus.instance.share(params);
  }
}

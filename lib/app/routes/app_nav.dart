import 'package:get/get.dart';

import '../data/models/name_model.dart';
import 'app_pages.dart';

/// Arguments for [Routes.nameDetail].
class NameDetailArgs {
  NameDetailArgs({required this.id, this.name, this.heroTag})
    : tag = '$id#${_seq++}';

  /// For deep links (`/name?id=hiwot`) that arrive without arguments.
  NameDetailArgs._link(this.id) : name = null, heroTag = null, tag = '$id#link';

  /// The arguments of the route being built.
  static NameDetailArgs current() {
    final Object? args = Get.arguments;
    if (args is NameDetailArgs) return args;
    return NameDetailArgs._link(Get.parameters['id'] ?? '');
  }

  static int _seq = 0;

  final String id;

  /// Already-loaded name, so the page can render instantly.
  final NameModel? name;
  final String? heroTag;

  /// Unique per pushed page — detail pages can stack (similar → similar).
  final String tag;
}

/// Arguments for [Routes.compare].
class CompareArgs {
  const CompareArgs(this.firstId, this.secondId);

  final String firstId;
  final String secondId;
}

abstract final class AppNav {
  static Future<void>? openName(NameModel name, {String? heroTag}) =>
      Get.toNamed<void>(
        Routes.nameDetail,
        arguments: NameDetailArgs(id: name.id, name: name, heroTag: heroTag),
        preventDuplicates: false,
      );

  static Future<void>? openCompare(String firstId, String secondId) =>
      Get.toNamed<void>(
        Routes.compare,
        arguments: CompareArgs(firstId, secondId),
      );
}

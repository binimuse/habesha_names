import 'package:get/get.dart';

import '../../../core/base/async_controller.dart';
import '../../../data/models/name_model.dart';
import '../../../data/repositories/names_repository.dart';
import '../../../routes/app_nav.dart';

class ComparePair {
  const ComparePair(this.first, this.second);

  final NameModel first;
  final NameModel second;
}

class CompareController extends AsyncController<ComparePair?> {
  CompareController(this._names);

  final NamesRepository _names;

  /// Read once at construction, while this route's arguments are current.
  final CompareArgs? args = Get.arguments is CompareArgs
      ? Get.arguments as CompareArgs
      : null;

  @override
  Future<ComparePair?> fetch() async {
    final CompareArgs? a = args;
    if (a == null) return null;
    final List<NameModel> names = await _names.getByIds([
      a.firstId,
      a.secondId,
    ]);
    return names.length == 2 ? ComparePair(names[0], names[1]) : null;
  }

  @override
  bool isEmptyValue(ComparePair? value) => value == null;
}

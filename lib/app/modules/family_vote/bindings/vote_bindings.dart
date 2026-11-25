import 'package:get/get.dart';

import '../../../data/repositories/names_repository.dart';
import '../../../services/favorites_service.dart';
import '../../../services/vote_service.dart';
import '../controllers/vote_controllers.dart';

class VoteCreateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VoteCreateController>(
      () => VoteCreateController(
        Get.find<VoteService>(),
        Get.find<FavoritesService>(),
        Get.find<NamesRepository>(),
      ),
    );
  }
}

/// Route arguments: the vote id.
class VoteResultsBinding extends Bindings {
  @override
  void dependencies() {
    final String id = Get.arguments as String;
    Get.lazyPut<VoteResultsController>(
      () => VoteResultsController(id, Get.find<VoteService>()),
    );
  }
}

class VotesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VotesController>(
      () => VotesController(Get.find<VoteService>()),
    );
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../services/crash_reporter.dart';

/// Base for screens that load data asynchronously.
///
/// Drives GetX's [StateMixin] so views can use `controller.obx(...)` with
/// `onLoading`, `onEmpty` and `onError` — every screen gets the three states.
abstract class AsyncController<T> extends GetxController with StateMixin<T> {
  /// Load on start. Return false for screens that wait for user input.
  bool get loadOnInit => true;

  /// When this emits, data is reloaded silently (no loading spinner),
  /// e.g. after a background sync.
  Stream<void>? get refreshTrigger => null;

  /// Fetches the data. Throwing puts the screen in the error state.
  @protected
  Future<T> fetch();

  /// Whether [value] should show the empty state.
  @protected
  bool isEmptyValue(T value);

  /// Reactive "data is on screen" flag. StateMixin's [status] is not an Rx,
  /// so `Obx` widgets must read this instead.
  final RxBool isReady = false.obs;

  @override
  void change(T? newState, {RxStatus? status}) {
    super.change(newState, status: status);
    if (status != null) isReady.value = status.isSuccess;
  }

  StreamSubscription<void>? _refreshSub;

  @override
  void onInit() {
    super.onInit();
    _refreshSub = refreshTrigger?.listen((_) => load(silent: true));
    if (loadOnInit) {
      // A prefilled state (e.g. passed via route arguments) refreshes quietly.
      load(silent: state != null);
    } else {
      change(null, status: RxStatus.empty());
    }
  }

  Future<void> load({bool silent = false}) async {
    if (!silent || state == null) change(state, status: RxStatus.loading());
    try {
      final T value = await fetch();
      change(
        value,
        status: isEmptyValue(value) ? RxStatus.empty() : RxStatus.success(),
      );
    } catch (error, stack) {
      CrashReporter.record(error, stack, reason: '$runtimeType.load');
      // Keep showing existing data after a failed quiet refresh.
      if (!silent || state == null) {
        change(null, status: RxStatus.error(error.toString()));
      }
    }
  }

  @override
  void onClose() {
    _refreshSub?.cancel();
    super.onClose();
  }
}

/// [AsyncController] for plain lists: empty list → empty state.
abstract class AsyncListController<T> extends AsyncController<List<T>> {
  @override
  bool isEmptyValue(List<T> value) => value.isEmpty;
}

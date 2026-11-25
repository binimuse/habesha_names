import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

/// Plays name pronunciations, one at a time.
class AudioService extends GetxService {
  AudioService({bool Function()? offlineCache})
    : _offlineCache = offlineCache ?? (() => false);

  /// Premium: keep downloaded pronunciations on disk for offline use.
  final bool Function() _offlineCache;

  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _sub;

  /// Id of the name currently loading or playing.
  final RxnString activeId = RxnString();
  final RxBool isLoading = false.obs;

  AudioPlayer get _p {
    final AudioPlayer? existing = _player;
    if (existing != null) return existing;
    final AudioPlayer created = AudioPlayer();
    _sub = created.playerStateStream.listen((s) {
      if (s.processingState == ProcessingState.completed) {
        activeId.value = null;
      }
    });
    return _player = created;
  }

  /// Returns false if the audio could not be played.
  Future<bool> play(String id, String url) async {
    try {
      activeId.value = id;
      isLoading.value = true;
      await _p.stop();
      await _p.setAudioSource(
        _offlineCache()
            // just_audio’s only built-in disk cache; marked experimental.
            // ignore: experimental_member_use
            ? LockCachingAudioSource(Uri.parse(url))
            : AudioSource.uri(Uri.parse(url)),
      );
      isLoading.value = false;
      unawaited(_p.play());
      return true;
    } catch (error) {
      debugPrint('Audio failed for $id: $error');
      activeId.value = null;
      isLoading.value = false;
      return false;
    }
  }

  Future<void> stop() async {
    activeId.value = null;
    isLoading.value = false;
    await _player?.stop();
  }

  @override
  void onClose() {
    _sub?.cancel();
    _player?.dispose();
    super.onClose();
  }
}

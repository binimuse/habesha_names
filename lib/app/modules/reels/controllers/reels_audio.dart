import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../../data/models/name_model.dart';

/// Minimal player surface so the preload logic can be tested.
abstract interface class ReelsPlayer {
  Future<void> load(String url);
  Future<void> play();
  Future<void> pause();
  Future<void> dispose();
}

class JustAudioReelsPlayer implements ReelsPlayer {
  final AudioPlayer _p = AudioPlayer();

  @override
  Future<void> load(String url) => _p.setUrl(url, preload: true);

  @override
  Future<void> play() async {
    await _p.seek(Duration.zero);
    await _p.play();
  }

  @override
  Future<void> pause() => _p.pause();

  @override
  Future<void> dispose() => _p.dispose();
}

/// Keeps players for the current page and the next [ahead] pages loaded,
/// so pronunciation starts instantly when the user swipes.
class ReelsAudio {
  ReelsAudio({ReelsPlayer Function()? create, this.ahead = 3})
    : _create = create ?? JustAudioReelsPlayer.new;

  final ReelsPlayer Function() _create;
  final int ahead;
  final Map<String, ReelsPlayer> _players = {};
  String? _playingId;

  /// Ids currently loaded (for tests / debugging).
  Iterable<String> get loadedIds => _players.keys;

  /// Preloads `[index, index + ahead]` and (optionally) plays [index].
  Future<void> focus(
    List<NameModel> deck,
    int index, {
    required bool play,
  }) async {
    final List<NameModel> window = [
      for (int i = index; i <= index + ahead && i < deck.length; i++)
        if (deck[i].audioUrl != null) deck[i],
    ];
    final Set<String> keep = {for (final n in window) n.id};

    // Stop the current clip before its player may be released.
    await pause();

    for (final String id in [..._players.keys]) {
      if (!keep.contains(id)) await _players.remove(id)!.dispose();
    }
    for (final NameModel n in window) {
      if (_players.containsKey(n.id)) continue;
      final ReelsPlayer p = _create();
      _players[n.id] = p;
      try {
        await p.load(n.audioUrl!);
      } catch (error) {
        debugPrint('Reels preload failed for ${n.id}: $error');
      }
    }

    final String? currentId = index < deck.length ? deck[index].id : null;
    if (play && currentId != null && _players[currentId] != null) {
      _playingId = currentId;
      try {
        await _players[currentId]!.play();
      } catch (error) {
        debugPrint('Reels play failed for $currentId: $error');
      }
    }
  }

  Future<void> pause() async {
    final String? id = _playingId;
    _playingId = null;
    if (id != null) await _players[id]?.pause();
  }

  Future<void> dispose() async {
    for (final ReelsPlayer p in _players.values) {
      await p.dispose();
    }
    _players.clear();
  }
}

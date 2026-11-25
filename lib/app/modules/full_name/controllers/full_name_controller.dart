import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/text/geez.dart';
import '../../../core/text/latin_to_geez.dart';
import '../../../core/text/name_normalizer.dart';
import '../../../core/text/name_sound_score.dart';
import '../../../data/models/name_model.dart';
import '../../../data/repositories/names_repository.dart';
import '../../../services/storage_service.dart';

/// One part of a full name in both scripts.
class ScriptName {
  const ScriptName({
    required this.latin,
    required this.geez,
    this.approxLatin = false,
    this.approxGeez = false,
  });

  final String latin;
  final String geez;

  /// True when that script was transliterated rather than known.
  final bool approxLatin;
  final bool approxGeez;
}

class FullNamePreview {
  const FullNamePreview(this.parts, this.score);

  final List<ScriptName> parts;
  final NameSoundScore? score;

  String get latin => parts.map((p) => p.latin).join(' ');
  String get geez => parts.map((p) => p.geez).join(' ');
  bool get approxLatin => parts.any((p) => p.approxLatin);
  bool get approxGeez => parts.any((p) => p.approxGeez);
}

enum SoundGrade { great, good, ok, clash }

/// Given name + father's + grandfather's name (Habesha naming).
class FullNameController extends GetxController {
  FullNameController(this.name, this._names, this._storage);

  static const String _kFather = 'full_name.father';
  static const String _kGrandfather = 'full_name.grandfather';
  static const Duration _debounce = Duration(milliseconds: 250);

  /// The given (first) name.
  final NameModel name;
  final NamesRepository _names;
  final StorageService _storage;

  late final TextEditingController father = TextEditingController(
    text: _storage.read<String>(_kFather) ?? '',
  );
  late final TextEditingController grandfather = TextEditingController(
    text: _storage.read<String>(_kGrandfather) ?? '',
  );

  final Rx<FullNamePreview> preview = const FullNamePreview([], null).obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    father.addListener(_schedule);
    grandfather.addListener(_schedule);
    refreshPreview();
  }

  static SoundGrade gradeOf(int total) => total >= 85
      ? SoundGrade.great
      : total >= 70
      ? SoundGrade.good
      : total >= 50
      ? SoundGrade.ok
      : SoundGrade.clash;

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(_debounce, refreshPreview);
  }

  Future<void> refreshPreview() async {
    final ScriptName given = ScriptName(
      latin: name.nameLatin,
      geez: name.nameGeez,
    );
    final ScriptName? f = await _resolve(father.text);
    final ScriptName? g = await _resolve(grandfather.text);
    final List<ScriptName> parts = [given, ?f, ?g];
    preview.value = FullNamePreview(
      parts,
      f == null
          ? null
          : NameSoundScore.of(
              [given.latin, f.latin, g?.latin ?? ''],
              knownSyllables: {if (name.syllables > 0) 0: name.syllables},
            ),
    );
    await _storage.write(_kFather, father.text.trim());
    await _storage.write(_kGrandfather, grandfather.text.trim());
  }

  /// Uses our database when the name is known, otherwise transliterates.
  Future<ScriptName?> _resolve(String raw) async {
    final String input = raw.trim();
    if (input.isEmpty) return null;
    final List<NameModel> hits = await _names.search(input);
    if (Geez.containsEthiopic(input)) {
      final String folded = NameNormalizer.foldText(input);
      for (final NameModel n in hits) {
        if (NameNormalizer.foldText(n.nameGeez) == folded) {
          return ScriptName(latin: n.nameLatin, geez: input);
        }
      }
      return ScriptName(
        latin: GeezToLatin.convert(input),
        geez: input,
        approxLatin: true,
      );
    }
    final String latin = _capitalize(input);
    final String lower = input.toLowerCase();
    for (final NameModel n in hits) {
      if (n.latinForms.any((f) => f.toLowerCase() == lower)) {
        return ScriptName(latin: latin, geez: n.nameGeez);
      }
    }
    return ScriptName(
      latin: latin,
      geez: LatinToGeez.convert(input),
      approxGeez: true,
    );
  }

  static String _capitalize(String s) => s
      .split(RegExp(r'\s+'))
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');

  @override
  void onClose() {
    _timer?.cancel();
    father.dispose();
    grandfather.dispose();
    super.onClose();
  }
}

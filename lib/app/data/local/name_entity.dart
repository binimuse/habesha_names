import 'package:isar_community/isar.dart';

import '../models/gender.dart';
import '../models/name_model.dart';
import '../models/rarity.dart';

part 'name_entity.g.dart';

/// Isar row for a [NameModel]. Regenerate after changes with:
/// `dart run build_runner build --delete-conflicting-outputs`
@collection
class NameEntity {
  /// Stable Isar id derived from [nameId], so a put replaces the same row.
  Id get isarId => fastHash(nameId);

  @Index(unique: true, replace: true)
  late String nameId;

  late String nameLatin;
  late String nameGeez;
  List<String> spellings = [];

  @Enumerated(EnumType.name)
  late Gender gender;

  List<String> languages = [];
  List<String> faiths = [];
  late String meaningEn;
  late String meaningAm;
  List<String> themes = [];
  String? pronunciation;
  String? audioUrl;
  late int syllables;
  late bool easyAbroad;
  late String originEn;
  late String originAm;
  List<String> nicknames = [];
  List<String> similar = [];
  List<String> famous = [];
  late bool verified;
  late int popularity;
  bool modern = false;

  @Enumerated(EnumType.name)
  Rarity rarity = Rarity.unique;

  int trendScore = 0;

  @Index()
  late DateTime updatedAt;

  static NameEntity fromModel(NameModel m) => NameEntity()
    ..nameId = m.id
    ..nameLatin = m.nameLatin
    ..nameGeez = m.nameGeez
    ..spellings = m.spellings
    ..gender = m.gender
    ..languages = m.languages
    ..faiths = m.faiths
    ..meaningEn = m.meaningEn
    ..meaningAm = m.meaningAm
    ..themes = m.themes
    ..pronunciation = m.pronunciation
    ..audioUrl = m.audioUrl
    ..syllables = m.syllables
    ..easyAbroad = m.easyAbroad
    ..originEn = m.originEn
    ..originAm = m.originAm
    ..nicknames = m.nicknames
    ..similar = m.similar
    ..famous = m.famous
    ..verified = m.verified
    ..popularity = m.popularity
    ..modern = m.modern
    ..rarity = m.rarity
    ..trendScore = m.trendScore
    ..updatedAt = m.updatedAt;

  NameModel toModel() => NameModel(
    id: nameId,
    nameLatin: nameLatin,
    nameGeez: nameGeez,
    spellings: List.unmodifiable(spellings),
    gender: gender,
    languages: List.unmodifiable(languages),
    faiths: List.unmodifiable(faiths),
    meaningEn: meaningEn,
    meaningAm: meaningAm,
    themes: List.unmodifiable(themes),
    pronunciation: pronunciation,
    audioUrl: audioUrl,
    syllables: syllables,
    easyAbroad: easyAbroad,
    originEn: originEn,
    originAm: originAm,
    nicknames: List.unmodifiable(nicknames),
    similar: List.unmodifiable(similar),
    famous: List.unmodifiable(famous),
    verified: verified,
    popularity: popularity,
    modern: modern,
    rarity: rarity,
    trendScore: trendScore,
    updatedAt: updatedAt.toUtc(),
  );
}

/// FNV-1a 64-bit hash, as recommended by Isar for String ids.
int fastHash(String string) {
  int hash = 0xcbf29ce484222325;
  int i = 0;
  while (i < string.length) {
    final int codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }
  return hash;
}

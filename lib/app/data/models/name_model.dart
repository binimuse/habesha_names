import 'gender.dart';
import 'rarity.dart';

/// A baby name. Pure Dart (no Flutter imports) so `tools/` scripts and tests
/// can use it.
///
/// JSON / Firestore use snake_case keys, see [NameFields].
/// Vocabulary fields (`languages`, `faiths`, `themes`) hold lowercase codes,
/// e.g. `amharic`, `orthodox`, `nature`.
class NameModel {
  const NameModel({
    required this.id,
    required this.nameLatin,
    required this.nameGeez,
    required this.gender,
    required this.updatedAt,
    this.spellings = const [],
    this.languages = const [],
    this.faiths = const [],
    this.meaningEn = '',
    this.meaningAm = '',
    this.themes = const [],
    this.pronunciation,
    this.audioUrl,
    this.syllables = 0,
    this.easyAbroad = false,
    this.originEn = '',
    this.originAm = '',
    this.nicknames = const [],
    this.similar = const [],
    this.famous = const [],
    this.verified = false,
    this.popularity = 0,
    this.modern = false,
    this.rarity = Rarity.unique,
    this.trendScore = 0,
  });

  factory NameModel.fromJson(Map<String, dynamic> json) {
    final String id = _string(json[NameFields.id]);
    final Gender? gender = Gender.tryParse(json[NameFields.gender] as String?);
    if (id.isEmpty) throw const FormatException('Name is missing "id"');
    if (gender == null) {
      throw FormatException('Name "$id" has invalid gender', json['gender']);
    }
    return NameModel(
      id: id,
      nameLatin: _string(json[NameFields.nameLatin]),
      nameGeez: _string(json[NameFields.nameGeez]),
      spellings: _strings(json[NameFields.spellings]),
      gender: gender,
      languages: _codes(json[NameFields.languages]),
      faiths: _codes(json[NameFields.faiths]),
      meaningEn: _string(json[NameFields.meaningEn]),
      meaningAm: _string(json[NameFields.meaningAm]),
      themes: _codes(json[NameFields.themes]),
      pronunciation: _nullableString(json[NameFields.pronunciation]),
      audioUrl: _nullableString(json[NameFields.audioUrl]),
      syllables: (json[NameFields.syllables] as num?)?.toInt() ?? 0,
      easyAbroad: json[NameFields.easyAbroad] as bool? ?? false,
      originEn: _string(json[NameFields.originEn]),
      originAm: _string(json[NameFields.originAm]),
      nicknames: _strings(json[NameFields.nicknames]),
      similar: _strings(json[NameFields.similar]),
      famous: _strings(json[NameFields.famous]),
      verified: json[NameFields.verified] as bool? ?? false,
      popularity: (json[NameFields.popularity] as num?)?.toInt() ?? 0,
      modern: json[NameFields.modern] as bool? ?? false,
      rarity:
          Rarity.tryParse(json[NameFields.rarity] as String?) ?? Rarity.unique,
      trendScore: (json[NameFields.trendScore] as num?)?.toInt() ?? 0,
      updatedAt: parseDate(json[NameFields.updatedAt]),
    );
  }

  final String id;
  final String nameLatin;
  final String nameGeez;

  /// Alternative Latin spellings, e.g. `Hiwot`, `Heywet`, `Hiywet`.
  final List<String> spellings;
  final Gender gender;
  final List<String> languages;
  final List<String> faiths;
  final String meaningEn;
  final String meaningAm;
  final List<String> themes;

  /// Human-readable guide, e.g. `HEE-wot`.
  final String? pronunciation;
  final String? audioUrl;
  final int syllables;

  /// Easy to say and spell for non-Ethiopians.
  final bool easyAbroad;
  final String originEn;
  final String originAm;
  final List<String> nicknames;

  /// Ids of related names.
  final List<String> similar;

  /// Well-known people with this name.
  final List<String> famous;
  final bool verified;

  /// 0–100, used for ranking.
  final int popularity;

  /// A contemporary name (vs. traditional / biblical).
  final bool modern;

  /// Computed daily on the server from recent likes.
  final Rarity rarity;

  /// Likes in the last 7 days (updated daily).
  final int trendScore;
  final DateTime updatedAt;

  /// [nameLatin] followed by every spelling not already equal to it.
  List<String> get latinForms => [
    nameLatin,
    for (final String s in spellings)
      if (s.toLowerCase() != nameLatin.toLowerCase()) s,
  ];

  Map<String, dynamic> toJson() => {
    NameFields.id: id,
    NameFields.nameLatin: nameLatin,
    NameFields.nameGeez: nameGeez,
    NameFields.spellings: spellings,
    NameFields.gender: gender.name,
    NameFields.languages: languages,
    NameFields.faiths: faiths,
    NameFields.meaningEn: meaningEn,
    NameFields.meaningAm: meaningAm,
    NameFields.themes: themes,
    NameFields.pronunciation: pronunciation,
    NameFields.audioUrl: audioUrl,
    NameFields.syllables: syllables,
    NameFields.easyAbroad: easyAbroad,
    NameFields.originEn: originEn,
    NameFields.originAm: originAm,
    NameFields.nicknames: nicknames,
    NameFields.similar: similar,
    NameFields.famous: famous,
    NameFields.verified: verified,
    NameFields.popularity: popularity,
    NameFields.modern: modern,
    NameFields.rarity: rarity.name,
    NameFields.trendScore: trendScore,
    NameFields.updatedAt: updatedAt.toUtc().toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      other is NameModel && other.id == id && other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(id, updatedAt);

  @override
  String toString() => 'NameModel($id, $nameLatin / $nameGeez)';

  /// Accepts ISO-8601 strings, epoch milliseconds or [DateTime].
  static DateTime parseDate(Object? value) {
    if (value is DateTime) return value.toUtc();
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value).toUtc();
    }
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  static String _string(Object? v) => (v as String?)?.trim() ?? '';

  static String? _nullableString(Object? v) {
    final String s = _string(v);
    return s.isEmpty ? null : s;
  }

  static List<String> _strings(Object? v) => [
    for (final Object? e in (v as List<Object?>?) ?? const [])
      if (e is String && e.trim().isNotEmpty) e.trim(),
  ];

  static List<String> _codes(Object? v) => [
    for (final String s in _strings(v)) s.toLowerCase(),
  ];
}

/// JSON / Firestore / CSV column names.
abstract final class NameFields {
  static const String id = 'id';
  static const String nameLatin = 'name_latin';
  static const String nameGeez = 'name_geez';
  static const String spellings = 'spellings';
  static const String gender = 'gender';
  static const String languages = 'languages';
  static const String faiths = 'faiths';
  static const String meaningEn = 'meaning_en';
  static const String meaningAm = 'meaning_am';
  static const String themes = 'themes';
  static const String pronunciation = 'pronunciation';
  static const String audioUrl = 'audio_url';
  static const String syllables = 'syllables';
  static const String easyAbroad = 'easy_abroad';
  static const String originEn = 'origin_en';
  static const String originAm = 'origin_am';
  static const String nicknames = 'nicknames';
  static const String similar = 'similar';
  static const String famous = 'famous';
  static const String verified = 'verified';
  static const String popularity = 'popularity';
  static const String modern = 'modern';
  static const String rarity = 'rarity';
  static const String trendScore = 'trend_score';
  static const String updatedAt = 'updated_at';

  /// Set on a Firestore doc to remove the name from devices.
  static const String deleted = 'deleted';

  static const List<String> all = [
    id, nameLatin, nameGeez, spellings, gender, languages, faiths, //
    meaningEn, meaningAm, themes, pronunciation, audioUrl, syllables,
    easyAbroad, originEn, originAm, nicknames, similar, famous, verified,
    popularity, modern, rarity, trendScore, updatedAt,
  ];

  static const Set<String> listFields = {
    spellings,
    languages,
    faiths,
    themes,
    nicknames,
    similar,
    famous,
  };
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// A `names/{id}` document, same snake_case fields as the app's NameModel.
///
/// `rarity` and `trend_score` are owned by the updateTrends function and are
/// shown read-only; `updated_at` is set by the server on every save so
/// phones pick the change up on their next sync.
class AdminName {
  const AdminName({
    required this.id,
    required this.nameLatin,
    required this.nameGeez,
    required this.gender,
    this.spellings = const [],
    this.languages = const [],
    this.faiths = const [],
    this.themes = const [],
    this.meaningEn = '',
    this.meaningAm = '',
    this.pronunciation = '',
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
    this.rarity,
    this.trendScore = 0,
    this.deleted = false,
    this.updatedAt,
  });

  final String id;
  final String nameLatin;
  final String nameGeez;
  final String gender;
  final List<String> spellings;
  final List<String> languages;
  final List<String> faiths;
  final List<String> themes;
  final String meaningEn;
  final String meaningAm;
  final String pronunciation;
  final String? audioUrl;
  final int syllables;
  final bool easyAbroad;
  final String originEn;
  final String originAm;
  final List<String> nicknames;
  final List<String> similar;
  final List<String> famous;
  final bool verified;
  final int popularity;
  final bool modern;
  final String? rarity;
  final num trendScore;
  final bool deleted;
  final DateTime? updatedAt;

  factory AdminName.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> d = doc.data() ?? const {};
    List<String> list(String k) => [
      for (final Object? v in (d[k] as List<dynamic>? ?? const []))
        if (v is String) v,
    ];
    String str(String k) => (d[k] as String?) ?? '';
    return AdminName(
      id: doc.id,
      nameLatin: str('name_latin'),
      nameGeez: str('name_geez'),
      gender: str('gender'),
      spellings: list('spellings'),
      languages: list('languages'),
      faiths: list('faiths'),
      themes: list('themes'),
      meaningEn: str('meaning_en'),
      meaningAm: str('meaning_am'),
      pronunciation: str('pronunciation'),
      audioUrl: d['audio_url'] as String?,
      syllables: (d['syllables'] as num?)?.toInt() ?? 0,
      easyAbroad: d['easy_abroad'] == true,
      originEn: str('origin_en'),
      originAm: str('origin_am'),
      nicknames: list('nicknames'),
      similar: list('similar'),
      famous: list('famous'),
      verified: d['verified'] == true,
      popularity: (d['popularity'] as num?)?.toInt() ?? 0,
      modern: d['modern'] == true,
      rarity: d['rarity'] as String?,
      trendScore: (d['trend_score'] as num?) ?? 0,
      deleted: d['deleted'] == true,
      updatedAt: (d['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  /// Editable fields only (no rarity / trend_score / updated_at).
  Map<String, Object?> toEditableMap() => {
    'id': id,
    'name_latin': nameLatin,
    'name_geez': nameGeez,
    'gender': gender,
    'spellings': spellings,
    'languages': languages,
    'faiths': faiths,
    'themes': themes,
    'meaning_en': meaningEn,
    'meaning_am': meaningAm,
    'pronunciation': pronunciation,
    'audio_url': (audioUrl?.isEmpty ?? true) ? null : audioUrl,
    'syllables': syllables,
    'easy_abroad': easyAbroad,
    'origin_en': originEn,
    'origin_am': originAm,
    'nicknames': nicknames,
    'similar': similar,
    'famous': famous,
    'verified': verified,
    'popularity': popularity,
    'modern': modern,
  };
}

enum NameStatus {
  /// Only in `name_drafts` — phones don't see it.
  draft,

  /// Live in `names`.
  published,

  /// Live, with unpublished edits waiting in `name_drafts`.
  changed,

  /// Soft-deleted in `names` (phones removed it).
  deleted,
}

/// A name as the admin sees it: the live version and/or a draft.
class NameEntry {
  const NameEntry({this.published, this.draft})
    : assert(published != null || draft != null);

  final AdminName? published;
  final AdminName? draft;

  String get id => (draft ?? published)!.id;

  /// What the editor shows: the draft if there is one.
  AdminName get current => (draft ?? published)!;

  NameStatus get status {
    if (published == null) return NameStatus.draft;
    if (draft != null) return NameStatus.changed;
    return published!.deleted ? NameStatus.deleted : NameStatus.published;
  }

  /// Combines both collections by id, sorted by Latin spelling.
  static List<NameEntry> merge(
    List<AdminName> published,
    List<AdminName> drafts,
  ) {
    final Map<String, AdminName> live = {for (final n in published) n.id: n};
    final Map<String, AdminName> draft = {for (final n in drafts) n.id: n};
    return [
      for (final String id in {...live.keys, ...draft.keys})
        NameEntry(published: live[id], draft: draft[id]),
    ]..sort(
      (a, b) => a.current.nameLatin.toLowerCase().compareTo(
        b.current.nameLatin.toLowerCase(),
      ),
    );
  }
}

import 'dart:convert';

import 'package:habesha_names/app/data/models/gender.dart';
import 'package:habesha_names/app/data/models/name_model.dart';
import 'package:habesha_names/app/data/models/rarity.dart';

/// RFC 4180 CSV parser: quoted fields, `""` escapes, newlines inside quotes,
/// CRLF/LF line endings and a leading UTF-8 BOM. Blank lines are skipped.
List<List<String>> parseCsv(String input) {
  final String s = input.startsWith('﻿') ? input.substring(1) : input;
  final List<List<String>> rows = [];
  List<String> row = [];
  final StringBuffer field = StringBuffer();
  bool inQuotes = false;

  void endField() {
    row.add(field.toString());
    field.clear();
  }

  void endRow() {
    endField();
    if (!(row.length == 1 && row.first.trim().isEmpty)) rows.add(row);
    row = [];
  }

  for (int i = 0; i < s.length; i++) {
    final String c = s[i];
    if (inQuotes) {
      if (c == '"') {
        if (i + 1 < s.length && s[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        field.write(c);
      }
    } else if (c == '"') {
      inQuotes = true;
    } else if (c == ',') {
      endField();
    } else if (c == '\n' || c == '\r') {
      if (c == '\r' && i + 1 < s.length && s[i + 1] == '\n') i++;
      endRow();
    } else {
      field.write(c);
    }
  }
  if (inQuotes) throw const FormatException('Unterminated quoted field');
  if (field.isNotEmpty || row.isNotEmpty) endRow();
  return rows;
}

class CsvConversion {
  CsvConversion(this.names, this.errors, this.warnings);

  final List<NameModel> names;
  final List<String> errors;
  final List<String> warnings;

  bool get ok => errors.isEmpty;
}

/// Converts parsed CSV rows (first row = header, snake_case column names as
/// in [NameFields]) to names. List columns use `|` between values.
///
/// [previous] (by id) keeps `updated_at` stable for unchanged rows; changed
/// or new rows without an explicit `updated_at` get [now].
CsvConversion convertRows(
  List<List<String>> rows, {
  required DateTime now,
  Map<String, NameModel> previous = const {},
}) {
  final List<String> errors = [];
  final List<String> warnings = [];
  if (rows.isEmpty) return CsvConversion(const [], ['CSV is empty'], warnings);

  final List<String> header = [
    for (final String h in rows.first) h.trim().toLowerCase(),
  ];
  for (final String required in [
    NameFields.nameLatin,
    NameFields.nameGeez,
    NameFields.gender,
  ]) {
    if (!header.contains(required)) errors.add('Missing column "$required"');
  }
  for (final String h in header) {
    if (h.isNotEmpty && !NameFields.all.contains(h)) {
      warnings.add('Unknown column "$h" is ignored');
    }
  }
  if (errors.isNotEmpty) return CsvConversion(const [], errors, warnings);

  final List<NameModel> names = [];
  final Set<String> ids = {};

  for (int r = 1; r < rows.length; r++) {
    final int line = r + 1;
    final Map<String, String> cell = {
      for (int c = 0; c < header.length; c++)
        header[c]: c < rows[r].length ? rows[r][c].trim() : '',
    };
    String text(String key) => cell[key] ?? '';
    List<String> list(String key) => [
      for (final String v in text(key).split('|'))
        if (v.trim().isNotEmpty) v.trim(),
    ];

    final String latin = text(NameFields.nameLatin);
    final String id = text(NameFields.id).isNotEmpty
        ? text(NameFields.id)
        : slugify(latin);
    if (latin.isEmpty || text(NameFields.nameGeez).isEmpty) {
      errors.add('Line $line: name_latin and name_geez are required');
      continue;
    }
    if (!ids.add(id)) {
      errors.add('Line $line: duplicate id "$id"');
      continue;
    }
    final Gender? gender = Gender.tryParse(text(NameFields.gender));
    if (gender == null) {
      errors.add('Line $line ($id): invalid gender "${text('gender')}"');
      continue;
    }

    int? integer(String key) {
      final String v = text(key);
      if (v.isEmpty) return 0;
      final int? parsed = int.tryParse(v);
      if (parsed == null) {
        errors.add('Line $line ($id): $key "$v" is not a number');
      }
      return parsed;
    }

    bool? boolean(String key) {
      final String v = text(key).toLowerCase();
      if (const ['', 'false', 'no', 'n', '0'].contains(v)) return false;
      if (const ['true', 'yes', 'y', '1'].contains(v)) return true;
      errors.add('Line $line ($id): $key "$v" is not true/false');
      return null;
    }

    final int? syllables = integer(NameFields.syllables);
    final int? popularity = integer(NameFields.popularity);
    final bool? easyAbroad = boolean(NameFields.easyAbroad);
    final bool? verified = boolean(NameFields.verified);
    final bool? modern = boolean(NameFields.modern);
    if ([syllables, popularity, easyAbroad, verified, modern].contains(null)) {
      continue;
    }

    DateTime? explicitDate;
    if (text(NameFields.updatedAt).isNotEmpty) {
      explicitDate = DateTime.tryParse(text(NameFields.updatedAt))?.toUtc();
      if (explicitDate == null) {
        errors.add('Line $line ($id): updated_at is not an ISO-8601 date');
        continue;
      }
    }

    NameModel build(DateTime updatedAt) => NameModel(
      id: id,
      nameLatin: latin,
      nameGeez: text(NameFields.nameGeez),
      spellings: list(NameFields.spellings),
      gender: gender,
      languages: [for (final v in list(NameFields.languages)) v.toLowerCase()],
      faiths: [for (final v in list(NameFields.faiths)) v.toLowerCase()],
      meaningEn: text(NameFields.meaningEn),
      meaningAm: text(NameFields.meaningAm),
      themes: [for (final v in list(NameFields.themes)) v.toLowerCase()],
      pronunciation: _nullIfEmpty(text(NameFields.pronunciation)),
      audioUrl: _nullIfEmpty(text(NameFields.audioUrl)),
      syllables: syllables!,
      easyAbroad: easyAbroad!,
      originEn: text(NameFields.originEn),
      originAm: text(NameFields.originAm),
      nicknames: list(NameFields.nicknames),
      similar: list(NameFields.similar),
      famous: list(NameFields.famous),
      verified: verified!,
      modern: modern!,
      popularity: popularity!,
      updatedAt: updatedAt,
    );

    NameModel name = build(explicitDate ?? now);
    final NameModel? before = previous[id];
    if (explicitDate == null && before != null && _sameContent(before, name)) {
      name = build(before.updatedAt);
    }

    if (name.meaningEn.isEmpty) warnings.add('$id: meaning_en is empty');
    if (name.syllables == 0) warnings.add('$id: syllables is 0');
    names.add(name);
  }

  for (final NameModel n in names) {
    for (final String s in n.similar) {
      if (!ids.contains(s)) warnings.add('${n.id}: similar id "$s" not found');
    }
  }

  names.sort((a, b) => a.id.compareTo(b.id));
  return CsvConversion(_withRarity(names, previous), errors, warnings);
}

/// Initial rarity from curated popularity (the server later re-ranks by
/// recent likes). Rarity depends on every row, so the "unchanged row keeps its
/// previous updated_at" check is redone here with the final values.
List<NameModel> _withRarity(
  List<NameModel> names,
  Map<String, NameModel> previous,
) {
  final Map<String, NameModel> byId = {for (final n in names) n.id: n};
  final Map<String, Rarity> rarity = RarityRanker.rank(
    byId.keys,
    trend: (id) => byId[id]!.trendScore,
    popularity: (id) => byId[id]!.popularity,
  );
  return [
    for (final NameModel n in names)
      () {
        final NameModel ranked = NameModel.fromJson(
          n.toJson()..[NameFields.rarity] = rarity[n.id]!.name,
        );
        final NameModel? before = previous[n.id];
        if (before == null || !_sameContent(before, ranked)) return ranked;
        return NameModel.fromJson(
          ranked.toJson()
            ..[NameFields.updatedAt] = before.updatedAt.toIso8601String(),
        );
      }(),
  ];
}

/// `Tsion Abebe` → `tsion-abebe`.
String slugify(String s) => s
    .toLowerCase()
    .replaceAll(RegExp('[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');

String? _nullIfEmpty(String s) => s.isEmpty ? null : s;

bool _sameContent(NameModel a, NameModel b) {
  Map<String, dynamic> strip(NameModel n) =>
      n.toJson()..remove(NameFields.updatedAt);
  return jsonEncode(strip(a)) == jsonEncode(strip(b));
}

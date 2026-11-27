import 'dart:convert';

import '../data/admin_name.dart';
import 'vocab.dart';

/// Parses CSV (comma) or a paste from Excel / Google Sheets (tab-separated).
/// RFC 4180 quoting: `"a, b"`, `""` escapes, newlines inside quotes, CRLF,
/// leading BOM. Blank lines are skipped.
List<List<String>> parseDelimited(String input) {
  final String s = input.startsWith('﻿') ? input.substring(1) : input;
  final String firstLine = s.split(RegExp(r'\r?\n')).first;
  final String sep = firstLine.contains('\t') ? '\t' : ',';

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
    if (!row.every((c) => c.trim().isEmpty)) rows.add(row);
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
    } else if (c == '"' && field.isEmpty) {
      inQuotes = true;
    } else if (c == sep) {
      endField();
    } else if (c == '\n' || c == '\r') {
      if (c == '\r' && i + 1 < s.length && s[i + 1] == '\n') i++;
      endRow();
    } else {
      field.write(c);
    }
  }
  if (inQuotes) throw const FormatException('A quoted field is not closed');
  if (field.isNotEmpty || row.isNotEmpty) endRow();
  return rows;
}

enum ImportAction { add, update, unchanged }

class ImportRow {
  const ImportRow(this.line, this.name, this.action);

  final int line;
  final AdminName name;
  final ImportAction action;
}

class ImportPreview {
  const ImportPreview({
    required this.rows,
    required this.errors,
    required this.warnings,
  });

  final List<ImportRow> rows;
  final List<String> errors;
  final List<String> warnings;

  int count(ImportAction a) => rows.where((r) => r.action == a).length;

  /// Rows that would be written (new + changed).
  List<AdminName> get toWrite => [
    for (final ImportRow r in rows)
      if (r.action != ImportAction.unchanged) r.name,
  ];
}

/// Same columns as data/names.csv (snake_case header row). List columns use
/// `|` between values (e.g. `amharic|tigrinya`). Required: name_latin,
/// name_geez, gender. `id` defaults to the slug of name_latin. Server-owned
/// columns (rarity, trend_score, updated_at) are ignored.
///
/// [existing] decides add vs update vs unchanged. With [allowUpdates] off,
/// rows whose id already exists are skipped (with a warning), so an AI batch
/// can never overwrite curated names.
ImportPreview previewImport(
  String input, {
  required Map<String, AdminName> existing,
  bool allowUpdates = true,
}) {
  final List<String> errors = [];
  final List<String> warnings = [];
  final List<List<String>> table;
  try {
    table = parseDelimited(input);
  } on FormatException catch (e) {
    return ImportPreview(
      rows: const [],
      errors: [e.message],
      warnings: const [],
    );
  }
  if (table.length < 2) {
    return const ImportPreview(
      rows: [],
      errors: ['Paste a header row plus at least one name.'],
      warnings: [],
    );
  }

  const Set<String> known = {
    'id', 'name_latin', 'name_geez', 'spellings', 'gender', 'languages', //
    'faiths', 'meaning_en', 'meaning_am', 'themes', 'pronunciation',
    'audio_url', 'syllables', 'easy_abroad', 'origin_en', 'origin_am',
    'nicknames', 'similar', 'famous', 'verified', 'popularity', 'modern',
  };
  const Set<String> ignored = {'rarity', 'trend_score', 'updated_at'};
  final List<String> header = [
    for (final String h in table.first) h.trim().toLowerCase(),
  ];
  for (final String req in ['name_latin', 'name_geez', 'gender']) {
    if (!header.contains(req)) errors.add('Missing column "$req"');
  }
  for (final String h in header) {
    if (h.isNotEmpty && !known.contains(h) && !ignored.contains(h)) {
      warnings.add('Unknown column "$h" is ignored');
    }
  }
  if (errors.isNotEmpty) {
    return ImportPreview(rows: const [], errors: errors, warnings: warnings);
  }

  final List<ImportRow> rows = [];
  final Set<String> seen = {};
  // Same Ge'ez spelling under another id = probably the same name spelled
  // differently in Latin (Hiwot / Hiwet).
  final Map<String, String> idByGeez = {
    for (final AdminName n in existing.values)
      if (!n.deleted) _geezKey(n.nameGeez): n.id,
  };
  final RegExp geezLetters = RegExp(r'[ሀ-፿]');

  for (int r = 1; r < table.length; r++) {
    final int line = r + 1;
    final Map<String, String> cell = {
      for (int c = 0; c < header.length; c++)
        header[c]: c < table[r].length ? table[r][c].trim() : '',
    };
    String text(String k) => cell[k] ?? '';
    List<String> list(String k) => [
      for (final String v in text(k).split('|'))
        if (v.trim().isNotEmpty) v.trim(),
    ];
    List<String> codes(String k, List<String> allowed) {
      final List<String> out = [];
      for (final String v in list(k)) {
        final String code = v.toLowerCase();
        if (allowed.contains(code)) {
          out.add(code);
        } else {
          errors.add(
            'Line $line: unknown $k "$v" (allowed: ${allowed.join(', ')})',
          );
        }
      }
      return out;
    }

    final int errorsBefore = errors.length;
    final String latin = text('name_latin');
    final String geez = text('name_geez');
    final String id = text('id').isNotEmpty ? text('id') : slugify(latin);

    if (latin.isEmpty) errors.add('Line $line: name_latin is empty');
    if (geez.isEmpty) {
      errors.add('Line $line: name_geez is empty');
    } else if (!geezLetters.hasMatch(geez)) {
      errors.add('Line $line: name_geez "$geez" has no Ge\'ez letters');
    }
    if (!RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$').hasMatch(id)) {
      errors.add(
        'Line $line: id "$id" must be lowercase letters/digits/dashes',
      );
    } else if (!seen.add(id)) {
      errors.add('Line $line: duplicate id "$id" in the paste');
    }
    final String gender = switch (text('gender').toLowerCase()) {
      'girl' || 'female' || 'f' => 'girl',
      'boy' || 'male' || 'm' => 'boy',
      'unisex' || 'u' => 'unisex',
      _ => '',
    };
    if (gender.isEmpty) {
      errors.add(
        'Line $line: gender "${text('gender')}" must be girl/boy/unisex',
      );
    }

    int number(String k, int max) {
      final String v = text(k);
      if (v.isEmpty) return 0;
      final int? n = int.tryParse(v);
      if (n == null || n < 0 || n > max) {
        errors.add('Line $line: $k "$v" must be a number 0–$max');
        return 0;
      }
      return n;
    }

    bool flag(String k) {
      final String v = text(k).toLowerCase();
      if (const ['', 'false', 'no', 'n', '0'].contains(v)) return false;
      if (const ['true', 'yes', 'y', '1'].contains(v)) return true;
      errors.add('Line $line: $k "$v" must be true/false');
      return false;
    }

    final String audio = text('audio_url');
    if (audio.isNotEmpty &&
        !(Uri.tryParse(audio)?.isScheme('https') ?? false)) {
      errors.add('Line $line: audio_url must start with https://');
    }

    final List<String> languages = codes('languages', Vocab.languages);
    final List<String> faiths = codes('faiths', Vocab.faiths);
    final List<String> themes = codes('themes', Vocab.themes);
    final AdminName name = AdminName(
      id: id,
      nameLatin: latin,
      nameGeez: geez,
      gender: gender,
      spellings: {if (latin.isNotEmpty) latin, ...list('spellings')}.toList(),
      languages: languages.isEmpty ? const ['amharic'] : languages,
      faiths: faiths.isEmpty ? const ['neutral'] : faiths,
      themes: themes,
      meaningEn: text('meaning_en'),
      meaningAm: text('meaning_am'),
      pronunciation: text('pronunciation'),
      audioUrl: audio.isEmpty ? null : audio,
      syllables: number('syllables', 12),
      easyAbroad: flag('easy_abroad'),
      originEn: text('origin_en'),
      originAm: text('origin_am'),
      nicknames: list('nicknames'),
      similar: [for (final String s in list('similar')) s.toLowerCase()],
      famous: list('famous'),
      verified: flag('verified'),
      popularity: number('popularity', 100),
      modern: flag('modern'),
    );
    if (errors.length > errorsBefore) continue;

    if (languages.isEmpty) warnings.add('$id: no languages, using amharic');
    if (name.meaningEn.isEmpty) warnings.add('$id: meaning_en is empty');

    final AdminName? old = existing[id];
    final ImportAction action;
    if (old == null || old.deleted) {
      action = old == null ? ImportAction.add : ImportAction.update;
    } else if (!allowUpdates) {
      warnings.add('Line $line: "$id" already exists — skipped');
      continue;
    } else {
      action = _same(old, name) ? ImportAction.unchanged : ImportAction.update;
    }
    final String? twin = idByGeez[_geezKey(geez)];
    if (twin != null && twin != id) {
      warnings.add(
        'Line $line: "$id" has the same Ge\'ez ($geez) as "$twin" '
        '— possible duplicate',
      );
    }
    idByGeez[_geezKey(geez)] = id;
    rows.add(ImportRow(line, name, action));
  }

  for (final ImportRow r in rows) {
    for (final String s in r.name.similar) {
      if (!existing.containsKey(s) && !seen.contains(s)) {
        warnings.add('${r.name.id}: similar "$s" is not a known name id');
      }
    }
  }
  return ImportPreview(rows: rows, errors: errors, warnings: warnings);
}

String _geezKey(String g) => g.replaceAll(RegExp(r'\s'), '');

bool _same(AdminName a, AdminName b) =>
    jsonEncode(a.toEditableMap()) == jsonEncode(b.toEditableMap());

/// Header row for a blank template (same order as data/names.csv).
const String importTemplateHeader =
    'id\tname_latin\tname_geez\tspellings\tgender\tlanguages\tfaiths\t'
    'meaning_en\tmeaning_am\tthemes\tpronunciation\taudio_url\tsyllables\t'
    'easy_abroad\torigin_en\torigin_am\tnicknames\tsimilar\tfamous\t'
    'verified\tpopularity\tmodern';

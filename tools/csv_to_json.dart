// Converts the names spreadsheet (CSV) into the app's bundled names.json.
//
//   dart run tools/csv_to_json.dart [input.csv] [output.json] [--version=N]
//
// Defaults: data/names.csv → assets/data/names.json.
// Columns use the snake_case names in NameFields (see data/names.csv).
// List columns separate values with "|", e.g.  Hiwot|Heywet|Hiywet
//
// Rows whose content is unchanged keep their previous updated_at, so only
// edited names are picked up by the next Firestore import / app sync.
// The file version is bumped automatically when anything changed.

import 'dart:convert';
import 'dart:io';

import 'package:habesha_names/app/data/models/name_model.dart';

import 'src/name_csv.dart';

void main(List<String> args) {
  final List<String> positional = [
    for (final String a in args)
      if (!a.startsWith('--')) a,
  ];
  final int? versionOverride = _intFlag(args, 'version');
  final File input = File(
    positional.isNotEmpty ? positional[0] : 'data/names.csv',
  );
  final File output = File(
    positional.length > 1 ? positional[1] : 'assets/data/names.json',
  );

  if (!input.existsSync()) {
    stderr.writeln('Input not found: ${input.path}');
    exit(2);
  }

  final (int previousVersion, Map<String, NameModel> previous) = _readPrevious(
    output,
  );

  final CsvConversion result;
  try {
    result = convertRows(
      parseCsv(input.readAsStringSync()),
      now: DateTime.now().toUtc().copyWith(millisecond: 0, microsecond: 0),
      previous: previous,
    );
  } on FormatException catch (e) {
    stderr.writeln('Invalid CSV: ${e.message}');
    exit(1);
  }

  for (final String w in result.warnings) {
    stdout.writeln('warning: $w');
  }
  if (!result.ok) {
    for (final String e in result.errors) {
      stderr.writeln('error: $e');
    }
    stderr.writeln('${result.errors.length} error(s) — nothing written.');
    exit(1);
  }

  final bool changed = _hasChanges(previous, result.names);
  final int version =
      versionOverride ??
      (changed || previousVersion == 0 ? previousVersion + 1 : previousVersion);

  if (!changed && versionOverride == null && output.existsSync()) {
    stdout.writeln('No changes — ${output.path} is up to date (v$version).');
    return;
  }

  output.parent.createSync(recursive: true);
  output.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert({
      'version': version,
      'count': result.names.length,
      'names': [for (final NameModel n in result.names) n.toJson()],
    })}\n',
  );
  stdout.writeln(
    'Wrote ${result.names.length} names to ${output.path} (v$version).',
  );
}

(int, Map<String, NameModel>) _readPrevious(File file) {
  if (!file.existsSync()) return (0, const {});
  try {
    final Map<String, dynamic> json =
        jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final Map<String, NameModel> byId = {
      for (final Object? e in json['names'] as List<Object?>)
        if (NameModel.fromJson(e! as Map<String, dynamic>) case final n)
          n.id: n,
    };
    return ((json['version'] as num?)?.toInt() ?? 0, byId);
  } on Object catch (e) {
    stdout.writeln('warning: could not read previous ${file.path} ($e)');
    return (0, const {});
  }
}

bool _hasChanges(Map<String, NameModel> before, List<NameModel> after) {
  if (before.length != after.length) return true;
  for (final NameModel n in after) {
    final NameModel? old = before[n.id];
    if (old == null || jsonEncode(old.toJson()) != jsonEncode(n.toJson())) {
      return true;
    }
  }
  return false;
}

int? _intFlag(List<String> args, String name) {
  for (final String a in args) {
    if (a.startsWith('--$name=')) return int.tryParse(a.split('=').last);
  }
  return null;
}

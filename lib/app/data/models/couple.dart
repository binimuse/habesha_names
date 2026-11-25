import 'dart:math';

/// A partner link at `couples/{code}`.
class Couple {
  const Couple({required this.code, required this.members});

  factory Couple.fromJson(String code, Map<String, dynamic> json) => Couple(
    code: code,
    members: [
      for (final Object? m in json['members'] as List<Object?>? ?? const [])
        if (m is String) m,
    ],
  );

  final String code;
  final List<String> members;

  bool get isComplete => members.length >= 2;
}

/// A name both partners liked, at `couples/{code}/matches/{nameId}`.
class NameMatch {
  const NameMatch({
    required this.nameId,
    required this.createdAt,
    this.superLike = false,
  });

  final String nameId;
  final bool superLike;
  final DateTime createdAt;
}

enum PartnerError { unavailable, invalidCode, notFound, full, unknown }

class PartnerException implements Exception {
  const PartnerException(this.error);

  final PartnerError error;

  @override
  String toString() => 'PartnerException(${error.name})';
}

abstract final class CoupleCode {
  static const int length = 6;
  static final RegExp _pattern = RegExp(r'^\d{6}$');

  /// 100000–999999 (no leading zero, so it reads well aloud).
  static String generate([Random? random]) =>
      (100000 + (random ?? Random.secure()).nextInt(900000)).toString();

  /// Strips spaces/dashes people type ("123 456", "123-456").
  static String normalize(String input) =>
      input.replaceAll(RegExp(r'[\s\-]'), '');

  static bool isValid(String code) => _pattern.hasMatch(code);
}

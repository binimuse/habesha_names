import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

import 'callable_transport.dart';
import 'callable_transport_stub.dart'
    if (dart.library.js_interop) 'callable_transport_web.dart';

/// Calls an HTTPS callable Cloud Function directly (browser `fetch`), using
/// the callable protocol: POST `{"data": …}` with the user's ID token →
/// `{"result": …}` or `{"error": {status, message}}`.
///
/// Used instead of the cloud_functions plugin, whose web release build
/// failed with "Int64 accessor not supported by dart2js".
class CallableException implements Exception {
  const CallableException(this.code, this.message);

  /// e.g. PERMISSION_DENIED, NOT_FOUND, INVALID_ARGUMENT, HTTP_500.
  final String code;
  final String message;

  @override
  String toString() => '$code: $message';
}

abstract final class Callable {
  static const String _base =
      'https://europe-west1-habesha-baby-names.cloudfunctions.net';

  static Future<Object?> call(String name, [Map<String, Object?>? data]) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw const CallableException('UNAUTHENTICATED', 'Not signed in.');
    }
    final String token = await user.getIdToken() ?? '';
    final CallableHttpResponse res = await postJson(
      '$_base/$name',
      token,
      jsonEncode({'data': data}),
    );
    return parseCallableResponse(name, res);
  }
}

/// Pure: turns the HTTP response into the result or a [CallableException].
Object? parseCallableResponse(String name, CallableHttpResponse res) {
  Object? body;
  try {
    body = jsonDecode(res.body);
  } on FormatException {
    body = null;
  }
  if (body is Map && body['error'] is Map) {
    final Map<dynamic, dynamic> e = body['error'] as Map<dynamic, dynamic>;
    throw CallableException(
      '${e['status'] ?? 'INTERNAL'}',
      '${e['message'] ?? 'Unknown error'}',
    );
  }
  if (res.status == 404) {
    throw CallableException(
      'NOT_FOUND',
      'The $name function is not deployed. Run: firebase deploy --only functions',
    );
  }
  if (res.status != 200 || body is! Map || !body.containsKey('result')) {
    throw CallableException('HTTP_${res.status}', res.body);
  }
  return body['result'];
}

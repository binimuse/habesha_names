import 'dart:js_interop';

import 'callable_transport.dart';

/// Browser `fetch` POST with a Firebase ID token.
Future<CallableHttpResponse> postJson(
  String url,
  String token,
  String body,
) async {
  final _FetchResponse res = await _fetch(
    url.toJS,
    <String, Object?>{
          'method': 'POST',
          'headers': <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          'body': body,
        }.jsify()!
        as JSObject,
  ).toDart;
  return (status: res.status, body: (await res.text().toDart).toDart);
}

@JS('fetch')
external JSPromise<_FetchResponse> _fetch(JSString url, JSObject init);

extension type _FetchResponse(JSObject _) implements JSObject {
  external int get status;
  external JSPromise<JSString> text();
}

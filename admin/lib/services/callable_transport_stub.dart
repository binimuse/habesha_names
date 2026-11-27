import 'callable_transport.dart';

/// Non-web builds (unit tests on the VM): there is no browser fetch.
Future<CallableHttpResponse> postJson(String url, String token, String body) =>
    throw UnsupportedError('Callable functions need the web build.');

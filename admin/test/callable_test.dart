import 'package:flutter_test/flutter_test.dart';
import 'package:habesha_names_admin/services/callable.dart';

void main() {
  test('callable responses: result, function error, not deployed', () {
    expect(
      parseCallableResponse('f', (status: 200, body: '{"result":{"n":3}}')),
      {'n': 3},
    );
    expect(
      () => parseCallableResponse('f', (
        status: 403,
        body:
            '{"error":{"message":"Admins only.","status":"PERMISSION_DENIED"}}',
      )),
      throwsA(
        isA<CallableException>()
            .having((e) => e.code, 'code', 'PERMISSION_DENIED')
            .having((e) => e.message, 'message', 'Admins only.'),
      ),
    );
    expect(
      () => parseCallableResponse('adminListUsers', (
        status: 404,
        body: '<html>',
      )),
      throwsA(
        isA<CallableException>().having(
          (e) => e.message,
          'message',
          contains('not deployed'),
        ),
      ),
    );
  });
}

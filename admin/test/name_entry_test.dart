import 'package:flutter_test/flutter_test.dart';
import 'package:habesha_names_admin/data/admin_name.dart';

AdminName n(String id, {bool deleted = false, String meaning = ''}) =>
    AdminName(
      id: id,
      nameLatin: id[0].toUpperCase() + id.substring(1),
      nameGeez: 'ስ',
      gender: 'girl',
      deleted: deleted,
      meaningEn: meaning,
    );

void main() {
  test('merge gives each name one entry with the right status', () {
    final List<NameEntry> e = NameEntry.merge(
      [n('hiwot'), n('abebe', deleted: true), n('selam', meaning: 'old')],
      [n('selam', meaning: 'new'), n('tsion')],
    );
    final Map<String, NameEntry> by = {for (final x in e) x.id: x};
    expect(e.map((x) => x.id), ['abebe', 'hiwot', 'selam', 'tsion']); // sorted
    expect(by['hiwot']!.status, NameStatus.published);
    expect(by['abebe']!.status, NameStatus.deleted);
    expect(by['selam']!.status, NameStatus.changed);
    expect(by['selam']!.current.meaningEn, 'new'); // editor shows the draft
    expect(by['selam']!.published!.meaningEn, 'old'); // app still shows live
    expect(by['tsion']!.status, NameStatus.draft);
  });
}

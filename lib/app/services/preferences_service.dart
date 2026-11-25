import 'package:get/get.dart';

import '../data/models/user_prefs.dart';
import 'storage_service.dart';

/// Onboarding answers, persisted on the device.
class PreferencesService extends GetxService {
  PreferencesService(this._storage);

  static const String _kDone = 'prefs.onboarding_done';
  static const String _kExpecting = 'prefs.expecting';
  static const String _kFaiths = 'prefs.faiths';
  static const String _kLanguages = 'prefs.languages';

  final StorageService _storage;

  final RxBool onboardingDone = false.obs;
  final Rx<UserPrefs> prefs = const UserPrefs().obs;

  @override
  void onInit() {
    super.onInit();
    onboardingDone.value = _storage.read<bool>(_kDone) ?? false;
    prefs.value = UserPrefs(
      expecting: Expecting.values.firstWhere(
        (e) => e.name == _storage.read<String>(_kExpecting),
        orElse: () => Expecting.unknown,
      ),
      faiths: _readSet(_kFaiths),
      languages: _readSet(_kLanguages),
    );
  }

  Future<void> save(UserPrefs value) async {
    prefs.value = value;
    await Future.wait([
      _storage.write(_kExpecting, value.expecting.name),
      _storage.write(_kFaiths, value.faiths.toList()),
      _storage.write(_kLanguages, value.languages.toList()),
    ]);
  }

  Future<void> completeOnboarding(UserPrefs value) async {
    await save(value);
    onboardingDone.value = true;
    await _storage.write(_kDone, true);
  }

  Set<String> _readSet(String key) => {
    for (final Object? v in _storage.read<List<dynamic>>(key) ?? const [])
      if (v is String) v,
  };
}

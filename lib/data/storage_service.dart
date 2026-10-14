import 'package:universal_ble_example/data/prefs_async.dart';

class StorageService {
  StorageService._();
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  Future<void> init() async {
    // SharedPreferencesAsync is used via prefsAsync; no async init needed.
  }

  Future<void> setFavoriteServices(List<String> services) async {
    await prefsAsync.setStringList('favorite_services', services);
  }

  Future<List<String>> getFavoriteServices() async =>
      (await prefsAsync.getStringList('favorite_services')) ?? [];

  Future<void> setIncludeRssiInAdvertisementCopy(bool value) async {
    await prefsAsync.setBool('include_rssi_in_advertisement_copy', value);
  }

  Future<bool> getIncludeRssiInAdvertisementCopy() async =>
      (await prefsAsync.getBool('include_rssi_in_advertisement_copy')) ?? false;
}

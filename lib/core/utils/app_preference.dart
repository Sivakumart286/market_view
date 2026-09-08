import 'package:get_storage/get_storage.dart';

class AppPreference {
  static final AppPreference _instance = AppPreference._internal();
  factory AppPreference() => _instance;
  AppPreference._internal();

  static const String boxName = "handySharedPref";
  static const String _isAlreadyLoginKey = "isAlreadyLogin";
  static const String _authTokenKey = "authToken";

  var storage = GetStorage(boxName);

  static Future<void> init() async {
    await GetStorage.init(boxName);
  }

  bool? get isAlreadyLogin => storage.read(_isAlreadyLoginKey) ?? false;

  set isAlreadyLogin(bool? isAlreadyLogin) {
    storage.write(_isAlreadyLoginKey, isAlreadyLogin);
  }

  String? get authToken => storage.read(_authTokenKey) ?? "";

  set authToken(String? authToken) {
    storage.write(_authTokenKey, authToken);
  }

  String get selectedLanguage => storage.read<String>('selectedLanguage') ?? 'en';

  Future<void> setSelectedLanguage(String language) =>
      storage.write('selectedLanguage', language);

  Future<void> clearUserData() async {
    await storage.remove('isAlreadyLogin');
    await storage.remove('authToken');
    await storage.remove('selectedLanguage');
  }
}
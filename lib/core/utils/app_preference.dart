import 'package:get_storage/get_storage.dart';

class AppPreference {

  var storage = GetStorage("handySharedPref");

 bool? get isAlreadyLogin => storage.read("isAlreadyLogin")?? false;

 set isAlreadyLogin(bool? isAlreadyLogin){
   storage.write("isAlreadyLogin", isAlreadyLogin);
 }

 String? get authToken => storage.read("authToken") ?? "";

 set authToken(String? authToken) {
   storage.write("authToken", authToken);
 }

}
import 'package:shared_preferences/shared_preferences.dart';

class SavedData {
  static SharedPreferences? preferences;

  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
  }

  // Save user id on device

  static Future<void> saveUserId(String id) async {
    await preferences!.setString("userId", id);
  }

  // Get the user Id

  static String getUserId() {
    if (preferences == null) return "";
    return preferences!.getString("userId") ?? "";
  }

// Save user name
  static Future<void> saveUserName(String name) async {
    if (preferences == null) await init();
    await preferences!.setString("username", name);
  }
  // Get the user name

  static String getUserName() {
    if (preferences == null) return "";
    return preferences!.getString("username") ?? "";
  }

// Save user email
  static Future<void> saveUserEmail(String email) async {
    if (preferences == null) await init();
    await preferences!.setString("email", email);
  }
  // Get the user email

  static String getUserEmail() {
    if (preferences == null) return "";
    return preferences!.getString("email") ?? "";
  }

static bool isLoggedIn() {
  return getUserId().isNotEmpty;
}

}
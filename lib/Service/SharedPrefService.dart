import 'dart:convert';


import 'package:shared_preferences/shared_preferences.dart';

import '../models/User.dart';



class SharedPrefService {
// Example to store data
  Future<void> saveStringToPrefs(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

// Example to read data
  Future<String> readStringFromPrefs(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key) ?? '';
    return value;
  }

// clear field
  Future<void> clearStringFromPrefs(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

// clear all
  Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('All data removed');
  }

// check values of all keys
  Future<void> checkAllValues() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (String key in keys) {
      final value = prefs.get(key).toString() ?? '';
      print('Read $key: $value');
    }
  }


  Future<User> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = await prefs.getString('user');
    print("getUser:---------$userJson");
    if (userJson == null) {
      return User(
          email: '',
          password: '', id: '', name: '', passwordConfirmation: '', image: '',
          );
    }
    Map<String, dynamic> userMap = jsonDecode(userJson!);
    return User.fromJson(userMap);
  }
//////////////  check for user on app launch
  Future<void> saveUserData(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_token', token);
  }
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('user_token');
  }
/////////////
  Future<void> saveProfileDetails(User profileDetails) async {
    final prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(profileDetails.toJson());
    await prefs.setString('profileDetails', userJson);
  }

  Future<User> getProfileDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('profileDetails');
    print("------------user json: $userJson");
    Map<String, dynamic> userMap = jsonDecode(userJson!);
    print("profile details ash: $userMap");
    return User.fromJson(userMap);
  }

  Future<bool> removeFromPrefs(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(key);
    } catch (e) {
      print('Error removing key:  $key: $e');
      return false;
    }
  }

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    print("----------------------user saved to prefs: ${user.toJson()}");
    await prefs.setString('user', json.encode(user.toJson()));
  }

  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userJsonString = prefs.getString('user');

      if (userJsonString != null && userJsonString.isNotEmpty) {
        final Map<String, dynamic> userMap = json.decode(userJsonString);
        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print("Error reading user data: $e");
      return null;
    }
  }

}
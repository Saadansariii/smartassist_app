import 'package:hive/hive.dart';

class Storage {
  // Open a box to store the token
  static Future<Box> _openBox() async {
    return await Hive.openBox('tokenBox');
  }

  // Method to get the stored token
  static Future<String?> getToken() async {
    final box = await _openBox();
    return box.get('auth_token'); // Retrieve the stored token
  }

  // Method to save the token
  static Future<void> saveToken(String token) async {
    final box = await _openBox();
    await box.put('auth_token', token); // Store the token
  }

  // Method to remove the token
  static Future<void> removeToken() async {
    final box = await _openBox();
    await box.delete('auth_token'); // Delete the token
  }
}

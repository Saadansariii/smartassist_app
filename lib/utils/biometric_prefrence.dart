// biometric_preference.dart
// This class handles saving and retrieving biometric preferences
import 'package:shared_preferences/shared_preferences.dart';

class BiometricPreference {
  static const String _useBiometricKey = 'use_biometric';
  static const String _hasPromptedBiometricKey = 'has_prompted_biometric';

  // Get whether biometric is enabled
  static Future<bool> getUseBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_useBiometricKey) ?? false;
  }

  // Set whether biometric is enabled
  static Future<void> setUseBiometric(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useBiometricKey, value);
  }

  // Check if the user has been prompted about biometrics before
  static Future<bool> getHasPromptedBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasPromptedBiometricKey) ?? false;
  }

  // Set that the user has been prompted about biometrics
  static Future<void> setHasPromptedBiometric(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasPromptedBiometricKey, value);
  }

  // For debugging purposes
  static Future<void> printAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    print("All SharedPreferences keys: $keys");
    
    bool? useBiometric = prefs.getBool(_useBiometricKey);
    bool? hasPrompted = prefs.getBool(_hasPromptedBiometricKey);
    print("Current use_biometric value: $useBiometric");
    print("Current has_prompted_biometric value: $hasPrompted");
  }
}
// biometric_preference.dart
// This class handles saving and retrieving biometric preferences
import 'package:shared_preferences/shared_preferences.dart';

class BiometricPreference {
  static const String _useBiometricKey = 'use_biometric';
  static const String _hasPromptedBiometricKey = 'has_prompted_biometric';
  static const String _hasMadeBiometricChoiceKey = 'has_made_biometric_choice';

  // Get whether biometric is enabled
  static Future<bool> getUseBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_useBiometricKey) ?? false;
  }

  // Set whether biometric is enabled
  static Future<void> setUseBiometric(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useBiometricKey, value);
    // When setting biometric preference, also mark that user has made a choice
    await prefs.setBool(_hasMadeBiometricChoiceKey, true);
    
    // Log for debugging
    print("Setting _useBiometricKey = $value");
    print("Setting _hasMadeBiometricChoiceKey = true");
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

  // Check if the user has made a choice about biometrics (yes or no)
  static Future<bool> getHasMadeBiometricChoice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasMadeBiometricChoiceKey) ?? false;
  }

  // Directly set whether the user has made a choice
  static Future<void> setHasMadeBiometricChoice(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasMadeBiometricChoiceKey, value);
  }

  // Reset all biometric preferences (typically on logout)
  static Future<void> resetBiometricPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_useBiometricKey);
    await prefs.remove(_hasPromptedBiometricKey);
    await prefs.remove(_hasMadeBiometricChoiceKey);
    
    print("All biometric preferences have been reset");
  }

  // For debugging purposes
  static Future<void> printAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    print("All SharedPreferences keys: $keys");
    
    bool? useBiometric = prefs.getBool(_useBiometricKey);
    bool? hasPrompted = prefs.getBool(_hasPromptedBiometricKey);
    bool? hasMadeChoice = prefs.getBool(_hasMadeBiometricChoiceKey);
    print("Current use_biometric value: $useBiometric");
    print("Current has_prompted_biometric value: $hasPrompted");
    print("Current has_made_biometric_choice value: $hasMadeChoice");
  }
}
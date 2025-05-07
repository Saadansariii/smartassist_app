import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// TokenManager.dart - Fixed class to handle authentication
class TokenManager {
  static const String TOKEN_KEY = 'auth_token';
  static const String USER_ID_KEY = 'user_id';
  static const String USER_ROLE =
      'user_role'; // Fixed key name to be consistent

  // Add this debugging method to check what's stored
  static Future<void> debugStoredValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(TOKEN_KEY);
    String? userId = prefs.getString(USER_ID_KEY);
    String? role = prefs.getString(USER_ROLE);

    print("DEBUG - Stored Values:");
    print("Token exists: ${token != null}");
    print("User ID: $userId");
    print("User Role: $role");

    // Also check all keys in preferences to find mismatches
    print("All keys in SharedPreferences:");
    prefs.getKeys().forEach((key) {
      print("$key: ${prefs.get(key)}");
    });
  }

  // Check token validity without clearing or redirecting
  static Future<bool> isTokenValid() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(TOKEN_KEY);

      if (token == null) return false;

      bool isExpired = JwtDecoder.isExpired(token);
      return !isExpired;
    } catch (e) {
      print('Error checking token validity: $e');
      return false;
    }
  }

  // Save token and user data
  static Future<void> saveAuthData(
    String token,
    String userId,
    String userRole,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(TOKEN_KEY, token);
    await prefs.setString(USER_ID_KEY, userId);
    await prefs.setString(USER_ROLE, userRole); // Fixed key usage

    // Verify it was saved
    print("Saved role: ${prefs.getString(USER_ROLE)}");
  }

  static Future<void> clearAuthData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(TOKEN_KEY);
    await prefs.remove(USER_ID_KEY);
    await prefs.remove(USER_ROLE);
  }

  // Get stored token
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(TOKEN_KEY);
  }

  // Get user ID
  static Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(USER_ID_KEY);
  }

  // Get user role
  static Future<String?> getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(USER_ROLE);
  }
}

// class TokenManager {
//   static const String TOKEN_KEY = 'auth_token';
//   static const String USER_ID_KEY = 'user_id';
//   static const String USER_ROLE = 'team_role'; // Consistent naming

//   // Check token validity without clearing or redirecting
//   static Future<bool> isTokenValid() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString(TOKEN_KEY);

//       if (token == null) return false;

//       bool isExpired = JwtDecoder.isExpired(token);
//       return !isExpired;
//     } catch (e) {
//       print('Error checking token validity: $e');
//       return false;
//     }
//   }

//   // Save token and user data
//   static Future<void> saveAuthData(
//       String token, String userId, String teamRole) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString(TOKEN_KEY, token);
//     await prefs.setString(USER_ID_KEY, userId);
//     await prefs.setString('USER_ROLE', teamRole);

//     // Verify it was saved
//     print("Saved role: ${prefs.getString(USER_ROLE)}");
//   }

//   // Add this to your TokenManager class
//   static Future<void> clearAuthData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove(TOKEN_KEY);
//     await prefs.remove(USER_ID_KEY);
//     await prefs.remove(USER_ROLE);
//   }

//   // Get stored token
//   static Future<String?> getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(TOKEN_KEY);
//   }

//   // Get user ID
//   static Future<String?> getUserId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(USER_ID_KEY);
//   }

//   // Get team role
//   static Future<String?> getTeamRole() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(USER_ROLE);
//   }
// }

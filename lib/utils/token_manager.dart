// tems will working fine heree
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';

// class TokenManager {
//   static const String TOKEN_KEY = 'auth_token';
//   static const String USER_ID_KEY = 'user_id';
//   static const String USER_ROLE = 'team_role';

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
//       String token, String userId,String teamRole) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString(TOKEN_KEY, token);
//     await prefs.setString(USER_ID_KEY, userId);
//     await prefs.setString('USER_ROLE', teamRole);

//     // Verify it was saved
//     print("Saved role: ${prefs.getString('USER_ROLE')}");
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

//   // Refresh token method - implement your token refresh logic here
//   // static Future<bool> refreshToken() async {
//   //   try {
//   //     String? currentToken = await getToken();
//   //     if (currentToken == null) return false;

//   //     // Add your token refresh API call here
//   //     // Example:
//   //     // final response = await YourApiService.refreshToken(currentToken);
//   //     // if (response.success) {
//   //     //   await saveAuthData(response.newToken, response.userId);
//   //     //   return true;
//   //     // }

//   //     return false;
//   //   } catch (e) {
//   //     print('Error refreshing token: $e');
//   //     return false;
//   //   }
//   // }
// }

import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenManager {
  static const String TOKEN_KEY = 'auth_token';
  static const String USER_ID_KEY = 'user_id';
  static const String USER_ROLE = 'team_role'; // Consistent naming

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
      String token, String userId, String teamRole) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(TOKEN_KEY, token);
    await prefs.setString(USER_ID_KEY, userId);
    await prefs.setString('USER_ROLE', teamRole); // Using constant here

    // Verify it was saved
    print("Saved role: ${prefs.getString(USER_ROLE)}");
  }

  // Add this to your TokenManager class
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

  // Get team role
  static Future<String?> getTeamRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(USER_ROLE);
  }
}

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:smart_assist/utils/storage.dart';

// class LoginSrv {
//   static Future<Map<String, dynamic>> onLogin(Map body) async {
//     const url = 'https://api.smartassistapp.in/api/login';
//     final uri = Uri.parse(url);

//     try {
//       final response = await http.post(
//         uri,
//         body: jsonEncode(body),
//         headers: {'Content-Type': 'application/json'},
//       );

//       print('API Status Code: ${response.statusCode}');
//       print('API Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);

//         if (responseData['status'] == 200 && responseData.containsKey('data')) {
//           final data = responseData['data'];
//           final String token = data['token'];
//           final Map<String, dynamic>? user =
//               data.containsKey('user') ? data['user'] : null;

//           await Storage.saveToken(token);

//           if (user != null) {
//             return {'isSuccess': true, 'token': token, 'user': user};
//           } else {
//             return {
//               'isSuccess': false,
//               'message': 'User data missing in response'
//             };
//           }
//         } else {
//           return {
//             'isSuccess': false,
//             'message': responseData['message'] ?? 'Unknown error'
//           };
//         }
//       } else {
//         final errorData = jsonDecode(response.body);
//         return {
//           'isSuccess': false,
//           'message': errorData['message'] ?? 'Login failed'
//         };
//       }
//     } catch (error) {
//       print('Error: $error');
//       return {'isSuccess': false, 'error': error.toString()};
//     }
//   }
// }

// class LoginSrv {
  // static Future<Map<String, dynamic>> onLogin(Map body) async {
  //   const url = 'https://api.smartassistapp.in/api/login';
  //   final uri = Uri.parse(url);

  //   try {
  //     final response = await http.post(
  //       uri,
  //       body: jsonEncode(body),
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     print('API Status Code: ${response.statusCode}');
  //     print('API Response Body: ${response.body}');

  //     final responseData = jsonDecode(response.body);

  //     // Check for success in both HTTP status and response body
  //     if (response.statusCode == 200 &&
  //         responseData['status'] == 200 &&
  //         responseData.containsKey('data')) {
  //       final data = responseData['data'];
  //       final String token = data['token'];
  //       final Map<String, dynamic>? user = data['user'];

  //       // Save token for subsequent calls.
  //       await Storage.saveToken(token);

  //       if (user != null) {
  //         return {'isSuccess': true, 'token': token, 'user': user};
  //       } else {
  //         return {
  //           'isSuccess': false,
  //           'message': 'User data missing in response'
  //         };
  //       }
  //     } else {
  //       // Return the backend error message if available.
  //       return {
  //         'isSuccess': false,
  //         'message': responseData['message'] ?? 'Login failed'
  //       };
  //     }
  //   } catch (error) {
  //     print('Error: $error');
  //     return {'isSuccess': false, 'error': error.toString()};
  //   }
  // }
// }


















//  class LoginSrv {
//   static Future<Map<String, dynamic>> onLogin(Map body) async {
//     const url = 'https://api.smartassistapp.in/api/login';
//     final uri = Uri.parse(url);

//     try {
//       // Send POST request to the login endpoint
//       final response = await http.post(
//         uri,
//         body: jsonEncode(body),
//         headers: {'Content-Type': 'application/json'},
//       );

//       // Log the response for debugging
//       print('API Status Code: ${response.statusCode}');
//       print('API Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         return {'isSuccess': true, 'data': responseData};
//       } else {
//         final errorData = jsonDecode(response.body);
//         return {'isSuccess': false, 'data': errorData};
//       }
//     } catch (error) {
//       // Log the error and return a failure response
//       print('Error: $error');
//       return {'isSuccess': false, 'error': error.toString()};
//     }
//   }
// }
  

// class LoginSrv {
//   static Future<Map<String, dynamic>> onLogin(Map body) async {
//     const url = 'https://api.smartassistapp.in/api/login';
//     final uri = Uri.parse(url);

//     try {
//       final response = await http.post(
//         uri,
//         body: jsonEncode(body),
//         headers: {'Content-Type': 'application/json'},
//       );

//       print('API Status Code: ${response.statusCode}');
//       print('API Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);

//         // Ensure 'user' object is included in the returned data
//         final String token = responseData['token'];
//         final Map<String, dynamic>? user =
//             responseData.containsKey('user') ? responseData['user'] : null;

//         await Storage.saveToken(token);

//         if (user != null) {
//           return {
//             'isSuccess': true,
//             'token': token,
//             'user': user
//           };  
//         } else {
//           return {
//             'isSuccess': false,
//             'message': 'User data missing in response'
//           };
//         }
//       } else {
//         final errorData = jsonDecode(response.body);
//         return {'isSuccess': false, 'data': errorData};
//       }
//     } catch (error) {
//       print('Error: $error');
//       return {'isSuccess': false, 'error': error.toString()};
//     }
//   }
// }

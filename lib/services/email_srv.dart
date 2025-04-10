import 'dart:convert';

import 'package:http/http.dart' as http;

// class EmailService {
//   static Future<bool> verifyEmail(Map body) async {
//     const url = 'https://api.smartassistapp.in/api/login/verify-email';
//     final uri = Uri.parse(url);
//     final response = await http.post(
//       uri,
//       body: jsonEncode(body),
//       headers: {'Content-Type': 'application/json'},
//     );
//     return response.statusCode == 200;
//   }
// }

 
// class EmailService {
  // static Future<Map<String, dynamic>> verifyEmail(Map body) async {
  //   const url = 'https://api.smartassistapp.in/api/login/verify-email';
  //   final uri = Uri.parse(url);

  //   try {
  //     final response = await http.post(
  //       uri,
  //       body: jsonEncode(body),
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     // Log the response for debugging
  //     print('API Status Code: ${response.statusCode}');
  //     print('API Response Body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       return {'isSuccess': true, 'data': jsonDecode(response.body)};
  //     } else {
  //       return {'isSuccess': false, 'data': jsonDecode(response.body)};
  //     }
  //   } catch (error) {
  //     // Log any error that occurs during the API call
  //     print('Error: $error');
  //     return {'isSuccess': false, 'error': error.toString()};
  //   }
  // }
// }

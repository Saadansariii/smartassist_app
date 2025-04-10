// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class OtpSrv {
  // static Future<Map<String, dynamic>> verifyEmail(Map body) async {
  //   const url = 'https://api.smartassistapp.in/api/login/verify-otp';
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
  //       final responseData = jsonDecode(response.body);
  //       return {'isSuccess': true, 'data': responseData};
  //     } else {
  //       final errorData = jsonDecode(response.body);
  //       return {'isSuccess': false, 'data': errorData};
  //     }
  //   } catch (error) {
  //     print('Error: $error'); // Log error
  //     return {'isSuccess': false, 'error': error.toString()};
  //   }
  // }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;

// class SetPwdSrv {
  // static Future<Map<String, dynamic>> SetPwd(Map body) async {
  //   const url = 'https://api.smartassistapp.in/api/login/create-pwd';
  //   final uri = Uri.parse(url);

  //   try {
  //     final response = await http.put(
  //       uri,
  //       body: jsonEncode(body),
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     // Log the response for debugging
  //     print('API Status Code: ${response.statusCode}');
  //     print('API Response Body: ${response.body}');

  //     if (response.statusCode == 201) {
  //       final responseData = jsonDecode(response.body);
  //       return {'isSuccess': true, 'data': responseData};
  //     } else {
  //       final errorData = jsonDecode(response.body);
  //       return {'isSuccess': false, 'data': errorData};
  //     }
  //   } catch (error) {
  //     // Log any error that occurs during the API call
  //     print('Error: $error');
  //     return {'isSuccess': false, 'error': error.toString()};
  //   }
  // }
// }

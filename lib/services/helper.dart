import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http; 
import 'package:smart_assist/config/route/route_name.dart';
import 'package:smart_assist/utils/token_manager.dart';  

Future<T> processResponse<T>(
  http.Response response,
  T Function(Map<String, dynamic> data) onSuccess,
) async {
  if (response.statusCode == 401) { 
    await TokenManager.clearAuthData();
    Get.offAllNamed(RoutesName.splashScreen); 
    
    throw Exception('Unauthorized. Redirecting to login.');
  } else if (response.statusCode >= 200 && response.statusCode < 300) {
    final Map<String, dynamic> data = json.decode(response.body);
    return onSuccess(data);
  } else {
    final Map<String, dynamic> errorData = json.decode(response.body);
    throw Exception(errorData['message'] ?? 'Error: ${response.statusCode}');
  }
}

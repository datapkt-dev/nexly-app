import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../app/config/app_config.dart';
import '../../../unit/auth_service.dart';

class ProfileController {
  final AuthService authStorage = AuthService();
  final String baseUrl = AppConfig.baseURL;

  Future<Map<String, dynamic>> getUserProfile(int id) async {
    final url = Uri.parse('$baseUrl/projects/1/users/$id');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // 假設 API 是 Bearer Token
    };

    try {
      final response = await http.get(url, headers: headers); // GET, 不是 POST
      final responseData = jsonDecode(response.body);
      // userProfile = responseData['data'];
      //
      // final rawPhone = userProfile['phone'] ?? '';
      // displayPhone = rawPhone.startsWith('+886')
      //     ? rawPhone.replaceFirst('+886', '0')
      //     : rawPhone;

      // print(responseData);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> editUser(Map<String, dynamic> temp) async {
    final url = Uri.parse('$baseUrl/projects/1/users/me');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode(temp);

    try {
      final response = await http.patch(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);
      await authStorage.saveProfile(responseData['data']['user']);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }
}
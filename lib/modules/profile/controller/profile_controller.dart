import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../auth_service.dart';

class ProfileController {
  final _storage = const FlutterSecureStorage();
  final AuthService authStorage = AuthService();

  Future<Map<String, dynamic>> getUserProfile(int id) async {
    final url = Uri.parse('http://18.183.138.134/api/v1/projects/1/users/$id');
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


}
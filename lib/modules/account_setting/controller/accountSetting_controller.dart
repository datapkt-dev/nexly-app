import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../app/config/app_config.dart';
import '../../../unit/auth_service.dart';

class AccountSettingController {
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
      final response = await http.get(url, headers: headers);
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

  Future<Map<String, dynamic>> getUserBlackList() async {
    final url = Uri.parse('$baseUrl/projects/1/users/me/block');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // 假設 API 是 Bearer Token
    };

    try {
      final response = await http.get(url, headers: headers);
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

  Future<Map<String, dynamic>> postBlock(int id) async {
    final url = Uri.parse('$baseUrl/projects/1/users/me/block');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({'blocked_id': id});

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> unBlock(int id) async {
    final url = Uri.parse('$baseUrl/projects/1/users/me/block/$id');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // final body = jsonEncode({'blocked_id': 1});

    try {
      final response = await http.delete(url, headers: headers/*, body: body*/);
      final responseData = jsonDecode(response.body);

      print(responseData);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> changePassword(int id, String password) async {
    final url = Uri.parse('$baseUrl/auth/set-password');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      "id": id,
      "password": password
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);

      print(responseData);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> postReport(String type, int id, String reason) async {
    final url = Uri.parse('$baseUrl/projects/1/reports');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // 假設 API 是 Bearer Token
    };

    final body = jsonEncode({
      "report_type": type, // tales user comment
      "target_id": id,
      "reason": "scam" // needs to be oneof bullying scam misinformation self_harm illegal_goods copyright other
      // "reason_type": // must include when reason is other
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);
      print(responseData);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }
}
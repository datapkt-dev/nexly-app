import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../app/config/app_config.dart';
import '../../../unit/auth_service.dart';

class AccountSettingController {
  final AuthService authStorage = AuthService();
  final String baseUrl = AppConfig.baseURL;

  Future<Map<String, dynamic>> getUserProfile(int id) async {
    final url = Uri.parse('$baseUrl/users/$id');
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
    final url = Uri.parse('$baseUrl/users/me');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode(temp);

    try {
      final response = await http.patch(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);
      if (responseData is Map &&
          responseData['data'] is Map &&
          (responseData['data'] as Map)['user'] is Map) {
        await authStorage.saveProfile(
          Map<String, dynamic>.from(
              (responseData['data'] as Map)['user'] as Map),
        );
      }

      return Map<String, dynamic>.from(responseData as Map);
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }

  /// 檢查社交帳號（account）是否可用。
  /// 回傳格式：
  ///   { "account": "...", "available": true }                           // 可用
  ///   { "account": "...", "available": false, "reason": "..." }         // 不可用
  Future<Map<String, dynamic>> checkAccountAvailability(String account) async {
    final url = Uri.parse('$baseUrl/users/me/check-account?account=${Uri.encodeQueryComponent(account)}');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getUserBlackList() async {
    final url = Uri.parse('$baseUrl/users/me/block');
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
    final url = Uri.parse('$baseUrl/users/me/block');
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
    final url = Uri.parse('$baseUrl/users/me/block/$id');
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

  Future<Map<String, dynamic>> postReport(
      String type, int id, int reasonId, {String? reasonDetail}) async {
    final url = Uri.parse('$baseUrl/reports');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final bodyMap = {
      "report_type": type,
      "target_id": id,
      "reason_id": reasonId,
      if (reasonDetail != null && reasonDetail.isNotEmpty)
        "reason_detail": reasonDetail,
    };

    try {
      final response =
          await http.post(url, headers: headers, body: jsonEncode(bodyMap));
      final responseData = jsonDecode(response.body);
      print(responseData);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }
}
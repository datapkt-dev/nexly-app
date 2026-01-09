import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../app/config/app_config.dart';
import '../../../unit/auth_service.dart';

class ProfileController {
  Future<Map<String, dynamic>> getProfile(id) async {
    final String baseUrl = AppConfig.baseURL;
    final AuthService authStorage = AuthService();

    final url = Uri.parse('$baseUrl/projects/1/users/$id/profile');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // 假設 API 是 Bearer Token
    };

    try {
      final response = await http.get(url, headers: headers);
      final responseData = jsonDecode(response.body);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getUserTales(int userId, int page) async {
    final AuthService authStorage = AuthService();
    final String baseUrl = AppConfig.baseURL;

    final url = Uri.parse('$baseUrl/projects/1/tales/others?page=$page&search_user_id=$userId&page_size=5');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // 假設 API 是 Bearer Token
    };

    try {
      final response = await http.get(url, headers: headers);
      final responseData = jsonDecode(response.body);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getCoTales(int userId, int page) async {
    final AuthService authStorage = AuthService();
    final String baseUrl = AppConfig.baseURL;

    final url = Uri.parse('$baseUrl/projects/1/users/$userId/cotales');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // 假設 API 是 Bearer Token
    };

    try {
      final response = await http.get(url, headers: headers);
      final responseData = jsonDecode(response.body);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getFavorites(int userId, int page) async {
    final AuthService authStorage = AuthService();
    final String baseUrl = AppConfig.baseURL;

    final url = Uri.parse('$baseUrl/projects/1/users/$userId/favorites');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // 假設 API 是 Bearer Token
    };

    try {
      final response = await http.get(url, headers: headers);
      final responseData = jsonDecode(response.body);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }

  Future<void> postFollow(int id) async {
    final String baseUrl = AppConfig.baseURL;
    final AuthService authStorage = AuthService();

    final url = Uri.parse('$baseUrl/projects/1/users/me/follow/toggle');

    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      "user_id": id
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);

      // return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      // return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getAchievement(id) async {
    final String baseUrl = AppConfig.baseURL;
    final AuthService authStorage = AuthService();

    final url = Uri.parse('$baseUrl/projects/1/users/$id/achievements');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // 假設 API 是 Bearer Token
    };

    try {
      final response = await http.get(url, headers: headers);
      final responseData = jsonDecode(response.body);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }
}
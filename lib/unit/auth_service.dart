// lib/services/auth_service.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform, debugPrint;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:firebase_messaging/firebase_messaging.dart';

import '../app/config/app_config.dart';

/// 帳號被停用時拋出此例外
class UserBannedException implements Exception {
  const UserBannedException();
}

class AuthService {
  final String baseUrl = AppConfig.baseURL;
  final _storage = const FlutterSecureStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static bool _gsiInitialized = false; // 只初始化一次

  /// 第三方登入後 server 回傳的 is_new_user 旗標。
  /// signInWithGoogle / signInWithApple 流程結束後，呼叫端可讀取此欄位
  /// 來決定是否導向 onboarding 引導頁。
  bool _lastIsNewUser = false;
  bool get lastIsNewUser => _lastIsNewUser;

  /// 第三方登入回傳的完整 user，供呼叫端在登入成功後寫入 userProvider
  Map<String, dynamic>? _lastUser;
  Map<String, dynamic>? get lastUser => _lastUser;

  /// 監聽登入狀態（可選）
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// 目前使用者（可為 null）
  User? get currentUser => _auth.currentUser;

  void _printLong(String text, {int chunkSize = 800}) {
    for (var i = 0; i < text.length; i += chunkSize) {
      debugPrint(text.substring(i, i + chunkSize > text.length ? text.length : i + chunkSize));
    }
  }

  Future<Map<String, dynamic>> login(String account, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'credential': account,
      'password': password,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);
      if (responseData['code'] == 40300007 || responseData['message'] == 'User is banned') {
        throw const UserBannedException();
      }
      if (response.statusCode == 200) {
        await saveToken(responseData['data']['access_token']);
        await saveProfile(responseData['data']['user']);
      }
      print(responseData);
      return responseData;
    } catch (e) {
      if (e is UserBannedException) rethrow;
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) return null;

      final payload = decodeJwtPayload(token); // 你應該已經有這個方法
      final exp = payload['exp'];
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      if (exp != null && now >= exp) {
        await logout(); // 過期就登出
        return null;
      }

      return token;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'profile');
  }

  Future<void> saveProfile(Map<String, dynamic> profile) async {
    await _storage.write(
      key: 'profile',
      value: jsonEncode(profile),
    );
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final jsonString = await _storage.read(key: 'profile');
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  Future<Map<String, dynamic>> authWithThirdParty({String provider = 'google'}) async {
    // 取得最新的 Firebase ID Token（true 會強制刷新）
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken(true);

    final uri = Uri.parse('$baseUrl/auth/third-party');
    final resp = await http
        .post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'provider': provider,
        'token': idToken,
      }),
    )
        .timeout(const Duration(seconds: 15));


    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      await saveToken(body['data']['access_token']);
      await saveProfile(body['data']['user']);
      _lastIsNewUser = body['data']['is_new_user'] == true;
      _lastUser = (body['data']['user'] is Map)
          ? Map<String, dynamic>.from(body['data']['user'] as Map)
          : null;
      // membership_type 在 data 層（不在 user 內），合併進 _lastUser 方便外部一次寫進 provider
      if (_lastUser != null && body['data']['membership_type'] != null) {
        _lastUser!['membership_type'] = body['data']['membership_type'];
      }
      print(body['data']['user']);
      return body;
    } else {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (body['code'] == 40300007 || body['message'] == 'User is banned') {
        throw const UserBannedException();
      }
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }
  }

  /// Google 登入（Web 用 Firebase popup；Android/iOS/macOS 用 google_sign_in v7）
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // ---- Web：用 Firebase Popup ----
      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..addScope('email')
          ..setCustomParameters({'prompt': 'select_account'});
        final cred = await _auth.signInWithPopup(provider);

        // Web 也同樣把 Firebase ID Token 打給你的後端
        final idToken = await cred.user!.getIdToken(true);
        // debugPrint('firebaseIdToken length=${idToken?.length}');
        // _printLong(idToken!);

        try {
          final backend = await authWithThirdParty(); // 這個方法裡已會抓 currentUser 的 token
          // debugPrint('third-party OK (web): $backend');
        } catch (e) {
          if (e is UserBannedException) rethrow;
          debugPrint('third-party (web) failed: $e');
        }
        return cred;
      }

      // ---- Android/iOS/macOS：google_sign_in v7 ----
      final gsi.GoogleSignIn signIn = gsi.GoogleSignIn.instance;

      // 只初始化一次；iOS 由 plist 讀 clientId；Android 需要 serverClientId
      if (!_gsiInitialized) {
        await signIn.initialize(
          clientId: defaultTargetPlatform == TargetPlatform.iOS
              ? null   // iOS 從 GoogleService-Info.plist 自動讀取
              : null,  // Android 不需要 clientId
          serverClientId: defaultTargetPlatform == TargetPlatform.android
              ? '49445219401-0btf2k6v1bdtjjtajvt8vbbjr2qs21s0.apps.googleusercontent.com'
              : null,
        );
        _gsiInitialized = true;
      }

      if (!signIn.supportsAuthenticate()) {
        throw StateError('This platform does not support GoogleSignIn.authenticate().');
      }

      // 使用者取消會丟 GoogleSignInException(code=canceled)
      final gsi.GoogleSignInAccount account = await signIn.authenticate();

      // v7 只有 idToken（沒有 accessToken）
      final gsi.GoogleSignInAuthentication tokens = await account.authentication;
      if (tokens.idToken == null) {
        throw StateError('Google Sign-In did not return an idToken.');
      }

      // 先用 Google idToken 換 Firebase 身分
      final oauth = GoogleAuthProvider.credential(idToken: tokens.idToken);
      final userCred = await _auth.signInWithCredential(oauth);

      // 成功登入 Firebase 後再取 Firebase ID Token 丟給你的後端
      final idToken = await userCred.user!.getIdToken(true);
      debugPrint('🔑 Firebase ID Token:');
      _printLong(idToken!);

      try {
        final backend = await authWithThirdParty(); // 內部會以 currentUser 重新抓 token
        // debugPrint('third-party OK: $backend');
      } catch (e) {
        if (e is UserBannedException) rethrow;
        debugPrint('third-party login failed: $e');
      }

      return userCred;

    } on gsi.GoogleSignInException catch (e) {
      // 使用者手動取消不當作錯誤
      if (e.code == gsi.GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    } on FirebaseAuthException {
      // e.code: invalid-credential / user-disabled / operation-not-allowed ...
      rethrow;
    }
  }

  /// 登出
  /// - 僅登出（保留授權，下次不需重授權）：使用 signOut()
  /// - 連同撤銷授權（下次需重授權）：使用 disconnect()

  /// Apple 登入（iOS 原生 Sign in with Apple → Firebase → 後端）
  Future<UserCredential?> signInWithApple() async {
    try {
      final appleProvider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');

      final userCred = await _auth.signInWithProvider(appleProvider);

      // 成功登入 Firebase 後，把 Firebase ID Token 打給後端
      try {
        await authWithThirdParty(provider: 'apple');
      } catch (e) {
        if (e is UserBannedException) rethrow;
        debugPrint('third-party (apple) login failed: $e');
      }

      return userCred;
    } on FirebaseAuthException catch (e) {
      // 使用者取消
      if (e.code == 'canceled' || e.code == 'web-context-canceled') {
        return null;
      }
      rethrow;
    } catch (e) {
      // 使用者取消 (iOS native dialog)
      if (e.toString().contains('AuthorizationErrorCode.canceled')) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> signOut({bool revoke = false}) async {
    if (!kIsWeb) {
      try {
        if (revoke) {
          await gsi.GoogleSignIn.instance.disconnect();
        } else {
          await gsi.GoogleSignIn.instance.signOut();
        }
      } catch (_) {
        // 忽略未初始化等狀況
      }
    }
    await _auth.signOut();
  }

  Map<String, dynamic> decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT token');
    }
    final payload = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(payload));
    return jsonDecode(decoded);
  }

  Future<Map<String, dynamic>> delUser() async {
    final uri = Uri.parse('$baseUrl/users/me');
    String? token = await getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // final body = jsonEncode(temp);

    try {
      final response = await http.delete(uri, headers: headers,/* body: body*/);
      final responseData = jsonDecode(response.body);
      print(responseData);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }

  /// 向後端註冊 FCM token，啟用推播
  Future<void> activateFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        debugPrint('⚠️ activateFcmToken: FCM token is null, skip');
        return;
      }

      final token = await getToken();
      if (token == null) {
        debugPrint('⚠️ activateFcmToken: user token is null, skip');
        return;
      }

      // 判斷 device_type
      String deviceType = 'web';
      if (!kIsWeb) {
        if (Platform.isIOS) {
          deviceType = 'ios';
        } else if (Platform.isAndroid) {
          deviceType = 'android';
        }
      }

      final url = Uri.parse('$baseUrl/fcms/me/activate');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final body = jsonEncode({
        'token': fcmToken,
        'device_type': deviceType,
      });

      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);
      debugPrint('✅ activateFcmToken response: $responseData');
    } catch (e) {
      debugPrint('❌ activateFcmToken failed: $e');
    }
  }
}

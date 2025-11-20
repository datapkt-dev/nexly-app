// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform, debugPrint;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;

class AuthService {
  final _storage = const FlutterSecureStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static bool _gsiInitialized = false; // 只初始化一次

  /// 監聽登入狀態（可選）
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// 目前使用者（可為 null）
  User? get currentUser => _auth.currentUser;

  void _printLong(String text, {int chunkSize = 800}) {
    for (var i = 0; i < text.length; i += chunkSize) {
      debugPrint(text.substring(i, i + chunkSize > text.length ? text.length : i + chunkSize));
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

  Future<Map<String, dynamic>> authWithThirdParty() async {
    // 取得最新的 Firebase ID Token（true 會強制刷新）
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken(true);

    final uri = Uri.parse('http://18.183.138.134/api/v1/auth/third-party');
    final resp = await http
        .post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'provider': 'google',
        'token': idToken, // ← 用 Firebase ID Token
      }),
    )
        .timeout(const Duration(seconds: 15));

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      await saveToken(jsonDecode(resp.body)['data']['access_token']);
      await saveProfile(jsonDecode(resp.body)['data']['user']);
      print(jsonDecode(resp.body)['data']['user']);
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
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
          debugPrint('third-party (web) failed: $e');
          // 視需求：要不要在後端失敗時登出/阻擋
        }
        return cred;
      }

      // ---- Android/iOS/macOS：google_sign_in v7 ----
      final gsi.GoogleSignIn signIn = gsi.GoogleSignIn.instance;

      // 只初始化一次；iOS 通常可省略 clientId（由 plist 讀）
      if (!_gsiInitialized) {
        await signIn.initialize(
          clientId: defaultTargetPlatform == TargetPlatform.iOS ? null : null,
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
      // debugPrint('firebaseIdToken length=${idToken?.length}');
      // _printLong(idToken!);

      try {
        final backend = await authWithThirdParty(); // 內部會以 currentUser 重新抓 token
        // debugPrint('third-party OK: $backend');
      } catch (e) {
        debugPrint('third-party login failed: $e');
        // 視需求決定是否要 throw，或僅提示使用者後端登入失敗
        // rethrow; // 若你要把失敗傳回 UI，就打開這行
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
}

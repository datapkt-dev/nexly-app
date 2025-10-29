// lib/services/auth_service.dart
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static bool _gsiInitialized = false; // 只初始化一次

  /// 監聽登入狀態（可選）
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// 目前使用者（可為 null）
  User? get currentUser => _auth.currentUser;

  /// Google 登入（Web 用 Firebase popup；Android/iOS/macOS 用 google_sign_in v7）
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..addScope('email')
          ..setCustomParameters({'prompt': 'select_account'});
        return await _auth.signInWithPopup(provider);
      }

      final gsi.GoogleSignIn signIn = gsi.GoogleSignIn.instance;

      // 初始化一次即可；iOS 可視情況指定 clientId（一般可省略，從 plist 讀）
      if (!_gsiInitialized) {
        await signIn.initialize(
          clientId: defaultTargetPlatform == TargetPlatform.iOS
              ? null // 或填入你的 CLIENT_ID 字串以更保險
              : null,
        );
        _gsiInitialized = true;
      }

      if (!signIn.supportsAuthenticate()) {
        throw StateError(
            'This platform does not support GoogleSignIn.authenticate().');
      }

      // 使用者取消會丟 GoogleSignInException(code=canceled)
      final gsi.GoogleSignInAccount account = await signIn.authenticate();

      // v7: 只有 idToken
      final gsi.GoogleSignInAuthentication tokens = await account.authentication;

      final credential =
      GoogleAuthProvider.credential(idToken: tokens.idToken);

      return await _auth.signInWithCredential(credential);
    } on gsi.GoogleSignInException catch (e) {
      if (e.code == gsi.GoogleSignInExceptionCode.canceled) {
        return null; // 使用者取消
      }
      rethrow;
    } on FirebaseAuthException catch (e) {
      // 讓你在 UI 顯示更清楚的錯誤
      // e.code 範例：invalid-credential、user-disabled、operation-not-allowed…
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
}

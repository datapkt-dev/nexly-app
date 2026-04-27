import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nexly/components/widgets/keyboard_dismiss.dart';
import 'package:nexly/modules/login/pages/forget.dart';
import 'package:nexly/modules/login/pages/register.dart';
import '../index/index.dart';
import '../onboarding/onboarding_page.dart';
import '../providers.dart';
import 'package:nexly/unit/auth_service.dart';
import '../../l10n/app_localizations.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  bool _obscure = true;
  bool _googleLoading = false;           // 👈 Google 登入 loading 狀態
  bool _appleLoading = false;            // 👈 Apple 登入 loading 狀態
  final _authService = AuthService();    // 👈 使用你的 AuthService

  Future<Map<String, dynamic>> futureData = Future.value({});

  TextEditingController controllerAccount = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();

  String _accountError = '';
  String _passwordError = '';
  String _loginError = '';
  Color _accountBorder = const Color(0xFFEEEEEE);
  Color _passwordBorder = const Color(0xFFEEEEEE);

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _showBannedDialog() async {
    if (!mounted) return;
    final t = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(t.account_banned_title),
        content: Text(t.account_banned_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    if (_googleLoading) return;
    setState(() => _googleLoading = true);
    try {
      final cred = await _authService.signInWithGoogle();
      if (!mounted) return;
      if (cred == null) {
        _showSnack('已取消 Google 登入');
      } else {
        _showSnack('登入成功：${cred.user?.email ?? ''}');
        // 登入成功後註冊 FCM token
        _authService.activateFcmToken();
        // 第三方登入：新使用者導向 onboarding，舊使用者直接進主頁
        _routeAfterThirdParty();
      }
    } catch (e) {
      if (e is UserBannedException) {
        await _showBannedDialog();
      } else if (mounted) {
        _showSnack('登入失敗：$e');
      }
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    if (_appleLoading) return;
    setState(() => _appleLoading = true);
    try {
      final cred = await _authService.signInWithApple();
      if (!mounted) return;
      if (cred == null) {
        _showSnack('已取消 Apple 登入');
      } else {
        _showSnack('登入成功：${cred.user?.email ?? ''}');
        _authService.activateFcmToken();
        _routeAfterThirdParty();
      }
    } catch (e) {
      if (e is UserBannedException) {
        await _showBannedDialog();
      } else if (mounted) {
        _showSnack('登入失敗：$e');
      }
    } finally {
      if (mounted) setState(() => _appleLoading = false);
    }
  }

  /// 第三方登入後的路由決策：
  /// - 新使用者（後端 third-party API 回傳 is_new_user = true）→ Onboarding 引導頁
  /// - 老使用者 → 直接進主頁
  void _routeAfterThirdParty() {
    // ✅ 把 server 回傳的完整 user 寫進全域 provider，
    // 確保 AccountSetting / ProfileEdit 立即看到 account / email 等私密欄位
    final user = _authService.lastUser;
    if (user != null) {
      ref.read(userProvider.notifier).setUser(user);
    }
    final isNewUser = _authService.lastIsNewUser;
    final next = isNewUser ? const OnboardingPage() : const Index();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => next),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder(
          future: futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '發生錯誤: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }
            return KeyboardDismissOnTap(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16,),
                  child: Column(
                    children: [
                      SizedBox(height: 120,),
                      Image.asset(
                        'assets/images/logo.png',
                        width: 180,
                        height: 60,
                      ),
                      SizedBox(height: 53,),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: _accountBorder,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: controllerAccount,
                          maxLines: 1,
                          decoration: const InputDecoration(
                            hintText: '信箱',
                            hintStyle: TextStyle(
                              color: Color(0xFFB0B0B0),
                              fontSize: 16,
                              fontFamily: 'PingFang TC',
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(
                            color: Color(0xFF454545),
                            fontSize: 16,
                            fontFamily: 'PingFang TC',
                            fontWeight: FontWeight.w400,
                          ),
                          onChanged: (_) {
                            if (_accountBorder != const Color(0xFFEEEEEE)) {
                              setState(() {
                                _accountBorder = const Color(0xFFEEEEEE);
                                _accountError = '';
                                _loginError = '';
                              });
                            }
                          },
                        ),
                      ),
                      if (_accountError.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _accountError,
                            style: const TextStyle(
                              color: Color(0xFFFF3F23),
                              fontSize: 12,
                              fontFamily: 'PingFang TC',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 32,),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: _passwordBorder,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controllerPassword,
                                obscureText: _obscure,
                                maxLines: 1,
                                decoration: const InputDecoration(
                                  hintText: '密碼',
                                  hintStyle: TextStyle(
                                    color: Color(0xFFB0B0B0),
                                    fontSize: 16,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF454545),
                                  fontSize: 16,
                                  fontFamily: 'PingFang TC',
                                  fontWeight: FontWeight.w400,
                                ),
                                onChanged: (_) {
                                  if (_passwordBorder != const Color(0xFFEEEEEE)) {
                                    setState(() {
                                      _passwordBorder = const Color(0xFFEEEEEE);
                                      _passwordError = '';
                                      _loginError = '';
                                    });
                                  }
                                },
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscure = !_obscure;
                                });
                              },
                              child: _obscure ? const Icon(Icons.visibility_outlined) : const Icon(Icons.visibility_off_outlined),
                            ),
                          ],
                        ),
                      ),
                      if (_passwordError.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _passwordError,
                            style: const TextStyle(
                              color: Color(0xFFFF3F23),
                              fontSize: 12,
                              fontFamily: 'PingFang TC',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                      if (_loginError.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _loginError,
                            style: const TextStyle(
                              color: Color(0xFFFF3F23),
                              fontSize: 12,
                              fontFamily: 'PingFang TC',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 32,),
                      GestureDetector(
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          decoration: ShapeDecoration(
                            color: const Color(0xFF2C538A),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: Text(
                            '登入',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'PingFang TC',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        onTap: () {
                          // 重置錯誤狀態
                          setState(() {
                            _accountError = '';
                            _passwordError = '';
                            _loginError = '';
                            _accountBorder = const Color(0xFFEEEEEE);
                            _passwordBorder = const Color(0xFFEEEEEE);
                          });

                          final account = controllerAccount.text.trim();
                          final password = controllerPassword.text;

                          // 空值檢查
                          if (account.isEmpty && password.isEmpty) {
                            setState(() {
                              _accountBorder = const Color(0xFFFF3F23);
                              _passwordBorder = const Color(0xFFFF3F23);
                              _accountError = '請輸入信箱';
                              _passwordError = '請輸入密碼';
                            });
                            return;
                          }
                          if (account.isEmpty) {
                            setState(() {
                              _accountBorder = const Color(0xFFFF3F23);
                              _accountError = '請輸入信箱';
                            });
                            return;
                          }
                          if (password.isEmpty) {
                            setState(() {
                              _passwordBorder = const Color(0xFFFF3F23);
                              _passwordError = '請輸入密碼';
                            });
                            return;
                          }

                          // 呼叫 API
                          setState(() {
                            futureData = _authService.login(account, password);
                            futureData.then((result) {
                              if (result['message'] == 'Login successful') {
                                // ✅ 直接把登入回傳的完整 user 寫進全域 provider，
                                // 這樣 AccountSetting / ProfileEdit 一進去就能看到 account / email 等私密欄位。
                                final userMap = result['data']?['user'];
                                if (userMap is Map) {
                                  final merged = Map<String, dynamic>.from(userMap);
                                  // membership_type 在 data 層（不在 user 內），合併進來
                                  final membership = result['data']?['membership_type'];
                                  if (membership != null) {
                                    merged['membership_type'] = membership;
                                  }
                                  ref.read(userProvider.notifier).setUser(merged);
                                }
                                _authService.activateFcmToken();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Index()),
                                      (Route<dynamic> route) => false,
                                );
                              } else {
                                setState(() {
                                  _accountBorder = const Color(0xFFFF3F23);
                                  _passwordBorder = const Color(0xFFFF3F23);
                                  _loginError = '帳號或密碼錯誤';
                                });
                              }
                            }).catchError((e) {
                              if (e is UserBannedException) {
                                _showBannedDialog();
                              }
                            });
                          });
                        },
                      ),
                      SizedBox(height: 16,),
                      Row(
                        children: [
                          GestureDetector(
                            child: Text(
                              '忘記密碼？',
                              style: TextStyle(
                                color: const Color(0xFF838383),
                                fontSize: 14,
                                fontFamily: 'PingFang SC',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Forget()),
                              );
                            },
                          ),
                          Spacer(),
                          Text(
                            '還沒有帳號嗎？',
                            style: TextStyle(
                              color: const Color(0xFF838383),
                              fontSize: 14,
                              fontFamily: 'PingFang SC',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(width: 4,),
                          GestureDetector(
                            child: Text(
                              '立即註冊',
                              style: TextStyle(
                                color: const Color(0xFF2C538A),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                // MaterialPageRoute(builder: (context) => SignUp()),
                                MaterialPageRoute(builder: (context) => Register()),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 32,),
                      Text(
                        '或',
                        style: TextStyle(
                          color: const Color(0xFF333333),
                          fontSize: 14,
                          fontFamily: 'PingFang TC',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 32,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            // onTap: _googleLoading ? null : _handleGoogleSignIn,
                            onTap: () {
                              FocusScopeNode currentFocus = FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                                currentFocus.unfocus();
                              }
                              if (!_googleLoading) {
                                _handleGoogleSignIn();
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: ShapeDecoration(
                                color: Colors.white.withOpacity(_googleLoading ? 0.6 : 1),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(width: 1, color: Color(0xFFE7E7E7)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: _googleLoading
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                  : SvgPicture.asset('assets/icons/google.svg'),
                            ),
                          ),
                          if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                            SizedBox(width: 16,),
                            GestureDetector(
                              onTap: () {
                                FocusScopeNode currentFocus = FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                                  currentFocus.unfocus();
                                }
                                if (!_appleLoading) {
                                  _handleAppleSignIn();
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: ShapeDecoration(
                                  color: Colors.white.withValues(alpha: _appleLoading ? 0.6 : 1),
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(width: 1, color: Color(0xFFE7E7E7)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: _appleLoading
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                    : SvgPicture.asset('assets/icons/apple.svg'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

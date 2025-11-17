import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nexly/modules/login/pages/forget.dart';
import 'package:nexly/modules/login/pages/member.dart';
import 'package:nexly/modules/login/pages/register.dart';
import '../index/index.dart';
import 'package:nexly/auth_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _obscure = true;
  bool _googleLoading = false;           // 👈 Google 登入 loading 狀態
  final _authService = AuthService();    // 👈 使用你的 AuthService

  void _showSnack(String msg) {
    if (!mounted) return;
    print(msg);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
        // print(cred.credential);
        _showSnack('登入成功：${cred.user?.email ?? ''}');
        // 成功後導向首頁（用 replace 避免返回登入頁）
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Index()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) _showSnack('登入失敗：$e');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                      color: const Color(0xFFEEEEEE),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    // controller: controller,
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

                  ),
                ),
                SizedBox(height: 32,),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFEEEEEE),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          // controller: controller,
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
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => Member()),
                    // );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Index()),
                    );
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
                      onTap: _googleLoading ? null : _handleGoogleSignIn,
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
                    SizedBox(width: 16,),
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFFE7E7E7),
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: SvgPicture.asset('assets/icons/apple.svg'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

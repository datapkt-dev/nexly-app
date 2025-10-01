import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nexly_temp/modules/login/pages/forget_pwd.dart';
import 'package:nexly_temp/modules/login/pages/member.dart';
import 'package:nexly_temp/modules/login/pages/sign_up.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
                GestureDetector(
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF241172),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Member()),
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
                          MaterialPageRoute(builder: (context) => ForgetPwd()),
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
                          color: const Color(0xFF241172),
                          fontSize: 14,
                          fontFamily: 'PingFang TC',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUp()),
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
                      child: SvgPicture.asset('assets/icons/google.svg',),
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

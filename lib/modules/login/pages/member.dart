import 'package:flutter/material.dart';
import 'package:nexly_temp/modules/index/index.dart';

class Member extends StatefulWidget {
  const Member({super.key});

  @override
  State<Member> createState() => _MemberState();
}

class _MemberState extends State<Member> {
  bool _obscure = true;

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
                      color: const Color(0xFF24B7BD),
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
                      MaterialPageRoute(builder: (context) => Index()),
                    );
                  },
                ),
                SizedBox(height: 16,),
                Row(
                  children: [
                    Text(
                      '忘記密碼？',
                      style: TextStyle(
                        color: const Color(0xFF838383),
                        fontSize: 14,
                        fontFamily: 'PingFang SC',
                        fontWeight: FontWeight.w400,
                      ),
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
                    Text(
                      '立即註冊',
                      style: TextStyle(
                        color: const Color(0xFF24B7BD),
                        fontSize: 14,
                        fontFamily: 'PingFang TC',
                        fontWeight: FontWeight.w500,
                      ),
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

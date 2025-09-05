import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 120,),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: const Color(0xFF656565),
                    size: 24,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 20,),
                Text(
                  '用戶註冊',
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 24,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 20,),
                Text(
                  '帳號設定',
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 16,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w400,
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
                      color: const Color(0xFFF1F4F6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text(
                      '發送驗證碼',
                      style: TextStyle(
                        color: Color(0xFFB3B3B3),
                        fontSize: 14,
                        fontFamily: 'PingFang TC',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  onTap: () {

                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

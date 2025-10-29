// import 'package:speedingservice/modules/login/pages/resetPWD.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nexly/modules/login/pages/resetPWD.dart';
// import '../../../config/app_config.dart';
// import '../../../units/auth_service.dart';

class Forget extends StatefulWidget {
  const Forget({super.key});

  @override
  State<Forget> createState() => _ForgetState();
}

class _ForgetState extends State<Forget> {
  // final String baseUrl = AppConfig.baseURL;
  // final LoginService loginService = LoginService(baseUrl: AppConfig.baseURL);
  // final AuthService authStorage = AuthService();
  Future<Map<String, dynamic>> futureData = Future.value({});

  int layer = 0;

  Color _number = Color(0xFF333333);
  Color _code = Color(0xFF333333);
  String err = '';
  TextEditingController controllerNumber = TextEditingController();
  String number = '';
  TextEditingController controllerCode = TextEditingController();

  // Future<Map<String, dynamic>> sendCode(String tempNumber) async {
  //   final url = Uri.parse('$baseUrl/auth/send-code');
  //   if (tempNumber.startsWith("0")) {
  //     tempNumber = tempNumber.substring(1);
  //     number = '+886$tempNumber';
  //   }
  //
  //   final headers = {
  //     'Content-Type': 'application/json',
  //   };
  //
  //   final body = jsonEncode({
  //     // 'credential': number,
  //     "action": "forget_password",
  //     'credential': number,
  //   });
  //
  //   try {
  //     final response = await http.post(url, headers: headers, body: body);
  //     final responseData = jsonDecode(response.body);
  //
  //     return responseData;
  //   } catch (e) {
  //     print('請求錯誤：$e');
  //     return {'error': e.toString()};
  //   }
  // }

  // Future<Map<String, dynamic>> verifyCode(String code) async {
  //   final url = Uri.parse('$baseUrl/auth/verify-code');
  //
  //   final headers = {
  //     'Content-Type': 'application/json',
  //   };
  //
  //   final body = jsonEncode({
  //     "credential" : number,
  //     "code" : code
  //   });
  //
  //   try {
  //     final response = await http.post(url, headers: headers, body: body);
  //     final responseData = jsonDecode(response.body);
  //
  //     return responseData;
  //   } catch (e) {
  //     print('請求錯誤：$e');
  //     return {'error': e.toString()};
  //   }
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
              return _buildLayer();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLayer() {
    switch (layer) {
      case 0:
        return enterNumber();
      case 1:
        return enterCode();
      default:
        return const Center(child: Text("未知層級"));
    }
  }

  Widget enterNumber() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 120,),
          IconButton(
            padding: EdgeInsets.zero, // 移除內建 padding
            constraints: const BoxConstraints(), // 移除最小點擊範圍限制（視需要）
            icon: Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20,),
          Text(
            '忘記密碼',
            style: TextStyle(
              color: const Color(0xFF333333),
              fontSize: 24,
              fontFamily: 'PingFang TC',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20,),
          Text(
            '請輸入信箱',
            style: TextStyle(
              color: const Color(0xFF333333),
              fontSize: 16,
              fontFamily: 'PingFang TC',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 32,),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: _number,
                  width: 0,
                ),
              ),
            ),
            child: TextField(
              controller: controllerNumber,
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
                color: Color(0xFFB0B0B0),
                fontSize: 16,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (err != '') ...[
            SizedBox(height: 6,),
            Text(
              err,
              style: TextStyle(
                color: const Color(0xFFFF3F23),
                fontSize: 12,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          const SizedBox(height: 32,),
          GestureDetector(
            onTap: () {
              final input = controllerNumber.text.trim();
              err = '';
              _number = Color(0xFF333333);

              // 不接受任何空白
              if (RegExp(r'\s').hasMatch(input)) {
                setState(() {
                  err = 'Email 不可包含空白字元';
                  _number = const Color(0xFFFF3F23);
                });
                return;
              }

              // 簡潔實用版檢查：有一個 @、後面至少一個點 + 至少2位 TLD
              final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
              final isValid = emailRegex.hasMatch(input);

              if (!isValid) {
                setState(() {
                  err = '請輸入正確的 Email 格式';
                  _number = const Color(0xFFFF3F23);
                });
                return;
              }

              setState(() {
                // futureData = sendCode(controllerNumber.text);
                // futureData.then((result) {
                //   print(result);
                //   if (result['message'] == 'OTP 已發送，請留意您的簡訊') {
                //     layer++;
                //   } else {
                //     err = result['message'];
                //     _number = const Color(0xFFFF3F23);
                //   }
                // });
                layer++;
              });
            },
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              decoration: ShapeDecoration(
                color: const Color(0xFF2C538A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(
                '發送驗證碼',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'PingFang TC',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget enterCode() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 120,),
          IconButton(
            padding: EdgeInsets.zero, // 移除內建 padding
            constraints: const BoxConstraints(), // 移除最小點擊範圍限制（視需要）
            icon: Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
              ),
            ),
            onPressed: () {
              setState(() {
                layer--;
              });
            },
          ),
          const SizedBox(height: 20,),
          Text(
            '忘記密碼',
            style: TextStyle(
              color: const Color(0xFF333333),
              fontSize: 24,
              fontFamily: 'PingFang TC',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20,),
          Text(
            '驗證碼已經發送至${controllerNumber.text}',
            style: TextStyle(
              color: const Color(0xFF333333),
              fontSize: 16,
              fontFamily: 'PingFang TC',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 32,),
          Align(
            alignment: AlignmentGeometry.centerRight,
            child: Text(
              '重寄驗證碼(180s)',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: const Color(0xFF2C538A),
                fontSize: 14,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 16,),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: _code,
                  width: 0,
                ),
              ),
            ),
            child: TextField(
              controller: controllerCode,
              maxLines: 1,
              decoration: const InputDecoration(
                hintText: '輸入驗證碼6碼',
                hintStyle: TextStyle(
                  color: Color(0xFFB0B0B0),
                  fontSize: 16,
                  fontFamily: 'PingFang TC',
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
              ),
              style: const TextStyle(
                color: Color(0xFFB0B0B0),
                fontSize: 16,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (err != '') ...[
            SizedBox(height: 6,),
            Text(
              err,
              style: TextStyle(
                color: const Color(0xFFFF3F23),
                fontSize: 12,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          const SizedBox(height: 32,),
          GestureDetector(
            onTap: () {
              setState(() {
                // futureData = verifyCode(controllerCode.text);
                // futureData.then((result) {
                //   print(result);
                //   if (result['data']?['valid'] == true) {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => ResetPWD(number: number)),
                //     ).then((result) {
                //       setState(() {
                //         layer = 0;
                //       });
                //     });
                //   } else {
                //     err = result['message'];
                //     _code = Color(0xFFFF3F23);
                //   }
                // });

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ResetPWD(number: number)),
                );
              });
            },
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              decoration: ShapeDecoration(
                color: const Color(0xFF2C538A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(
                '下一步',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'PingFang TC',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

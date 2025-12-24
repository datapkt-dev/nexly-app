import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/config/app_config.dart';
import '../../../components/widgets/DateInputFormatter.dart';
import '../login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  Future<Map<String, dynamic>> futureData = Future.value({});

  int layer = 0;

  TextEditingController controllerMail = TextEditingController();
  String mail = '';
  TextEditingController controllerCode = TextEditingController();

  TextEditingController controllerAccount = TextEditingController();
  TextEditingController controllerName = TextEditingController();
  List<String> gender = ['男性', '女性', '不透露',];
  int selectedGender = 0;
  TextEditingController controllerBirth = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerPasswordCheck = TextEditingController();
  Color _number = Color(0xFFEEEEEE);
  String err = '';
  Color _tooltip = Color(0xFF656565);
  Color _password = Color(0xFFE7E7E7);
  Color _passwordCheck = Color(0xFFE7E7E7);
  // bool errCheck = false;

  final GlobalKey<TooltipState> _tooltipKey = GlobalKey<TooltipState>();

  Future<Map<String, dynamic>> postSendCode(String email) async {
    String baseUrl = AppConfig.baseURL;
    print('sendCode');
    print(email);
    final url = Uri.parse('$baseUrl/auth/send-code');

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "action": "register",
      'credential': email,
      "source": "email_verification"
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> postVerifyCode(String email, String code) async {
    String baseUrl = AppConfig.baseURL;
    final url = Uri.parse('$baseUrl/auth/verify-code');

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "credential" : email,
      "code" : code,
      "source": "email_verification"
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }

  bool isValidPassword(String password) {
    final regex = RegExp(r'^[a-zA-Z0-9]{8,}$');
    return regex.hasMatch(password);
  }

  Future<Map<String, dynamic>> postRegister() async {
    String baseUrl = AppConfig.baseURL;
    final url = Uri.parse('$baseUrl/auth/register');

    final genderMap = {0: "M", 1: "F", 2: "Other"};
    final genderValue = genderMap[selectedGender] ?? "Other";

    // 先把 vehicle 轉成 cars
    // final cars = vehicle.map((v) {
    //   return {
    //     "car_type": v[0].text,
    //     "car_number": v[1].text,
    //   };
    // }).toList();

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "name" : controllerName.text,
      "email" : mail,
      // "phone" : number,
      "birthday": controllerBirth.text,
      "gender": genderValue, // M, F, Other
      "country": "TW", // 寫死TW
      "project_id": 1, // Must Provided
      // "cars": cars,
      "password": controllerPassword.text
    });
    print(body);

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }

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
      case 2:
        return userData();
      case 3:
        return enterPassword();
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
                Icons.arrow_back_ios_rounded,
                // color: const Color(0xFFEFEFEF),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20,),
          Text(
            '用戶註冊',
            style: TextStyle(
              color: const Color(0xFF333333),
              fontSize: 24,
              fontFamily: 'PingFang TC',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20,),
          Text(
            '帳號設定',
            style: TextStyle(
              color: const Color(0xFF333333),
              fontSize: 16,
              fontFamily: 'PingFang TC',
              fontWeight: FontWeight.w400,
              height: 1.25,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 32,),
          Container(
            // height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: _number,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: controllerMail,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: '請輸入信箱',
                hintStyle: TextStyle(
                  color: Color(0xFFABABAB),
                  fontSize: 16,
                  fontFamily: 'PingFang TC',
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                color: Color(0xFFABABAB),
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
              final input = controllerMail.text.trim();

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
                err = '';
                _number = Color(0xFF333333);
                mail = '';
                futureData = postSendCode(controllerMail.text);
                futureData.then((result) {
                  print(result);
                  if (result['message'] == 'OTP sent, please check your email') {
                    mail = controllerMail.text;
                    layer++;
                  } else {
                    err = result['message'];
                    _number = Color(0xFFFF3F23);
                    if (result['data']?['exists'] == true) {
                      err = '該信箱已註冊過';
                    }
                  }
                });
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
                Icons.arrow_back_ios_rounded,
                // color: const Color(0xFFEFEFEF),
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
            '用戶註冊',
            style: TextStyle(
              color: const Color(0xFF333333),
              fontSize: 24,
              fontFamily: 'PingFang TC',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20,),
          Text(
            '驗證碼已經發送至',
            style: TextStyle(
              color: const Color(0xFF333333),
              fontSize: 16,
              fontFamily: 'PingFang TC',
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            mail,
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
            // height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                isDense: true,
                contentPadding: EdgeInsets.zero,
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
                err = '';
                futureData = postVerifyCode(mail, controllerCode.text);
                futureData.then((result) {
                  print(result);
                  if (result['message'] == 'Verification successful') {
                    layer++;
                  } else {
                    err = result['message'];
                  }
                });
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

  Widget userData() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 120,),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
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
                Icons.arrow_back_ios_rounded,
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
            '用戶註冊',
            style: TextStyle(
              color: const Color(0xFF333333),
              fontSize: 24,
              fontFamily: 'PingFang TC',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20,),
          Text(
            '基本資料',
            style: TextStyle(
              color: const Color(0xFF333333),
              fontSize: 16,
              fontFamily: 'PingFang TC',
              fontWeight: FontWeight.w400,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: const Color(0xFFE7E7E7),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: TextField(
              controller: controllerAccount,
              maxLines: 1,
              decoration: const InputDecoration(
                hintText: '用戶帳號',
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
                color: Color(0xFFB0B0B0),
                fontSize: 16,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(height: 10,),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: const Color(0xFFE7E7E7),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: TextField(
              controller: controllerName,
              maxLines: 1,
              decoration: const InputDecoration(
                hintText: '姓名',
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
                color: Color(0xFFB0B0B0),
                fontSize: 16,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(height: 10,),
          Container(
            height: 44,
            decoration: ShapeDecoration(
              color: const Color(0xFFEEEEEF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Row(
              children: List.generate(gender.length, (index) {
                return Expanded(
                  child: InkWell(
                    child: Container(
                      alignment: Alignment.center,
                      height: double.infinity,
                      decoration: selectedGender == index ? ShapeDecoration(
                        color: const Color(0xFF2C538A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ) : null,
                      child: Text(
                        gender[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selectedGender == index ? Colors.white : Color(0xFF333333),
                          fontSize: 14,
                          fontFamily: 'PingFang TC',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        selectedGender = index;
                      });
                    },
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 10,),
          Container(
            // height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: const Color(0xFFE7E7E7),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: TextField(
              controller: controllerBirth,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // 只允許數字
                DateInputFormatter(), // 自訂格式化
              ],
              maxLines: 1,
              decoration: const InputDecoration(
                hintText: '生日',
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
                color: Color(0xFFB0B0B0),
                fontSize: 16,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 32,),
          GestureDetector(
            onTap: () {
              setState(() {
                if (controllerAccount.text != '' && controllerName.text != '' && controllerBirth.text != '') {
                  err ='';
                  layer++;
                } else {
                  err = '請填寫完整資料';
                }
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

  Widget enterPassword() {
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
                Icons.arrow_back_ios_rounded,
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
            '用戶註冊',
            style: TextStyle(
              color: const Color(0xFF333333),
              fontSize: 24,
              fontFamily: 'PingFang TC',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20,),
          Text(
            '密碼設定',
            style: TextStyle(
              color: const Color(0xFF333333),
              fontSize: 16,
              fontFamily: 'PingFang TC',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 32,),
          Container(
            // height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: _password,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: TextField(
              controller: controllerPassword,
              maxLines: 1,
              decoration: const InputDecoration(
                hintText: '輸入密碼',
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
                color: Color(0xFFB0B0B0),
                fontSize: 16,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Row(
            children: [
              Spacer(),
              Tooltip(
                key: _tooltipKey,
                triggerMode: TooltipTriggerMode.manual, // ✅ 改成手動控制
                message: '密碼必須包含至少8字元，可使用大寫字母、小寫字母和數字',
                textStyle: const TextStyle(
                  color: Color(0xFFEFEFEF),
                  fontSize: 12,
                  fontFamily: 'PingFang TC',
                  fontWeight: FontWeight.w400,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: IconButton(
                  icon: Icon(Icons.info_outline, color: _tooltip),
                  onPressed: () {
                    // ✅ 點擊時顯示 Tooltip
                    final tooltip = _tooltipKey.currentState;
                    tooltip?.ensureTooltipVisible();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32,),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: _passwordCheck,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: TextField(
              controller: controllerPasswordCheck,
              maxLines: 1,
              decoration: const InputDecoration(
                hintText: '再次輸入密碼',
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
                height: 1.25,
              ),
            )
          ],
          const SizedBox(height: 32,),
          GestureDetector(
            onTap: () {
              setState(() {
                _password = Color(0xFFE7E7E7);
                _passwordCheck = Color(0xFFE7E7E7);
                _tooltip = Color(0xFF656565);
                err = '';
                final password = controllerPassword.text;
                final passwordCheck = controllerPasswordCheck.text;

                if (password != passwordCheck) {
                  _passwordCheck = Color(0xFFFF3F23);
                  err = '兩次輸入的密碼不一致';
                  return;
                }

                if (!isValidPassword(password)) {
                  _password = Color(0xFFFF3F23);
                  _passwordCheck = Color(0xFFFF3F23);
                  _tooltip = Color(0xFFFF3F23);
                  err = '密碼需至少 8 碼，可使用大寫字母、小寫字母與數字';
                  return;
                }

                futureData = postRegister();
                futureData.then((result) {
                  if (result['message'] == 'Registration successful') {
                    showDialog(
                      context: context,
                      barrierDismissible: false, // 一定要按按鈕
                      builder: (context) {
                        return Dialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFF4A4A4A), width: 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20), // 四邊 20
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 40),
                                Text(
                                  '註冊成功，請重新登入',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFF333333),
                                    fontSize: 16,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 60),
                                GestureDetector(
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: ShapeDecoration(
                                      color: Color(0xFF2C538A),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    ),
                                    child: const Text(
                                      '確定',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'PingFang TC',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => const Login()),
                                          (Route<dynamic> route) => false,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    err = '註冊失敗';
                  }
                });
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
                '建立帳號',
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

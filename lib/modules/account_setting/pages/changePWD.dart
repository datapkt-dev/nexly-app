import 'package:flutter/material.dart';
import '../../login/login.dart';
import '../controller/accountSetting_controller.dart';

class ChangePWD extends StatefulWidget {
  final int id;
  const ChangePWD({super.key, required this.id});

  @override
  State<ChangePWD> createState() => _ResetPWDState();
}

class _ResetPWDState extends State<ChangePWD> {
  final AccountSettingController accountSettingController = AccountSettingController();
  Future<Map<String, dynamic>> futureData = Future.value({});

  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerPasswordCheck = TextEditingController();
  Color _password = Color(0xFF333333);
  Color _passwordCheck = Color(0xFF333333);
  Color _tooltip = Color(0xFF656565);
  String err = '';
  bool errCheck = false;

  final GlobalKey<TooltipState> _tooltipKey = GlobalKey<TooltipState>();

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
              return Column(
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
                        Icons.close_rounded,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 20,),
                  Text(
                    '重設密碼',
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
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: _password,
                          width: 0,
                        ),
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
                          icon: const Icon(Icons.info_outline, color: Colors.grey),
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
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: _passwordCheck,
                          width: 0,
                        ),
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
                      ),
                      style: const TextStyle(
                        color: Color(0xFFB0B0B0),
                        fontSize: 16,
                        fontFamily: 'PingFang TC',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  if (errCheck) ...[
                    SizedBox(height: 6,),
                    Text(
                      '密碼不ㄧ致，請確認',
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
                    onTap: () async {
                      setState(() {
                        _password = Color(0xFF333333);
                        _passwordCheck = Color(0xFF333333);
                        _tooltip = Color(0xFF656565);
                        err = '';
                        errCheck = false;
                      });
                      if (controllerPassword.text == controllerPasswordCheck.text) {
                        final res =  await accountSettingController.changePassword(widget.id, controllerPassword.text);
                        print(res);
                        if (res['message'] == 'Password set successfully') {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const Login()),
                                (Route<dynamic> route) => false, // 移除所有舊頁面
                          );
                        }
                      } else {
                        setState(() {
                          _passwordCheck = Color(0xFFFF3F23);
                          errCheck = true;
                        });
                      }
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
                        '確定',
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
              );
            },
          ),
        ),
      ),
    );
  }
}

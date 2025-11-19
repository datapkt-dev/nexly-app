import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../../DateInputFormatter.dart';
import '../controller/profile_controller.dart';

class ProfileEdit extends StatefulWidget {
  final Map<String, dynamic>? userProfile;
  const ProfileEdit({super.key, this.userProfile});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final ProfileController profileController = ProfileController();
  Future<Map<String, dynamic>> futureData = Future.value({});
  Map<String, dynamic> profileData = {};

  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerBio = TextEditingController();
  TextEditingController controllerBirth = TextEditingController();
  String? selectedGenderCode;
  Map<String, dynamic> gender = {
    'M' : '男性',
    'F' : '女性',
    'Other' : '不透露',
  };

  Future<void> _loadUser() async {
    setState(() {
      futureData = profileController.getUserProfile(widget.userProfile?['id']);
      futureData.then((result) {
        profileData = result['data']['user'];
        controllerName.text = profileData['name'];
        controllerBio.text = profileData['bio'] ?? '';
        if (profileData.containsKey('birthday') && profileData['birthday'] != null) {
          controllerBirth.text = DateFormat('yyyy-MM-dd').format(DateTime.parse(profileData['birthday']).toLocal());
        } else {
          controllerBirth.text = '';
        }
        selectedGenderCode = profileData['gender'];
      });
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // iconTheme: const IconThemeData(color: Color(0xFF333333)),
        title: Text(
          '會員資料',
          style: TextStyle(
            color: const Color(0xFF333333),
            fontSize: 18,
            fontFamily: 'PingFang TC',
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              '完成',
              style: TextStyle(
                color: const Color(0xFF333333),
                fontSize: 16,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w400,
              ),
            ),
            onPressed: () {
              setState(() {
                Map<String, dynamic> tempData = {
                  "name": controllerName.text,
                  "birthday": controllerBirth.text,
                  "gender": selectedGenderCode, // M, F, Other
                  "bio": controllerBio.text
                };
                futureData = profileController.editUser(tempData);
                futureData.then((result) {
                  if (result['message'] == 'User updated successfully') {
                    Navigator.pop(context, 'refresh');
                  } else {
                    _showSnack('請正確填寫資料');
                  }
                });
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 4,
                          offset: Offset(0, 0),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Text(
                              '姓名',
                              style: TextStyle(
                                color: const Color(0xFF333333),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: controllerName,
                                maxLines: 1,
                                textAlign: TextAlign.end,
                                decoration: const InputDecoration(
                                  isCollapsed: true,                 // 關閉額外裝飾高度
                                  contentPadding: EdgeInsets.zero,   // 內距 0
                                  hintText: '輸入您的姓名',
                                  hintStyle: TextStyle(
                                    color: Color(0xFFB0B0B0),
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 14,
                                  fontFamily: 'PingFang TC',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 40,),
                        Row(
                          children: [
                            Text(
                              '社交帳號',
                              style: TextStyle(
                                color: const Color(0xFF333333),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                            Text(
                              '${profileData['email'] ?? '-'}',
                              style: TextStyle(
                                color: const Color(0xFF333333),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 40,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '個人簡介',
                              style: TextStyle(
                                color: const Color(0xFF333333),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 10,),
                            Expanded(
                              child: TextField(
                                controller: controllerBio,
                                textInputAction: TextInputAction.newline,
                                minLines: 1,
                                maxLines: null,
                                textAlign: TextAlign.end,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  isCollapsed: true,
                                  contentPadding: EdgeInsets.zero,   // 內距 0
                                  hintText: '輸入簡介',
                                  hintStyle: TextStyle(
                                    color: Color(0xFFB0B0B0),
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 14,
                                  fontFamily: 'PingFang TC',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 40,),
                        Row(
                          children: [
                            Text(
                              '生日',
                              style: TextStyle(
                                color: const Color(0xFF333333),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: controllerBirth,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly, // 只允許數字
                                  DateInputFormatter(), // 自訂格式化
                                ],
                                maxLines: 1,
                                textAlign: TextAlign.end,
                                decoration: const InputDecoration(
                                  isCollapsed: true,                 // 關閉額外裝飾高度
                                  contentPadding: EdgeInsets.zero,   // 內距 0
                                  hintText: '輸入您的生日',
                                  hintStyle: TextStyle(
                                    color: Color(0xFFB0B0B0),
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 14,
                                  fontFamily: 'PingFang TC',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 40,),
                        Row(
                          children: [
                            Text(
                              '性別',
                              style: TextStyle(
                                color: const Color(0xFF333333),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                  ),
                                  builder: (context) {
                                    return SafeArea(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: gender.entries.map((entry) {
                                          return ListTile(
                                            title: Text(entry.value), // 顯示中文
                                            onTap: () {
                                              setState(() {
                                                selectedGenderCode = entry.key; // 存代碼
                                              });
                                              Navigator.pop(context);
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Text(
                                selectedGenderCode == null
                                    ? '請選擇性別'
                                    : gender[selectedGenderCode]!, // 根據代碼找顯示文字
                                style: TextStyle(
                                  color: selectedGenderCode == null
                                      ? const Color(0xFFB0B0B0) // 提示文字灰色
                                      : const Color(0xFF333333),
                                  fontSize: 14,
                                  fontFamily: 'PingFang TC',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          ],
                        ),
                        Divider(height: 40,),
                        Row(
                          children: [
                            Text(
                              '國家/地區',
                              style: TextStyle(
                                color: const Color(0xFF333333),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                            Text(
                              // widget.userProfile?['displayPhone'],
                              '美國紐約',
                              style: TextStyle(
                                color: const Color(0xFF333333),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 40,),
                        Row(
                          children: [
                            Text(
                              '信箱',
                              style: TextStyle(
                                color: const Color(0xFF333333),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                            Text(
                              widget.userProfile?['email']??'',
                              style: TextStyle(
                                color: const Color(0xFF333333),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 40,),
                      ],
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

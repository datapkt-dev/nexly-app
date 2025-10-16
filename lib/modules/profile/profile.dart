import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../components/widgets/upload_image_widget.dart';
import '../login/login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // final String baseUrl = AppConfig.baseURL;
  // final AuthService authStorage = AuthService();
  Future<Map<String, dynamic>> futureData = Future.value({});

  Map<String, dynamic>? user;
  Map<String, dynamic> userProfile = {};

  final genderMap = {
    "M": "男性",
    "F": "女性",
    "Other": "不透露",
  };
  String displayPhone = '';

  // Future<void> _loadUser() async {
  //   final profile = await authStorage.getProfile();
  //   setState(() {
  //     user = profile;
  //     print(user);
  //     futureData = getUserProfile(user?['id']);
  //   });
  // }
  //
  // Future<Map<String, dynamic>> getUserProfile(int id) async {
  //   final url = Uri.parse('$baseUrl/projects/1/users/$id');
  //   String? token = await authStorage.getToken();
  //
  //   final headers = {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $token', // 假設 API 是 Bearer Token
  //   };
  //
  //   try {
  //     final response = await http.get(url, headers: headers); // GET, 不是 POST
  //     final responseData = jsonDecode(response.body);
  //     userProfile = responseData['data'];
  //
  //     final rawPhone = userProfile['phone'] ?? '';
  //     displayPhone = rawPhone.startsWith('+886')
  //         ? rawPhone.replaceFirst('+886', '0')
  //         : rawPhone;
  //
  //     print(responseData);
  //
  //     return responseData;
  //   } catch (e) {
  //     print('請求錯誤：$e');
  //     return {'error': e.toString()};
  //   }
  // }
  //
  // Future<Map<String, dynamic>> uploadImg(String filePath) async {
  //   final file = File(filePath);
  //   if (!await file.exists()) {
  //     return {'error': 'File not found: $filePath'};
  //   }
  //
  //   final uri = Uri.parse('$baseUrl/upload-image'); // 若有 HTTPS 請改 https
  //   final request = http.MultipartRequest('POST', uri);
  //
  //   request.files.add(
  //     await http.MultipartFile.fromPath('files', filePath), // 不帶 contentType
  //   );
  //
  //   final streamed = await request.send();
  //   final response = await http.Response.fromStream(streamed);
  //   final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
  //
  //   return body;
  // }
  //
  // Future<Map<String, dynamic>> editUserImg(String newImgUrl) async {
  //   final url = Uri.parse('$baseUrl/projects/1/users/${userProfile['id']}');
  //   String? token = await authStorage.getToken();
  //
  //   final headers = {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $token',
  //   };
  //
  //   final body = jsonEncode({
  //     "name" : userProfile['name'],
  //     "birthday" : userProfile['birthday'],
  //     "gender" : userProfile['gender'],
  //     "country" : "TW",
  //     "avatar_url" : newImgUrl,
  //     "background_url" : ""
  //   });
  //
  //   try {
  //     final response = await http.patch(url, headers: headers, body: body);
  //     final responseData = jsonDecode(response.body);
  //     print(responseData);
  //     if (responseData['message'] == '員工更新成功') {
  //       setState(() {
  //         futureData = getUserProfile(user?['id']);
  //         futureData.then((result) async {
  //           print(result);
  //           await authStorage.saveProfile(result['data']);
  //         });
  //       });
  //     }
  //
  //     return responseData;
  //   } catch (e) {
  //     print('請求錯誤：$e');
  //     return {'error': e.toString()};
  //   }
  // }
  //
  // Future<Map<String, dynamic>> delUser() async {
  //   final url = Uri.parse('$baseUrl/projects/1/users/${userProfile['id']}');
  //   String? token = await authStorage.getToken();
  //
  //   final headers = {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $token',
  //   };
  //
  //   try {
  //     final response = await http.delete(url, headers: headers);
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
    // _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // iconTheme: const IconThemeData(color: Color(0xFFEFEFEF)),
        title: Text(
          '帳號設定 ',
          style: TextStyle(
            color: const Color(0xFF333333),
            fontSize: 18,
            fontFamily: 'PingFang TC',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder(
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
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        UploadImageWidget(
                          child: Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: ShapeDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(userProfile['avatar_url'] ?? ''),
                                    fit: BoxFit.cover,
                                  ),
                                  shape: OvalBorder(
                                    side: BorderSide(
                                      width: 2,
                                      color: const Color(0xFFE7E7E7),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: ShapeDecoration(
                                    color: Colors.black.withValues(alpha: 0.60),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.photo_camera,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onImagePicked: (imgRoute) async {
                            // final res = await uploadImg(imgRoute);
                            // if (res.containsKey('error') && res['error'] != null) {
                            //   print('有錯誤');
                            //   print(res);
                            // } else {//
                            //   print('沒錯誤');
                            //   print(res['local_urls'].first);
                            //   editUserImg(res['local_urls'].first.toString());
                            // }
                          },
                        ),
                        SizedBox(width: 16,),
                        Text(
                          '${userProfile['name']} (id: ${userProfile['id']})',
                          style: TextStyle(
                            color: const Color(0xFF333333),
                            fontSize: 16,
                            fontFamily: 'PingFang TC',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          child: Row(
                            children: [
                              Text(
                                '編輯',
                                style: TextStyle(
                                  color: const Color(0xFFF9D400),
                                  fontSize: 14,
                                  fontFamily: 'PingFang TC',
                                  fontWeight: FontWeight.w400,
                                  height: 1.25,
                                ),
                              ),
                              Icon(
                                Icons.border_color_outlined,
                                size: 13,
                                color: const Color(0xFFF9D400),
                              ),
                            ],
                          ),
                          onTap: () {
                            // userProfile['displayPhone'] = displayPhone;
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => ProfileEdit(userProfile: userProfile,)),
                            // ).then((result) {
                            //   if (result == 'refresh') {
                            //     setState(() {
                            //       futureData = getUserProfile(user?['id']);
                            //       futureData.then((result) async {
                            //         print(result);
                            //         await authStorage.saveProfile(result['data']);
                            //       });
                            //     });
                            //   }
                            // });
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: ShapeDecoration(
                      color: Color(0xFF3A3A3A),
                      // color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                                color: const Color(0xFFEFEFEF),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                            Text(
                              '${userProfile['name']}',
                              style: TextStyle(
                                color: const Color(0xFFEFEFEF),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20,),
                        Divider(),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Text(
                              '生日',
                              style: TextStyle(
                                color: const Color(0xFFEFEFEF),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                            Text(
                              '${userProfile['birthday']??'未輸入'}',
                              style: TextStyle(
                                color: const Color(0xFFEFEFEF),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Divider(),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Text(
                              '性別',
                              style: TextStyle(
                                color: const Color(0xFFEFEFEF),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                            Text(
                              genderMap[userProfile['gender']] ?? '其他',
                              style: TextStyle(
                                color: const Color(0xFFEFEFEF),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Divider(),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Text(
                              '信箱',
                              style: TextStyle(
                                color: const Color(0xFFEFEFEF),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                            Text(
                              '${userProfile['email']}',
                              style: TextStyle(
                                color: const Color(0xFFEFEFEF),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Divider(),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Text(
                              '電話',
                              style: TextStyle(
                                color: const Color(0xFFEFEFEF),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                            Text(
                              displayPhone,
                              style: TextStyle(
                                color: const Color(0xFFEFEFEF),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Divider(),
                        SizedBox(height: 10,),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: ShapeDecoration(
                      color: Color(0xFF3A3A3A),
                      // color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                        Text(
                          '其他',
                          style: TextStyle(
                            color: const Color(0xFFEFEFEF),
                            fontSize: 14,
                            fontFamily: 'PingFang TC',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        InkWell(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              children: [
                                Text(
                                  '變更密碼',
                                  style: TextStyle(
                                    color: const Color(0xFFEFEFEF),
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: const Color(0xFFEFEFEF),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => ResetPWD(number: userProfile['phone'],)),
                            // );
                          },
                        ),
                        Divider(),
                        InkWell(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              '刪除帳號',
                              style: TextStyle(
                                color: const Color(0xFFFF5858),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false, // 一定要按按鈕
                              builder: (context) {
                                return Dialog(
                                  backgroundColor: const Color(0xFF2E2E2E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: Color(0xFF4A4A4A), width: 1),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20), // 四邊 20
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(height: 40),
                                        Text(
                                          '是否確定刪除此帳號?',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: const Color(0xFFEFEFEF),
                                            fontSize: 16,
                                            fontFamily: 'PingFang TC',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 60),
                                        Row(
                                          children: [
                                            // 確認刪除
                                            Expanded(
                                              child: GestureDetector(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  padding: const EdgeInsets.all(10),
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        color: const Color(0xFF949292),
                                                      ),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    '確認刪除',
                                                    style: TextStyle(
                                                      color: const Color(0xFFFF3F23),
                                                      fontSize: 14,
                                                      fontFamily: 'PingFang TC',
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  // futureData = delUser();
                                                  // futureData.then((result) async {
                                                  //   print(result);
                                                  //   if (result['message'] == '訪客刪除成功') {
                                                  //     await authStorage.logout();
                                                  //     Navigator.pushAndRemoveUntil(
                                                  //       context,
                                                  //       MaterialPageRoute(builder: (context) => const Login()),
                                                  //           (Route<dynamic> route) => false, // 移除所有先前頁面
                                                  //     );
                                                  //   }
                                                  // });
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // 取消
                                            Expanded(
                                              child: GestureDetector(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  padding: const EdgeInsets.all(10),
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        color: const Color(0xFF949292),
                                                      ),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    '取消',
                                                    style: TextStyle(
                                                      color: const Color(0xFFEFEFEF),
                                                      fontSize: 14,
                                                      fontFamily: 'PingFang TC',
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 60),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

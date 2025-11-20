import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nexly/modules/payment/payment.dart';
import 'package:nexly/modules/profile/pages/profile_edit.dart';
import 'package:nexly/modules/profile/widgets/black_list.dart';
import 'package:nexly/modules/profile/widgets/privacy.dart';
import '../../unit/auth_service.dart';
import '../../components/widgets/upload_image_widget.dart';
import '../login/login.dart';
import '../login/pages/resetPWD.dart';
import '../setting/setting.dart';
import 'controller/profile_controller.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService authStorage = AuthService();
  final ProfileController profileController = ProfileController();
  Future<Map<String, dynamic>> futureData = Future.value({});

  Map<String, dynamic>? user;
  List? blockList;
  // Map<String, dynamic> userProfile = {};

  final genderMap = {
    "M": "男性",
    "F": "女性",
    "Other": "不透露",
  };
  String displayPhone = '';

  String temp = '';

  Future<void> _loadUser() async {
    final profile = await authStorage.getProfile();
    setState(() {
      futureData = profileController.getUserBlackList();
      futureData.then((result) {
        blockList?.clear();
        blockList = result['data']['items'];
      });
      user = profile;
    });
  }

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
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        // iconTheme: const IconThemeData(color: Color(0xFF333333)),
        title: Text(
          '帳號設定',
          style: TextStyle(
            color: const Color(0xFF333333),
            fontSize: 18,
            fontFamily: 'PingFang TC',
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              profileController.postBlock();
            },
            child: Text(
              'Block',
              style: TextStyle(
                color: const Color(0xFF333333),
                fontSize: 16,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              FutureBuilder(
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
                                      image: temp != '' ? DecorationImage(
                                        // image: NetworkImage(userProfile['avatar_url'] ?? ''),
                                        image: AssetImage(temp),
                                        fit: BoxFit.cover,
                                      ) : null,
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
                                print('success pick');
                                print(imgRoute);
                                setState(() {
                                  temp = imgRoute;
                                });
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
                              '${user?['name'] ?? '-'}',
                              // 'Sam',
                              style: TextStyle(
                                color: const Color(0xFF333333),
                                fontSize: 16,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 4,),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: ShapeDecoration(
                                color: const Color(0xFF2C538A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset('assets/icons/logo_main.svg'),
                                  SizedBox(width: 2,),
                                  SvgPicture.asset('assets/icons/logo_words.svg'),
                                  SizedBox(width: 2,),
                                  SvgPicture.asset('assets/icons/logo_+.svg'),
                                ],
                              ),
                            ),
                            Spacer(),
                            GestureDetector(
                              child: Row(
                                children: [
                                  Text(
                                    '編輯個人資料',
                                    style: TextStyle(
                                      color: const Color(0xFF333333),
                                      fontSize: 14,
                                      fontFamily: 'PingFang TC',
                                      fontWeight: FontWeight.w400,
                                      height: 1.25,
                                    ),
                                  ),
                                  Icon(
                                    Icons.border_color_outlined,
                                    size: 13,
                                    // color: const Color(0xFFF9D400),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ProfileEdit(userProfile: user,)),
                                ).then((result) {
                                  if (result == 'refresh') {
                                    _loadUser();
                                  }
                                });
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
                        margin: EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: ShapeDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/banner_upgrade.png'),
                            fit: BoxFit.cover,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: OvalBorder(),
                              ),
                              child: Image.asset(
                                'assets/images/logo_small.png',
                                height: 32,
                                width: 32,
                              ),
                            ),
                            SizedBox(width: 10,),
                            Text(
                              '將幸福延續簡單傳遞',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Spacer(),
                            GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.only(top: 2, left: 10, right: 8, bottom: 2),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFEDB60C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '升級',
                                      style: TextStyle(
                                        color: const Color(0xFF2C538A),
                                        fontSize: 14,
                                        fontFamily: 'PingFang TC',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 10,
                                      color: const Color(0xFF2C538A),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Payment()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
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
                                  '👤 姓名',
                                  style: TextStyle(
                                    color: const Color(0xFF333333),
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '${user?['name']}',
                                  style: TextStyle(
                                    color: const Color(0xFF333333),
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 40,),
                            Row(
                              children: [
                                Text(
                                  '😄 社交帳號',
                                  style: TextStyle(
                                    color: const Color(0xFF333333),
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '${user?['email']??'-'}',
                                  style: TextStyle(
                                    color: const Color(0xFF333333),
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 40,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '💬 個人簡介',
                                  style: TextStyle(
                                    color: const Color(0xFF333333),
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '${user?['bio']??'-'}',
                                        style: TextStyle(
                                          color: const Color(0xFF333333),
                                          fontSize: 14,
                                          fontFamily: 'PingFang TC',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                ),
                              ],
                            ),
                            Divider(height: 40,),
                            Row(
                              children: [
                                Text(
                                  '🎂 生日',
                                  style: TextStyle(
                                    color: const Color(0xFF333333),
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  (() {
                                    final v = user?['birthday'];
                                    if (v is String && v.length >= 10) return v.substring(0, 10); // 取 YYYY-MM-DD
                                    return '未輸入';
                                  })(),
                                  style: TextStyle(
                                    color: const Color(0xFF333333),
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 40,),
                            Row(
                              children: [
                                Text(
                                  '👥 性別',
                                  style: TextStyle(
                                    color: const Color(0xFF333333),
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  genderMap[user?['gender']] ?? '未輸入',
                                  style: TextStyle(
                                    color: const Color(0xFF333333),
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 40,),
                            Row(
                              children: [
                                Text(
                                  '🌐 國家/地區',
                                  style: TextStyle(
                                    color: const Color(0xFF333333),
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '美國紐約',
                                  style: TextStyle(
                                    color: const Color(0xFF333333),
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 40,),
                            Row(
                              children: [
                                Text(
                                  '✉️ 信箱',
                                  style: TextStyle(
                                    color: const Color(0xFF333333),
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '${user?['email']}',
                                  style: TextStyle(
                                    color: const Color(0xFF333333),
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
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
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 20),
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
                    Text(
                      '其他',
                      style: TextStyle(
                        color: const Color(0xFF333333),
                        fontSize: 14,
                        fontFamily: 'PingFang TC',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 20,),
                    InkWell(
                      child: Row(
                        children: [
                          Text(
                            '🔒 隱私設定',
                            style: TextStyle(
                              color: const Color(0xFF333333),
                              fontSize: 14,
                              fontFamily: 'PingFang TC',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                        ],
                      ),
                      onTap: () async {
                        final step = await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => Privacy(dataPass: blockList,),
                        );

                        if (step == 'open_blacklist') {
                          final res = await showModalBottomSheet<String>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (ctx) => BlackList(blockList: blockList),
                          );
                          print(res);
                          if (res == 'refresh') {
                            _loadUser();
                            // await _reloadData();
                            // setState(() {});
                          }
                        }
                      },
                    ),
                    Divider(height: 40,),
                    InkWell(
                      child: Row(
                        children: [
                          Text(
                            '🔑 變更密碼',
                            style: TextStyle(
                              color: const Color(0xFF333333),
                              fontSize: 14,
                              fontFamily: 'PingFang TC',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ResetPWD()),
                        );
                      },
                    ),
                    Divider(height: 40,),
                    InkWell(
                      child: Row(
                        children: [
                          Text(
                            '🌍 語言',
                            style: TextStyle(
                              color: const Color(0xFF333333),
                              fontSize: 14,
                              fontFamily: 'PingFang TC',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Setting()),
                        );
                      },
                    ),
                    Divider(height: 40,),
                    InkWell(
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          '👏 登出',
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
                              backgroundColor: Colors.white,
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
                                      '是否確定要登出?',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(0xFF333333),
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
                                                color: Color(0xFFE9416C),
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                    width: 1,
                                                    color: const Color(0xFFE9416C),
                                                  ),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                              ),
                                              child: const Text(
                                                '確認登出',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontFamily: 'PingFang TC',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            onTap: () async {
                                              await authStorage.logout();
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(builder: (context) => const Login()),
                                                    (Route<dynamic> route) => false, // 移除所有先前頁面
                                              );
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
                                                  color: const Color(0xFF333333),
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
                    Divider(height: 40,),
                    InkWell(
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          '🗑️ 刪除帳號',
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
                              backgroundColor: Colors.white,
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
                                        color: const Color(0xFF333333),
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
                                                color: Color(0xFFE9416C),
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                    width: 1,
                                                    color: const Color(0xFFE9416C),
                                                  ),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                              ),
                                              child: const Text(
                                                '確認刪除',
                                                style: TextStyle(
                                                  color: Colors.white,
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
                                                  color: const Color(0xFF333333),
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
                    SizedBox(height: 20,),
                  ],
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

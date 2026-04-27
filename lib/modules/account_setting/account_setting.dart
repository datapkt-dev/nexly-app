import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nexly/modules/payment/payment.dart';
import 'package:nexly/modules/account_setting/pages/changePWD.dart';
import 'package:nexly/modules/account_setting/pages/profile_edit.dart';
import 'package:nexly/modules/account_setting/widgets/black_list.dart';
import 'package:nexly/modules/account_setting/widgets/privacy.dart';
import '../../app/config/app_config.dart';
import '../../components/utils/display_name.dart';
import '../../unit/auth_service.dart';
import '../../components/widgets/upload_image_widget.dart';
import '../login/login.dart';
import '../language_setting/language_setting.dart';
import '../providers.dart';
import 'controller/accountSetting_controller.dart';
import 'widgets/country_data.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class AccountSetting extends ConsumerStatefulWidget {
  const AccountSetting({super.key});

  @override
  ConsumerState<AccountSetting> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<AccountSetting> {
  final AuthService authStorage = AuthService();
  final AccountSettingController accountSettingController = AccountSettingController();

  /// 黑名單為此頁面專屬狀態，不放進全域 user provider。
  List? blockList;
  bool _blackListLoading = true;

  final genderMap = {
    "M": "男性",
    "F": "女性",
    "Other": "不透露",
  };
  String displayPhone = '';

  @override
  void initState() {
    super.initState();
    // user 由 ref.watch(userProvider) 取得，這裡只負責：
    // 1) 觸發初始化及背景刷新（bootstrap 會先讀 secure storage，再背景打 /me）
    // 2) 載入此頁專屬的黑名單
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(userProvider.notifier).bootstrap();
      _loadBlackList();
    });
  }

  Future<void> _loadBlackList() async {
    try {
      final res = await accountSettingController.getUserBlackList();
      if (!mounted) return;
      setState(() {
        blockList = res['data']?['items'];
        _blackListLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _blackListLoading = false);
    }
  }

  Future<Map<String, dynamic>> uploadImg(String filePath) async {
    final String baseUrl = AppConfig.baseURL;
    final file = File(filePath);
    if (!await file.exists()) {
      return {'error': 'File not found: $filePath'};
    }

    final uri = Uri.parse('$baseUrl/upload-image');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath('files', filePath),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    return body;
  }

  Future<Map<String, dynamic>> editUserImg(String newImgUrl) async {
    final String baseUrl = AppConfig.baseURL;
    final url = Uri.parse('$baseUrl/users/me');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      "avatar_url": newImgUrl,
    });

    try {
      final response = await http.patch(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);

      if (responseData['message'] == 'User updated successfully') {
        // 立即更新全域 user state，全 App 訂閱者（首頁頭像、留言區作者卡…）
        // 一起同步，無須各自重打 API。
        await ref
            .read(userProvider.notifier)
            .merge({'avatar_url': newImgUrl});
      }

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 16, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 80, height: 12, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: double.infinity,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: List.generate(6, (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 80, height: 14, color: Colors.white),
                    Container(width: 100, height: 14, color: Colors.white),
                  ],
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 全 App 共用的 user 來源
    final user = ref.watch(userProvider);
    final temp = (user['avatar_url'] ?? '') as String;
    final hasUser = user.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          '帳號設定',
          style: TextStyle(
            color: const Color(0xFF333333),
            fontSize: 18,
            fontFamily: 'PingFang TC',
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              if (!hasUser)
                _buildShimmer()
              else
                Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            UploadImageWidget(
                              child: Stack(
                                children: [
                                  ClipOval(
                                    child: temp != ''
                                        ? Image(
                                            image: CachedNetworkImageProvider(temp),
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            gaplessPlayback: true,
                                            errorBuilder: (_, __, ___) => Container(
                                              width: 80,
                                              height: 80,
                                              color: const Color(0xFFE7E7E7),
                                              child: const Icon(Icons.person, color: Colors.grey),
                                            ),
                                          )
                                        : Container(
                                            width: 80,
                                            height: 80,
                                            color: const Color(0xFFE7E7E7),
                                            child: const Icon(Icons.person, color: Colors.grey),
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
                                final upRes = await uploadImg(imgRoute);
                                if (upRes['message'] == 'Upload successful') {
                                  await editUserImg(upRes['data']['urls'][0]);
                                }
                              },
                            ),
                            SizedBox(width: 16,),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 可換行的「名字 + 徽章」
                                  Expanded(
                                    child: Wrap(
                                      spacing: 4,
                                      children: [
                                        // 名字：可多行
                                        Text(
                                          displayNameOrAccount(user['name'], user['account']).isEmpty
                                              ? '-'
                                              : displayNameOrAccount(user['name'], user['account']),
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                          style: const TextStyle(
                                            color: Color(0xFF333333),
                                            fontSize: 16,
                                            fontFamily: 'PingFang TC',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        // 徽章（只有付費會員才顯示）
                                        if ((user['membership_type'] ?? 'free') != 'free')
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFF2C538A),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SvgPicture.asset('assets/icons/logo_main.svg'),
                                                const SizedBox(width: 2),
                                                SvgPicture.asset('assets/icons/logo_words.svg'),
                                                const SizedBox(width: 2),
                                                SvgPicture.asset('assets/icons/logo_+.svg'),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // 右側固定的「編輯個人資料」
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const ProfileEdit()),
                                      );
                                      // 編輯頁直接呼叫 userProvider.merge()，
                                      // 不再需要從 pop 結果合併。
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Text(
                                          '編輯個人資料',
                                          style: TextStyle(
                                            color: Color(0xFF333333),
                                            fontSize: 14,
                                            fontFamily: 'PingFang TC',
                                            fontWeight: FontWeight.w400,
                                            height: 1.25,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(Icons.border_color_outlined, size: 13),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 升級 banner（只有 free 會員才顯示）
                      if ((user['membership_type'] ?? 'free') == 'free')
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
                                  displayNameOrAccount(user['name'], user['account']),
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
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    user['account'] ?? '-',
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                                        '${user['bio']??'-'}',
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
                                    final v = user['birthday'];
                                    if (v is String && v.length >= 10) return v.substring(0, 10);
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
                                  genderMap[user['gender']] ?? '未輸入',
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
                                  countryName(user['country']),
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
                                  '🏙️ 城市',
                                  style: TextStyle(
                                    color: const Color(0xFF333333),
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  (user['city'] ?? '').toString().isEmpty
                                      ? '未輸入'
                                      : user['city'].toString(),
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
                                  '${user['email']}',
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
                          builder: (ctx) => Privacy(
                            dataPass: {
                              "privacy_tales": user['privacy_tales'],
                              "privacy_cotales": user['privacy_cotales'],
                              "privacy_favorites": user['privacy_favorites'],
                            },
                          ),
                        );

                        if (step == 'open_blacklist') {
                          final res = await showModalBottomSheet<String>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (ctx) => BlackList(blockList: blockList),
                          );
                          // 黑名單頁可能解除過封鎖，回來後重新拉一次
                          if (res == 'refresh') {
                            await _loadBlackList();
                          }
                        }

                        // 隱私設定可能在 bottom sheet 內被改動，回來後背景刷新
                        ref.read(userProvider.notifier).refreshFromServer();
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
                          MaterialPageRoute(builder: (context) => ChangePWD(id: user['id'],)),
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
                          MaterialPageRoute(builder: (context) => const LanguageSetting()),
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
                                        // 確認登出
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
                                              // 清空全域 user state，避免下個帳號殘留
                                              ref.read(userProvider.notifier).clear();
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
                                                  color: Color(0xFF333333),
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
                                            onTap: () async {
                                              final res = await authStorage.delUser();
                                              if (res['message'] == 'User deleted successfully') {
                                                await authStorage.logout();
                                                ref.read(userProvider.notifier).clear();
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => const Login()),
                                                      (Route<dynamic> route) => false, // 移除所有先前頁面
                                                );
                                              }
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

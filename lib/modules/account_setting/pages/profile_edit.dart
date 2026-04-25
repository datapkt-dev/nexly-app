import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers.dart';
import '../../../unit/auth_service.dart';
import '../controller/accountSetting_controller.dart';
import '../widgets/country_data.dart';
import '../widgets/country_picker_sheet.dart';
import 'social_account_page.dart';

class ProfileEdit extends ConsumerStatefulWidget {
  const ProfileEdit({super.key});

  @override
  ConsumerState<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends ConsumerState<ProfileEdit> {
  final AccountSettingController accountSettingController = AccountSettingController();
  Map<String, dynamic> profileData = {};
  bool _saving = false;

  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerBio = TextEditingController();
  TextEditingController controllerCity = TextEditingController();
  String? selectedGenderCode;
  String? selectedCountryCode;

  /// 生日改用 native date picker，存 DateTime
  DateTime? _birthDate;

  /// ✅ 記錄初始值，用來做 dirty diff
  String _initialName = '';
  String _initialBio = '';
  String _initialCity = '';
  DateTime? _initialBirthDate;
  String? _initialGenderCode;
  String? _initialCountryCode;

  Map<String, dynamic> gender = {
    'M' : '男性',
    'F' : '女性',
    'Other' : '不透露',
  };

  /// 從全域 userProvider 拿初始資料填表單。
  ///
  /// 注意：使用者可能正在輸入，所以只覆蓋「使用者沒改過的欄位」，
  /// 避免背景刷新打斷編輯。判斷方式：當前控制器內容仍等於初始快照值。
  void _hydrateFromProvider({bool preserveEdits = false}) {
    final src = ref.read(userProvider);
    profileData = Map<String, dynamic>.from(src);

    final newName = (profileData['name'] ?? '').toString();
    final newBio = (profileData['bio'] ?? '').toString();
    final newCity = (profileData['city'] ?? '').toString();
    final newGender = profileData['gender'] as String?;
    final newCountry = profileData['country'] as String?;

    // 解析生日
    DateTime? newBirth;
    final birthday = profileData['birthday'];
    if (birthday != null && birthday.toString().isNotEmpty) {
      try {
        newBirth = DateTime.parse(birthday.toString()).toLocal();
      } catch (_) {}
    }

    // preserveEdits = true 時（背景同步），只覆蓋使用者沒改過的欄位
    if (preserveEdits) {
      if (controllerName.text == _initialName) controllerName.text = newName;
      if (controllerBio.text == _initialBio) controllerBio.text = newBio;
      if (controllerCity.text == _initialCity) controllerCity.text = newCity;
      if (selectedGenderCode == _initialGenderCode) selectedGenderCode = newGender;
      if (selectedCountryCode == _initialCountryCode) selectedCountryCode = newCountry;
      if (_isSameDate(_birthDate, _initialBirthDate)) _birthDate = newBirth;
    } else {
      controllerName.text = newName;
      controllerBio.text = newBio;
      controllerCity.text = newCity;
      selectedGenderCode = newGender;
      selectedCountryCode = newCountry;
      _birthDate = newBirth;
    }

    // 更新「初始值」基準（背景同步後 dirty diff 也應以最新值為基準）
    _initialName = newName;
    _initialBio = newBio;
    _initialCity = newCity;
    _initialGenderCode = newGender;
    _initialCountryCode = newCountry;
    _initialBirthDate = newBirth;
  }

  /// ✅ 計算 dirty diff：只送真的有改的欄位
  Map<String, dynamic> _buildDiffPatch() {
    final patch = <String, dynamic>{};

    // name：可以改成空字串
    if (controllerName.text != _initialName) {
      patch['name'] = controllerName.text;
    }

    // bio：空字串 → null（讓 server 真的清空）
    if (controllerBio.text != _initialBio) {
      patch['bio'] = controllerBio.text.isEmpty ? null : controllerBio.text;
    }

    // city：空字串 → null
    if (controllerCity.text != _initialCity) {
      patch['city'] = controllerCity.text.isEmpty ? null : controllerCity.text;
    }

    // birthday：日期物件比對；改了就送 yyyy-MM-dd，清空就送 null
    if (!_isSameDate(_birthDate, _initialBirthDate)) {
      patch['birthday'] = _birthDate == null
          ? null
          : DateFormat('yyyy-MM-dd').format(_birthDate!);
    }

    // gender
    if (selectedGenderCode != _initialGenderCode) {
      patch['gender'] = selectedGenderCode;
    }

    // country
    if (selectedCountryCode != _initialCountryCode) {
      patch['country'] = selectedCountryCode;
    }

    return patch;
  }

  bool _isSameDate(DateTime? a, DateTime? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 開啟 native date picker（與 OnboardingPage 一致），13 歲下限
  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final lastAllowed = DateTime(now.year - 13, now.month, now.day);
    final initial = _birthDate ?? DateTime(now.year - 20, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(lastAllowed) ? lastAllowed : initial,
      firstDate: DateTime(1900),
      lastDate: lastAllowed,
      helpText: '選擇生日',
      cancelText: '取消',
      confirmText: '確定',
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2C538A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF333333),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // ✅ ConsumerState 的 initState 可以直接用 ref.read。
    // 不要再用 addPostFrameCallback —— 它會在第一次 build「之後」才執行，
    // 且 _hydrateFromProvider 內沒有 setState，所以 UI 永遠停在第一幀的空值
    // （profileData={}），這就是「社交帳號顯示 -」的真正原因。
    _hydrateFromProvider();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 直接 watch userProvider；任何欄位（特別是社交帳號 account）
    // 變動時這裡都會自動 rebuild，不會被 _hydrateFromProvider 的時機影響。
    final liveUser = ref.watch(userProvider);
    final liveAccount = (liveUser['account'] ?? '').toString();

    // ✅ 監聽全域 user 變化（例如背景刷新後拿到原本沒有的 account / email），
    // 自動 re-hydrate 表單，且不打斷使用者正在編輯的欄位。
    ref.listen<Map<String, dynamic>>(userProvider, (previous, next) {
      if (!mounted) return;
      // 只在資料真的「擴充」了（出現新欄位/欄位由 null 變有值）時才重 hydrate
      final prevAccount = previous?['account'];
      final nextAccount = next['account'];
      final accountAppeared =
          (prevAccount == null || prevAccount.toString().isEmpty) &&
              (nextAccount != null && nextAccount.toString().isNotEmpty);
      // 任何 server 回來的新值都觸發；同步保留正在編輯中的欄位
      if (accountAppeared || previous == null || previous.length != next.length) {
        setState(() => _hydrateFromProvider(preserveEdits: true));
      }
    });

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
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    '完成',
                    style: TextStyle(
                      color: const Color(0xFF333333),
                      fontSize: 16,
                      fontFamily: 'PingFang TC',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
            onPressed: (_saving || liveAccount.isEmpty)
                ? null
                : () async {
                    final patch = _buildDiffPatch();

                    // 沒有改任何東西
                    if (patch.isEmpty) {
                      _showSnack('沒有任何變更');
                      Navigator.pop(context);
                      return;
                    }

                    setState(() => _saving = true);
                    final result = await accountSettingController.editUser(patch);
                    if (!mounted) return;
                    setState(() => _saving = false);

                    if (result['message'] == 'User updated successfully') {
                      // 把 server 回傳的最新 user 寫進全域 provider，
                      // 全 App 訂閱者立即同步。
                      final updatedUser =
                          (result['data'] is Map && result['data']['user'] is Map)
                              ? Map<String, dynamic>.from(result['data']['user'] as Map)
                              : profileData;
                      await ref.read(userProvider.notifier).merge(updatedUser);
                      // ✅ 同步寫回 secure storage（provider.merge 只改記憶體）
                      final authService = AuthService();
                      await authService.saveProfile(updatedUser);
                      _showSnack('更新成功');
                      Navigator.pop(context);
                    } else {
                      _showSnack('更新失敗，請稍後重試');
                    }
                  },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
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
                            InkWell(
                              onTap: () async {
                                final result = await Navigator.push<String>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SocialAccountPage(
                                      currentAccount: liveAccount.isEmpty
                                          ? null
                                          : liveAccount,
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  // 子頁回傳新帳號 → 更新全域 provider
                                  // （SocialAccountPage 內部已做 PATCH，
                                  // 這裡只是同步 UI 用的本地 fallback）
                                  await ref
                                      .read(userProvider.notifier)
                                      .merge({'account': result});
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    liveAccount.isEmpty ? '-' : liveAccount,
                                    style: const TextStyle(
                                      color: Color(0xFF333333),
                                      fontSize: 14,
                                      fontFamily: 'PingFang TC',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right, size: 18, color: Color(0xFF838383)),
                                ],
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
                        // 生日：點擊開啟系統 native date picker
                        InkWell(
                          onTap: _pickBirthday,
                          child: Row(
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
                              const Spacer(),
                              Text(
                                _birthDate == null
                                    ? '選擇生日'
                                    : DateFormat('yyyy-MM-dd').format(_birthDate!),
                                style: TextStyle(
                                  color: _birthDate == null
                                      ? const Color(0xFFB0B0B0)
                                      : const Color(0xFF333333),
                                  fontSize: 14,
                                  fontFamily: 'PingFang TC',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right,
                                  size: 18, color: Color(0xFF838383)),
                            ],
                          ),
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
                            InkWell(
                              onTap: () async {
                                final selected = await CountryPickerSheet.show(
                                  context,
                                  currentCode: selectedCountryCode,
                                );
                                if (selected != null) {
                                  setState(() {
                                    selectedCountryCode = selected;
                                  });
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    countryName(selectedCountryCode),
                                    style: TextStyle(
                                      color: selectedCountryCode == null
                                          ? const Color(0xFFB0B0B0)
                                          : const Color(0xFF333333),
                                      fontSize: 14,
                                      fontFamily: 'PingFang TC',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right, size: 18, color: Color(0xFF838383)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 40,),
                        // 城市：自由文字輸入
                        Row(
                          children: [
                            Text(
                              '城市',
                              style: TextStyle(
                                color: const Color(0xFF333333),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: controllerCity,
                                maxLines: 1,
                                textAlign: TextAlign.end,
                                decoration: const InputDecoration(
                                  isCollapsed: true,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: '輸入城市（例如 Taipei）',
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
                              (liveUser['email'] ?? '').toString(),
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
          ),
        ),
      ),
    );
  }
}

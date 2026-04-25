import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../components/widgets/account_availability_field.dart';
import '../../unit/auth_service.dart';
import '../account_setting/controller/accountSetting_controller.dart';
import '../account_setting/widgets/country_data.dart';
import '../account_setting/widgets/country_picker_sheet.dart';
import '../index/index.dart';
import '../providers.dart';

/// 第三方登入後的引導頁面（onboarding）。
///
/// 觸發時機：
/// - Google / Apple 登入成功後，若 `auth_service.lastIsNewUser == true`
/// - 由 login.dart 用 `pushAndRemoveUntil` 導入，使用者無法返回登入頁
///
/// 流程設計（共 3 步）：
///   Step 1：社交帳號（必填，需 unique，重用 AccountAvailabilityField）
///   Step 2：生日（必填，年齡至少 13 歲，符合 IG 標準）
///   Step 3：性別 / 國家 / 城市（皆選填，可整步跳過）
///
/// 完成後：
///   1) PATCH /users/me 一次送出所有蒐集到的欄位
///   2) 更新全域 userProvider
///   3) pushAndRemoveUntil 進入 Index
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  final AccountSettingController _api = AccountSettingController();
  final AuthService _auth = AuthService();

  static const int _totalSteps = 3;
  int _currentStep = 0;

  // ── Step 1：社交帳號 ──
  String _account = '';
  AccountCheckStatus _accountStatus = AccountCheckStatus.idle;

  // ── Step 2：生日 ──
  /// 生日改用 native date picker 選取，存成 DateTime。
  DateTime? _birthDate;
  String? _birthError;

  // ── Step 3：性別 / 國家 / 城市 ──
  String? _gender;
  String? _country;
  final TextEditingController _cityController = TextEditingController();

  bool _submitting = false;

  static const Map<String, String> _genderOptions = {
    'M': '男性',
    'F': '女性',
    'Other': '不透露',
  };

  @override
  void initState() {
    super.initState();
    // 國家欄位用裝置 locale 預填（例如 zh-TW → 自動選 TW）
    _country = _detectCountryFromLocale();
  }

  /// 嘗試從裝置 locale 推斷國家代碼。
  /// 規則：
  ///   1) 優先用 locale.countryCode（例如 zh-TW、en-US 都會直接拿到 'TW'/'US'）
  ///   2) 拿到後檢查我們的 country_data 是否支援；不支援就 null
  String? _detectCountryFromLocale() {
    try {
      final locales = PlatformDispatcher.instance.locales;
      for (final loc in locales) {
        final code = loc.countryCode;
        if (code != null && code.isNotEmpty) {
          final upper = code.toUpperCase();
          // 檢查 country_data 認得這個 code（countryName 找不到時會回傳 fallback，
          // 所以這裡用 isSupportedCountry 直接判斷比較準）
          if (isSupportedCountry(upper)) return upper;
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // ── 驗證 ──────────────────────────────────────────────
  bool get _step1Valid {
    if (_account.trim().isEmpty) return false;
    return _accountStatus == AccountCheckStatus.available;
  }

  /// 生日：使用 _birthDate（DateTime），且年齡 ≥ 13 歲
  bool _validateBirth() {
    final picked = _birthDate;
    if (picked == null) {
      setState(() => _birthError = '請選擇生日');
      return false;
    }
    final now = DateTime.now();
    if (picked.isAfter(now)) {
      setState(() => _birthError = '生日不能在未來');
      return false;
    }
    int age = now.year - picked.year;
    if (now.month < picked.month ||
        (now.month == picked.month && now.day < picked.day)) {
      age--;
    }
    if (age < 13) {
      setState(() => _birthError = '需滿 13 歲才能使用本服務');
      return false;
    }
    setState(() => _birthError = null);
    return true;
  }

  // ── 流程控制 ──────────────────────────────────────────
  Future<void> _goNext() async {
    // Step 1 → 2
    if (_currentStep == 0) {
      if (!_step1Valid) return;
      _animateTo(1);
      return;
    }
    // Step 2 → 3
    if (_currentStep == 1) {
      if (!_validateBirth()) return;
      _animateTo(2);
      return;
    }
    // Step 3 → 完成
    if (_currentStep == 2) {
      await _submit();
    }
  }

  void _goBack() {
    if (_currentStep == 0) return;
    _animateTo(_currentStep - 1);
  }

  void _animateTo(int index) {
    setState(() => _currentStep = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  // 直接跳過 Step 3（不送選填欄位）
  Future<void> _skipFinalStep() async {
    await _submit(skipOptional: true);
  }

  // ── 送出 ──────────────────────────────────────────────
  Future<void> _submit({bool skipOptional = false}) async {
    setState(() => _submitting = true);

    final patch = <String, dynamic>{
      'account': _account.trim(),
      'birthday': DateFormat('yyyy-MM-dd').format(_birthDate!),
    };
    if (!skipOptional) {
      if (_gender != null) patch['gender'] = _gender;
      if (_country != null) patch['country'] = _country;
      final city = _cityController.text.trim();
      if (city.isNotEmpty) patch['city'] = city;
    }

    final result = await _api.editUser(patch);
    if (!mounted) return;

    if (result['message'] == 'User updated successfully') {
      // 更新全域 user state
      final raw = result['data'];
      final updatedUser = (raw is Map && raw['user'] is Map)
          ? Map<String, dynamic>.from(raw['user'] as Map)
          : null;
      if (updatedUser != null) {
        await ref.read(userProvider.notifier).merge(updatedUser);
        // ✅ 同步寫回 secure storage，下次重開 App 或進 Index 時就有最新資料
        await _auth.saveProfile(updatedUser);
      } else {
        await ref.read(userProvider.notifier).refreshFromServer();
      }

      // 註冊 FCM token（避免 onboarding 期間漏掉）
      _auth.activateFcmToken();

      // 進主頁
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Index()),
        (route) => false,
      );
    } else {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('資料儲存失敗，請稍後再試'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── UI ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // 阻擋 Android 系統返回
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          leading: _currentStep == 0
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
                  onPressed: _submitting ? null : _goBack,
                ),
          title: Text(
            '完成個人資料 ${_currentStep + 1}/$_totalSteps',
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 16,
              fontFamily: 'PingFang TC',
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildProgressBar(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStepAccount(),
                    _buildStepBirthday(),
                    _buildStepOptional(),
                  ],
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(_totalSteps, (i) {
          final active = i <= _currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              margin: EdgeInsets.only(right: i == _totalSteps - 1 ? 0 : 6),
              height: 4,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF2C538A) : const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Step 1：社交帳號 ──
  Widget _buildStepAccount() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '建立你的社交帳號',
            style: TextStyle(
              color: Color(0xFF333333),
              fontSize: 22,
              fontFamily: 'PingFang TC',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '這是其他人在 Nexly 上找到你的方式，之後可以再修改。',
            style: TextStyle(
              color: Color(0xFF838383),
              fontSize: 13,
              fontFamily: 'PingFang TC',
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          AccountAvailabilityField(
            initialValue: '',
            autofocus: true,
            hintText: '輸入社交帳號（例如 derrick01）',
            onValueChanged: (v) => setState(() => _account = v),
            onStatusChanged: (s, v) => setState(() {
              _accountStatus = s;
              _account = v;
            }),
          ),
        ],
      ),
    );
  }

  // ── Step 2：生日 ──
  Widget _buildStepBirthday() {
    final hasDate = _birthDate != null;
    final dateText = hasDate
        ? DateFormat('yyyy-MM-dd').format(_birthDate!)
        : '選擇你的生日';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '你的生日是？',
            style: TextStyle(
              color: Color(0xFF333333),
              fontSize: 22,
              fontFamily: 'PingFang TC',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '使用本服務需年滿 13 歲。生日不會公開顯示。',
            style: TextStyle(
              color: Color(0xFF838383),
              fontSize: 13,
              fontFamily: 'PingFang TC',
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: _pickBirthday,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cake_outlined,
                    size: 20,
                    color: Color(0xFF838383),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dateText,
                      style: TextStyle(
                        color: hasDate
                            ? const Color(0xFF333333)
                            : const Color(0xFFB0B0B0),
                        fontSize: 14,
                        fontFamily: 'PingFang TC',
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Color(0xFF838383),
                  ),
                ],
              ),
            ),
          ),
          if (_birthError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                _birthError!,
                style: const TextStyle(
                  color: Color(0xFFFF5858),
                  fontSize: 12,
                  fontFamily: 'PingFang TC',
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 開啟系統原生日期選擇器（iOS 風格 by adaptive on iOS, Material on Android）。
  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    // 預設上限：13 歲生日（鼓勵符合年齡限制）
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
      setState(() {
        _birthDate = picked;
        _birthError = null;
      });
    }
  }

  // ── Step 3：性別 / 國家 / 城市 ──
  Widget _buildStepOptional() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '介紹一下你自己',
            style: TextStyle(
              color: Color(0xFF333333),
              fontSize: 22,
              fontFamily: 'PingFang TC',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '這些資訊讓我們為你推薦更貼近的內容，也可以全部跳過。',
            style: TextStyle(
              color: Color(0xFF838383),
              fontSize: 13,
              fontFamily: 'PingFang TC',
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          _OptionalRow(
            label: '性別',
            value: _gender == null ? null : _genderOptions[_gender],
            placeholder: '請選擇',
            onTap: _pickGender,
          ),
          const SizedBox(height: 8),
          _OptionalRow(
            label: '國家／地區',
            value: _country == null ? null : countryName(_country),
            placeholder: '請選擇',
            onTap: _pickCountry,
          ),
          const SizedBox(height: 8),
          // 城市直接用文字輸入框
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Text(
                  '城市',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: '輸入城市（例如 Taipei）',
                      hintStyle: TextStyle(
                        color: Color(0xFFB0B0B0),
                        fontSize: 14,
                        fontFamily: 'PingFang TC',
                      ),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 14,
                      fontFamily: 'PingFang TC',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickGender() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _genderOptions.entries
              .map((e) => ListTile(
                    title: Text(e.value),
                    onTap: () => Navigator.pop(ctx, e.key),
                  ))
              .toList(),
        ),
      ),
    );
    if (picked != null) setState(() => _gender = picked);
  }

  Future<void> _pickCountry() async {
    final selected = await CountryPickerSheet.show(
      context,
      currentCode: _country,
    );
    if (selected != null) setState(() => _country = selected);
  }

  // ── 底部按鈕區 ──
  Widget _buildBottomBar() {
    final isLast = _currentStep == _totalSteps - 1;
    final canProceed = _submitting
        ? false
        : (_currentStep == 0
            ? _step1Valid
            : true /* step 2 在 _validateBirth 內檢查；step 3 一律允許 */);

    final primaryLabel = isLast ? '完成' : '下一步';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLast)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextButton(
                onPressed: _submitting ? null : _skipFinalStep,
                child: const Text(
                  '稍後再填',
                  style: TextStyle(
                    color: Color(0xFF838383),
                    fontSize: 14,
                    fontFamily: 'PingFang TC',
                  ),
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: canProceed ? _goNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C538A),
                disabledBackgroundColor: const Color(0xFFD1D1D1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      primaryLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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

/// Step 3 用：「label + 右側可選值 + 箭頭」的橫列 row
class _OptionalRow extends StatelessWidget {
  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  const _OptionalRow({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 14,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              value ?? placeholder,
              style: TextStyle(
                color: value == null
                    ? const Color(0xFFB0B0B0)
                    : const Color(0xFF333333),
                fontSize: 14,
                fontFamily: 'PingFang TC',
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFF838383)),
          ],
        ),
      ),
    );
  }
}

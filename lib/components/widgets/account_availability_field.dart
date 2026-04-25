import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../modules/account_setting/controller/accountSetting_controller.dart';

/// 帳號可用性檢查狀態
enum AccountCheckStatus {
  idle,        // 還沒打過 API（剛進頁、或內容跟原本相同）
  invalid,     // 本地格式驗證未通過（不會打 API）
  checking,    // debounce 後已送出請求，等待回應
  available,   // 可用 → 顯示綠色勾勾
  taken,       // 已被使用 → 顯示紅色錯誤訊息
  error,       // 網路錯誤等
}

/// 可重用的「社交帳號可用性檢查」輸入框。
///
/// 行為：
/// - 使用者打字 → debounce 500ms → 自動打 GET /users/me/check-account
/// - 右側即時顯示載入中圈圈 / 綠色勾勾（漸現）/ 紅色叉叉
/// - 透過 [onStatusChanged] 回報狀態給父頁面，父頁面用來決定「下一步/完成」按鈕是否可按
/// - 透過 [onValueChanged] 即時回報目前輸入的字串
///
/// 使用情境：
///   1) 帳號設定 > 編輯社交帳號（SocialAccountPage）
///   2) 第三方登入後的 onboarding 引導頁（OnboardingPage Step 1）
class AccountAvailabilityField extends StatefulWidget {
  final String? initialValue;
  final String hintText;
  final bool autofocus;

  /// 當輸入內容變動時呼叫（每次 key stroke 都會觸發）
  final ValueChanged<String>? onValueChanged;

  /// 當檢查狀態變動時呼叫（status, value）
  final void Function(AccountCheckStatus status, String value)? onStatusChanged;

  const AccountAvailabilityField({
    super.key,
    this.initialValue,
    this.hintText = '輸入您的社交帳號',
    this.autofocus = false,
    this.onValueChanged,
    this.onStatusChanged,
  });

  @override
  State<AccountAvailabilityField> createState() => _AccountAvailabilityFieldState();
}

class _AccountAvailabilityFieldState extends State<AccountAvailabilityField> {
  final AccountSettingController _controller = AccountSettingController();
  late final TextEditingController _textController;
  late final String _initialValue;

  AccountCheckStatus _status = AccountCheckStatus.idle;
  String? _takenReason;
  Timer? _debounce;
  int _requestSeq = 0;

  static const Duration _debounceDuration = Duration(milliseconds: 500);

  /// 帳號允許字元：小寫英文、數字、底線、點。長度 3~20。
  /// （與 IG/Twitter handle 規則對齊；若輸入大寫會被輸入 formatter 自動轉小寫）
  static final RegExp _validPattern = RegExp(r'^[a-z0-9._]+$');
  static const int _minLength = 3;
  static const int _maxLength = 20;

  /// 本地格式檢查；通過回傳 null，否則回傳錯誤訊息。
  String? _validateFormat(String value) {
    if (value.length < _minLength) {
      return '至少需要 $_minLength 個字元';
    }
    if (value.length > _maxLength) {
      return '最多 $_maxLength 個字元';
    }
    if (!_validPattern.hasMatch(value)) {
      return '只能使用小寫英文、數字、底線（_）和點（.）';
    }
    if (value.startsWith('.') || value.endsWith('.')) {
      return '不能以「.」開頭或結尾';
    }
    if (value.contains('..')) {
      return '不能包含連續的「..」';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _initialValue = (widget.initialValue ?? '').trim();
    _textController = TextEditingController(text: _initialValue);
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _emitStatus(AccountCheckStatus s) {
    setState(() => _status = s);
    widget.onStatusChanged?.call(s, _textController.text.trim());
  }

  void _onTextChanged() {
    final value = _textController.text.trim();
    widget.onValueChanged?.call(value);

    _debounce?.cancel();
    _requestSeq++;

    // 跟原本一樣 → idle
    if (value == _initialValue) {
      _takenReason = null;
      _emitStatus(AccountCheckStatus.idle);
      return;
    }

    // 空字串 → idle（父頁可決定是否允許）
    if (value.isEmpty) {
      _takenReason = null;
      _emitStatus(AccountCheckStatus.idle);
      return;
    }

    // 本地格式預驗證：不通過就不打 API，省成本也避免 server 回 400
    final formatErr = _validateFormat(value);
    if (formatErr != null) {
      setState(() => _takenReason = formatErr);
      _emitStatus(AccountCheckStatus.invalid);
      return;
    }

    _takenReason = null;
    _emitStatus(AccountCheckStatus.checking);

    _debounce = Timer(_debounceDuration, () => _runCheck(value));
  }

  Future<void> _runCheck(String account) async {
    final mySeq = ++_requestSeq;
    final result = await _controller.checkAccountAvailability(account);
    if (!mounted || mySeq != _requestSeq) return;

    if (result.containsKey('error')) {
      setState(() => _takenReason = '檢查失敗，請稍後重試');
      _emitStatus(AccountCheckStatus.error);
      return;
    }

    final available = result['available'] == true;
    setState(() => _takenReason = available ? null : (result['reason'] as String?));
    _emitStatus(available ? AccountCheckStatus.available : AccountCheckStatus.taken);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  autofocus: widget.autofocus,
                  maxLines: 1,
                  maxLength: _maxLength,
                  // 即時阻擋非法字元，並把大寫自動轉小寫，
                  // 使用者根本無法輸入錯誤格式
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(_maxLength),
                    _LowercaseTextFormatter(),
                    FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9._]')),
                  ],
                  keyboardType: TextInputType.visiblePassword, // 避免 iOS 自動大寫/校正
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.none,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 14,
                      fontFamily: 'PingFang TC',
                    ),
                    border: InputBorder.none,
                    counterText: '', // 隱藏 maxLength 計數器
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14,
                    fontFamily: 'PingFang TC',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusIndicator(),
            ],
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: (_status == AccountCheckStatus.taken ||
                  _status == AccountCheckStatus.error ||
                  _status == AccountCheckStatus.invalid)
              ? Padding(
                  key: ValueKey(_takenReason ?? 'msg'),
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    _takenReason ?? '此帳號已被使用',
                    style: const TextStyle(
                      color: Color(0xFFFF5858),
                      fontSize: 12,
                      fontFamily: 'PingFang TC',
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    Widget child;
    switch (_status) {
      case AccountCheckStatus.checking:
        child = const SizedBox(
          key: ValueKey('checking'),
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFB0B0B0),
          ),
        );
        break;
      case AccountCheckStatus.available:
        child = const Icon(
          Icons.check_circle,
          key: ValueKey('ok'),
          color: Color(0xFF22C55E),
          size: 22,
        );
        break;
      case AccountCheckStatus.taken:
      case AccountCheckStatus.error:
      case AccountCheckStatus.invalid:
        child = const Icon(
          Icons.cancel,
          key: ValueKey('bad'),
          color: Color(0xFFFF5858),
          size: 22,
        );
        break;
      case AccountCheckStatus.idle:
        child = const SizedBox(key: ValueKey('idle'), width: 22, height: 22);
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.6, end: 1.0).animate(animation),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// 自動把輸入的英文字母轉成小寫的 TextInputFormatter。
/// 用來確保帳號永遠是小寫格式。
class _LowercaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

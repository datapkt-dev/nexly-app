import 'package:flutter/material.dart';
import '../../../components/widgets/account_availability_field.dart';
import '../controller/accountSetting_controller.dart';

class SocialAccountPage extends StatefulWidget {
  final String? currentAccount;
  const SocialAccountPage({super.key, this.currentAccount});

  @override
  State<SocialAccountPage> createState() => _SocialAccountPageState();
}

class _SocialAccountPageState extends State<SocialAccountPage> {
  final AccountSettingController _controller = AccountSettingController();
  late final String _initialAccount;

  String _value = '';
  AccountCheckStatus _status = AccountCheckStatus.idle;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _initialAccount = (widget.currentAccount ?? '').trim();
    _value = _initialAccount;
  }

  bool get _canSave {
    if (_saving) return false;
    if (_value == _initialAccount) return false;
    if (_status == AccountCheckStatus.checking) return false;
    if (_status == AccountCheckStatus.taken) return false;
    if (_status == AccountCheckStatus.error) return false;
    // available 或（空字串=清除帳號）→ 可存
    return true;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final result = await _controller.editUser({'account': _value});
    if (!mounted) return;
    setState(() => _saving = false);
    if (result['message'] == 'User updated successfully') {
      Navigator.pop(context, _value);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('儲存失敗，請稍後再試'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          '編輯社交帳號',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 18,
            fontFamily: 'PingFang TC',
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _canSave ? _save : null,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    '完成',
                    style: TextStyle(
                      color: _canSave
                          ? const Color(0xFF333333)
                          : const Color(0xFFB0B0B0),
                      fontSize: 16,
                      fontFamily: 'PingFang TC',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '請輸入您的社交帳號名稱',
              style: TextStyle(
                color: Color(0xFF838383),
                fontSize: 13,
                fontFamily: 'PingFang TC',
              ),
            ),
            const SizedBox(height: 16),
            AccountAvailabilityField(
              initialValue: _initialAccount,
              autofocus: true,
              onValueChanged: (v) => setState(() => _value = v),
              onStatusChanged: (s, v) => setState(() {
                _status = s;
                _value = v;
              }),
            ),
          ],
        ),
      ),
    );
  }
}

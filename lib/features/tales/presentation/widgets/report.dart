// report_bottom_sheet.dart
import 'package:flutter/material.dart';

/// 檢舉結果資料（只在 BottomSheet 內部使用）
class ReportResult {
  ReportResult({
    required this.targetId,
    required this.targetType,
    required this.reason,
    this.note,
  });

  final int targetId;
  final ReportTarget targetType;
  final ReportReason reason;
  final String? note;
}

enum ReportTarget { tales, user }

enum ReportReason {
  hateOrViolence,
  sexualOrAdult,
  scamOrSpam,
  misinformation,
  selfHarm,
  illegalGoodsOrRestricted,
  intellectualProperty,
  other,
}

extension ReportReasonText on ReportReason {
  String get label => switch (this) {
    ReportReason.hateOrViolence => '霸凌、暴力歧視或仇恨',
    ReportReason.sexualOrAdult => '裸露或性行為',
    ReportReason.scamOrSpam => '詐騙、詐欺或垃圾訊息',
    ReportReason.misinformation => '不實資訊',
    ReportReason.selfHarm => '自殺、自殘',
    ReportReason.illegalGoodsOrRestricted => '販售或推廣管制商品',
    ReportReason.intellectualProperty => '智慧財產權',
    ReportReason.other => '其他',
  };
}

class ReportBottomSheet extends StatefulWidget {
  const ReportBottomSheet({
    super.key,
    required this.targetId,
    required this.targetType,
    required this.onSubmit,
    this.initialReason,
  });

  final int targetId;
  final ReportTarget targetType;
  final ReportReason? initialReason;

  /// ⭐ 由外部注入的送出行為（API）
  final Future<Map<String, dynamic>> Function(ReportResult result) onSubmit;

  /// ⭐【方案 3】唯一對外入口
  static Future<Map<String, dynamic>?> showAndSubmit(
      BuildContext context, {
        required int targetId,
        required ReportTarget targetType,
        required Future<Map<String, dynamic>> Function(ReportResult result) onSubmit,
        ReportReason? initialReason,
      }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportBottomSheet(
        targetId: targetId,
        targetType: targetType,
        initialReason: initialReason,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _noteCtrl = TextEditingController();

  ReportReason? _reason;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _reason = widget.initialReason;
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final result = ReportResult(
      targetId: widget.targetId,
      targetType: widget.targetType,
      reason: _reason!,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    try {
      final response = await widget.onSubmit(result);

      if (!mounted) return;
      Navigator.pop(context, response); // ⭐ 把 API 回傳值往外丟
    } catch (e) {
      setState(() => _submitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('送出失敗')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title =
    widget.targetType == ReportTarget.tales ? '檢舉此貼文' : '檢舉此用戶';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDADADA),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('您想檢舉什麼內容？'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<ReportReason>(
                        value: _reason,
                        decoration: InputDecoration(
                          hintText: '請選擇',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: InputBorder.none, // ← 移除預設下匡線
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        items: ReportReason.values
                            .map(
                              (r) => DropdownMenuItem(
                            value: r,
                            child: Text(r.label),
                          ),
                        )
                            .toList(),
                        onChanged: (v) => setState(() => _reason = v),
                        validator: (v) =>
                        v == null ? '請選擇檢舉原因' : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_reason == ReportReason.other)
                      TextFormField(
                        controller: _noteCtrl,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: '檢舉原因',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                        v == null || v.trim().isEmpty
                            ? '請填寫原因'
                            : null,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              GestureDetector(
                onTap: _submitting ? null : _submit,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C538A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _submitting
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    '確定',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

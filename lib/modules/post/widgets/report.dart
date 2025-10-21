// report_bottom_sheet.dart
import 'package:flutter/material.dart';

/// 回傳使用者選擇的檢舉資料
class ReportResult {
  ReportResult({required this.targetId, required this.targetType, required this.reason, this.note});
  final String targetId;          // 被檢舉對象 ID
  final ReportTarget targetType;  // 貼文 / 使用者
  final ReportReason reason;      // 檢舉主因
  final String? note;             // 其他補充/說明
}

enum ReportTarget { post, user }

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
    this.initialReason,
  });

  final String targetId;
  final ReportTarget targetType;
  final ReportReason? initialReason;

  static Future<ReportResult?> show(
      BuildContext context, {
        required String targetId,
        required ReportTarget targetType,
        ReportReason? initialReason,
      }) {
    return showModalBottomSheet<ReportResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReportBottomSheet(
        targetId: targetId,
        targetType: targetType,
        initialReason: initialReason,
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

    // 模擬等待 API。串真 API 時把這段移除，直接 pop 結果即可。
    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;
    Navigator.of(context).pop(ReportResult(
      targetId: widget.targetId,
      targetType: widget.targetType,
      reason: _reason!,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.targetType == ReportTarget.post ? '檢舉此貼文' : '檢舉此用戶';

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, -8)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              // 手把
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDADADA),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 12),
              // 標題
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF333333),
                  fontSize: 18,
                  fontFamily: 'PingFang TC',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // 內容表單
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '您想檢舉什麼內容？',
                      style: TextStyle(
                        color: const Color(0xFF333333),
                        fontSize: 16,
                        fontFamily: 'PingFang TC',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 下拉選單
                    Container(
                      // padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<ReportReason>(
                        value: _reason,
                        isExpanded: true,
                        decoration: InputDecoration(
                          hintText: '請選擇',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: InputBorder.none,      // ← 移除預設下匡線
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        items: ReportReason.values
                            .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r.label, style: const TextStyle(fontSize: 14)),
                        ))
                            .toList(),
                        onChanged: (v) => setState(() => _reason = v),
                        validator: (v) => v == null ? '請選擇檢舉原因' : null,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 只有選「其他」時顯示輸入框（可改為永遠顯示）
                    if (_reason == ReportReason.other) ...[
                      const Text(
                        '檢舉原因',
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 16,
                          fontFamily: 'PingFang TC',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              strokeAlign: BorderSide.strokeAlignCenter,
                              color: const Color(0xFFE7E7E7),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: TextFormField(
                          controller: _noteCtrl,
                          maxLines: 4,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            hintText: '檢舉原因',
                            hintStyle: const TextStyle(
                              color: Color(0xFFABABAB),
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) {
                            if (_reason == ReportReason.other && (v == null || v.trim().isEmpty)) {
                              return '請填寫原因';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),

              // 底部按鈕
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: OutlinedButton(
              //           onPressed: _submitting ? null : () => Navigator.pop(context),
              //           style: OutlinedButton.styleFrom(
              //             minimumSize: const Size.fromHeight(48),
              //             side: const BorderSide(color: Color(0xFFE5E5E5)),
              //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              //           ),
              //           child: const Text('取消', style: TextStyle(color: Color(0xFF333333))),
              //         ),
              //       ),
              //       const SizedBox(width: 12),
              //       Expanded(
              //         child: ElevatedButton(
              //           onPressed: _submitting ? null : _submit,
              //           style: ElevatedButton.styleFrom(
              //             minimumSize: const Size.fromHeight(48),
              //             backgroundColor: const Color(0xFF3B5AF8),
              //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              //             elevation: 0,
              //           ),
              //           child: _submitting
              //               ? const SizedBox(
              //               height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              //               : const Text('送出', style: TextStyle(color: Colors.white)),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

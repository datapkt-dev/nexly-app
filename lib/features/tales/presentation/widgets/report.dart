// report_bottom_sheet.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../app/config/app_config.dart';
import '../../../../unit/auth_service.dart';

// ── 資料模型 ──────────────────────────────────────────────

class ReportReasonItem {
  final int id;
  final String code;
  final String description;

  const ReportReasonItem({
    required this.id,
    required this.code,
    required this.description,
  });
}

class ReportResult {
  ReportResult({
    required this.targetId,
    required this.targetType,
    required this.reasonId,
    required this.reasonCode,
    this.note,
  });

  final int targetId;
  final ReportTarget targetType;
  final int reasonId;
  final String reasonCode;
  final String? note;
}

enum ReportTarget { tales, user, comment }

// ── BottomSheet ───────────────────────────────────────────

class ReportBottomSheet extends StatefulWidget {
  const ReportBottomSheet({
    super.key,
    required this.targetId,
    required this.targetType,
    required this.onSubmit,
  });

  final int targetId;
  final ReportTarget targetType;

  /// ⭐ 由外部注入的送出行為（API）
  final Future<Map<String, dynamic>> Function(ReportResult result) onSubmit;

  /// ⭐ 唯一對外入口
  static Future<Map<String, dynamic>?> showAndSubmit(
    BuildContext context, {
    required int targetId,
    required ReportTarget targetType,
    required Future<Map<String, dynamic>> Function(ReportResult result) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportBottomSheet(
        targetId: targetId,
        targetType: targetType,
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

  List<ReportReasonItem> _reasons = [];
  ReportReasonItem? _selected;
  bool _loadingReasons = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _fetchReasons();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchReasons() async {
    try {
      final type = widget.targetType.name; // tales / user / comment
      final url = Uri.parse('${AppConfig.baseURL}/report-reasons?type=$type');
      final token = await AuthService().getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final resp = await http.get(url, headers: headers);
      final data = jsonDecode(resp.body);
      final items = (data['data'] as List?)
              ?.map((e) => ReportReasonItem(
                    id: e['id'],
                    code: e['code'],
                    description: e['description'],
                  ))
              .toList() ??
          [];
      if (mounted) {
        setState(() {
          _reasons = items;
          _loadingReasons = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingReasons = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final result = ReportResult(
      targetId: widget.targetId,
      targetType: widget.targetType,
      reasonId: _selected!.id,
      reasonCode: _selected!.code,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    try {
      final response = await widget.onSubmit(result);
      if (!mounted) return;
      Navigator.pop(context, response);
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
    final isOther = _selected?.code == 'other';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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

              if (_loadingReasons)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                )
              else
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('您想檢舉什麼內容？'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: const Color(0xFFEEEEEE)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonFormField<ReportReasonItem>(
                          value: _selected,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          decoration: const InputDecoration(
                            hintText: '請選擇',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          items: _reasons
                              .map((r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(
                                      r.description,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selected = v),
                          validator: (v) =>
                              v == null ? '請選擇檢舉原因' : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (isOther)
                        TextFormField(
                          controller: _noteCtrl,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: '請填寫補充說明',
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
                onTap: (_submitting || _loadingReasons) ? null : _submit,
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

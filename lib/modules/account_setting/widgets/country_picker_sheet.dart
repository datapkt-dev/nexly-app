import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'country_data.dart';

/// 從 countriesnow.space 拉回的國家資料
class _Country {
  final String name;
  final String iso2;
  final String flag;

  const _Country({required this.name, required this.iso2, required this.flag});
}

class CountryPickerSheet extends StatefulWidget {
  final String? currentCode;

  const CountryPickerSheet({super.key, this.currentCode});

  /// 顯示國家選擇器，回傳選中的 iso2 國碼（例如 "TW"），取消回傳 null
  static Future<String?> show(BuildContext context, {String? currentCode}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CountryPickerSheet(currentCode: currentCode),
    );
  }

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  final TextEditingController _searchController = TextEditingController();

  List<_Country> _all = [];
  List<_Country> _filtered = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
    try {
      final res = await http
          .get(Uri.parse('https://countriesnow.space/api/v0.1/countries/flag/unicode'))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final List data = json['data'] as List;
        final countries = data.map((e) => _Country(
          name: e['name'] as String,
          iso2: e['iso2'] as String,
          flag: e['unicodeFlag'] as String,
        )).toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        setState(() {
          _all = countries;
          _filtered = countries;
          _loading = false;
        });
      } else {
        _fallback();
      }
    } catch (_) {
      _fallback();
    }
  }

  /// API 失敗時退回本地 countryCodeToName
  void _fallback() {
    final countries = countryCodeToName.entries.map((e) => _Country(
      name: e.value,
      iso2: e.key,
      flag: _iso2ToFlag(e.key),
    )).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    setState(() {
      _all = countries;
      _filtered = countries;
      _loading = false;
      _error = '無法連線，使用本地資料';
    });
  }

  /// ISO2 → Unicode 國旗 emoji
  String _iso2ToFlag(String iso2) {
    if (iso2.length != 2) return '';
    final base = 0x1F1E6 - 65; // 'A'.codeUnitAt(0) == 65
    final c1 = iso2.codeUnitAt(0);
    final c2 = iso2.codeUnitAt(1);
    return String.fromCharCodes([base + c1, base + c2]);
  }

  void _onSearch(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = _all;
      } else {
        _filtered = _all.where((c) =>
          c.name.toLowerCase().contains(q) ||
          c.iso2.toLowerCase().contains(q),
        ).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // ===== 標題列 =====
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Text(
                    '選擇國家/地區',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 18,
                      fontFamily: 'PingFang TC',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Color(0xFF838383)),
                  ),
                ],
              ),
            ),

            // ===== 搜尋欄 =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  decoration: const InputDecoration(
                    hintText: '搜尋國家名稱或代碼',
                    hintStyle: TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 14,
                      fontFamily: 'PingFang TC',
                    ),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Color(0xFFB0B0B0)),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14,
                    fontFamily: 'PingFang TC',
                  ),
                ),
              ),
            ),

            // ===== 錯誤提示 =====
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 12),
                ),
              ),

            // ===== 國家列表 =====
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final c = _filtered[index];
                        final isSelected = c.iso2 == widget.currentCode;
                        return ListTile(
                          leading: Text(
                            c.flag,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(
                            c.name,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF2C538A)
                                  : const Color(0xFF333333),
                              fontSize: 15,
                              fontFamily: 'PingFang TC',
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check, color: Color(0xFF2C538A))
                              : Text(
                                  c.iso2,
                                  style: const TextStyle(
                                    color: Color(0xFFB0B0B0),
                                    fontSize: 12,
                                    fontFamily: 'PingFang TC',
                                  ),
                                ),
                          // 回傳 iso2 給後台
                          onTap: () => Navigator.pop(context, c.iso2),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

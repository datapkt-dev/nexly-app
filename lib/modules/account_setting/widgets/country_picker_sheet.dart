import 'package:flutter/material.dart';
import 'country_data.dart';

class CountryPickerSheet extends StatefulWidget {
  final String? currentCode;

  const CountryPickerSheet({super.key, this.currentCode});

  /// 顯示國家選擇器，回傳選中的國碼（例如 "TW"），取消回傳 null
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
  List<MapEntry<String, String>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = countryCodeToName.entries.toList();
  }

  void _onSearch(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = countryCodeToName.entries.toList();
      } else {
        _filtered = countryCodeToName.entries.where((e) {
          return e.value.toLowerCase().contains(q) ||
              e.key.toLowerCase().contains(q);
        }).toList();
      }
    });
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
            // ===== 國家列表 =====
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final entry = _filtered[index];
                  final isSelected = entry.key == widget.currentCode;
                  return ListTile(
                    title: Text(
                      entry.value,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF2C538A)
                            : const Color(0xFF333333),
                        fontSize: 15,
                        fontFamily: 'PingFang TC',
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Color(0xFF2C538A))
                        : null,
                    onTap: () => Navigator.pop(context, entry.key),
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

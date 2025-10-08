import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n.dart';
import '../../models/locale.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool light = true;

  void _showPicker(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(top: false, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeModel = context.watch<LocaleModel>();
    // 1) 先決定「有效的目前語系」
    final effectiveLocale = localeModel.locale ?? Localizations.localeOf(context);
    // 2) 由目前語系映射到 picker index（安全、不會 -1）
    final selectedIndex = L10n.indexOfLocale(effectiveLocale);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        title: Text(AppLocalizations.of(context)!.setting),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          color: const Color(0xFFF2F2F2),
          child: Column(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: 8,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x3FC9C9C9),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFB3B3B3), width: 1)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                        child: Text(
                          AppLocalizations.of(context)!.setting,
                          style: const TextStyle(
                            color: Color(0xFF171717),
                            fontSize: 12,
                            fontFamily: 'Noto Sans TC',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showPicker(
                            CupertinoPicker(
                              magnification: 1.22,
                              squeeze: 1.2,
                              useMagnifier: true,
                              itemExtent: 32.0,
                              // 用安全的 selectedIndex
                              scrollController: FixedExtentScrollController(initialItem: selectedIndex),
                              onSelectedItemChanged: (int i) {
                                // 先更新 Provider 的語系
                                localeModel.setLocale(L10n.all[i]);
                                // 再 setState 觸發重建（若你需要即時更新右側顯示文字）
                                setState(() {});
                              },
                              children: List<Widget>.generate(
                                L10n.languages.length,
                                    (int i) => Center(child: Text(L10n.languages[i])),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Border(bottom: BorderSide(color: Color(0xFFB3B3B3), width: 1)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.language,
                                style: const TextStyle(
                                  color: Color(0xFF171717),
                                  fontSize: 16,
                                  fontFamily: 'Noto Sans TC',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  // 右側顯示當前選擇（用 selectedIndex，而不是成員變數）
                                  Text(
                                    L10n.languages[selectedIndex],
                                    style: const TextStyle(
                                      color: Color(0xFF6D6D6D),
                                      fontSize: 16,
                                      fontFamily: 'Noto Sans TC',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: 5,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x3FC9C9C9),
                        blurRadius: 4,
                        offset: Offset(0, -4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

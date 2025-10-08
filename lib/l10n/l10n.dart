// l10n/l10n.dart
import 'package:flutter/material.dart';

class L10n {
  // 你自己的清單，順序要和顯示名稱一一對應
  static const all = <Locale>[
    Locale('en'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
  ];

  // 用於 UI 顯示的語言名稱（與上面順序對應）
  static const languages = <String>[
    'English',
    '繁體中文（台灣）',
  ];

  // 根據 Locale 找 index（完整比對），找不到回 0
  static int indexOfLocale(Locale loc) {
    final i = all.indexWhere((e) =>
    e.languageCode == loc.languageCode &&
        (e.scriptCode ?? '') == (loc.scriptCode ?? '') &&
        (e.countryCode ?? '') == (loc.countryCode ?? ''));
    return i == -1 ? 0 : i;
  }
}

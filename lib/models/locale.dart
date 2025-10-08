import 'package:flutter/cupertino.dart';
import '../l10n/l10n.dart';


class LocaleModel with ChangeNotifier {
  // 預設語言為我們在 L10n 類別中定義的首位
  Locale _locale = L10n.all.first;
  Locale get locale => _locale;

  // 設定語系的方法
  void setLocale(Locale l) {
    if (!L10n.all.contains(l)) {
      return;
    }
    // 更改值
    _locale = l;
    // 同時也通知監聽的對象
    notifyListeners();
  }
}
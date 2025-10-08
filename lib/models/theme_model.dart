import 'package:flutter/material.dart';

class ThemeModel with ChangeNotifier {
  ThemeData _themeData;

  ThemeModel(this._themeData);

  ThemeData get themeData => _themeData;

  void toggleTheme() {
    if (_themeData == ThemeData.light()) {
      _themeData = ThemeData.dark();
    } else {
      _themeData = ThemeData.light();
    }
    notifyListeners();
  }
}
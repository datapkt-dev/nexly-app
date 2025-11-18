import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  static const int _maxDigits = 8; // YYYYMMDD

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final oldText = oldValue.text;
    final newText = newValue.text;

    final bool isDeleting = newText.length < oldText.length;

    // 取出純數字
    String oldDigits = _digitsOnly(oldText);
    String newDigits = _digitsOnly(newText);

    // 游標位置（文字座標）
    final int oldCursor =
    oldValue.selection.baseOffset.clamp(0, oldText.length);
    int newCursor =
    newValue.selection.baseOffset.clamp(0, newText.length);

    // 新文字中，游標前面有幾個「數字」（忽略 -）
    int digitsBeforeCursor =
    _countDigits(newText.substring(0, newCursor));

    // 情境：剛好在 '-' 後面按退格，系統只刪掉 '-'，數字沒少
    final bool backspaceOnDash = isDeleting &&
        oldCursor > 0 &&
        oldCursor <= oldText.length &&
        oldText[oldCursor - 1] == '-' &&
        newDigits == oldDigits;

    if (backspaceOnDash) {
      // 舊文字中，該 '-' 前面有幾個數字（可能是 4 或 6）
      final int digitsBeforeDash =
      _countDigits(oldText.substring(0, oldCursor - 1));
      if (digitsBeforeDash > 0 && digitsBeforeDash <= oldDigits.length) {
        // 主動把 '-' 左邊那個數字也刪掉
        newDigits = oldDigits.substring(0, digitsBeforeDash - 1) +
            oldDigits.substring(digitsBeforeDash);
        // 刪掉一個數字後，數字游標也往前一格
        digitsBeforeCursor = digitsBeforeDash - 1;
      }
    } else {
      // 一般情況：避免越界
      if (digitsBeforeCursor > newDigits.length) {
        digitsBeforeCursor = newDigits.length;
      }
    }

    // 最多 8 碼
    if (newDigits.length > _maxDigits) {
      newDigits = newDigits.substring(0, _maxDigits);
      if (digitsBeforeCursor > newDigits.length) {
        digitsBeforeCursor = newDigits.length;
      }
    }

    // 重新格式化成 YYYY-MM-DD
    final String formatted = _formatYYYYMMDD(newDigits);

    // 依照「數字游標」回推在格式化字串中的視覺游標位置
    final int visualCursor =
    _visualOffsetFromDigits(formatted, digitsBeforeCursor);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: visualCursor),
    );
  }

  // Helpers

  String _digitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');

  int _countDigits(String s) =>
      RegExp(r'\d').allMatches(s).length;

  String _formatYYYYMMDD(String digits) {
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buf.write(digits[i]);
      if (i == 3 || i == 5) buf.write('-'); // 4th、6th 後插入 -
    }
    final out = buf.toString();
    return out.length > 10 ? out.substring(0, 10) : out;
  }

  int _visualOffsetFromDigits(String formatted, int digitsBefore) {
    int idx = 0;
    int seen = 0;
    while (idx < formatted.length && seen < digitsBefore) {
      if (_isDigit(formatted.codeUnitAt(idx))) {
        seen++;
      }
      idx++;
    }
    return idx;
  }

  bool _isDigit(int codeUnit) =>
      codeUnit >= 48 && codeUnit <= 57; // '0'..'9'
}

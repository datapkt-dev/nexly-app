/// 統一的「使用者顯示名稱」取得邏輯。
///
/// 業界規則（對齊 IG / Threads / X）：
/// - 社交帳號（account / handle）才是「身份識別」，顯示優先；
///   若 account 為空，再 fallback 到 name（暱稱）；都沒有就回空字串。
///
/// 若想反過來（先 name 再 account），用 [displayNameOrAccount]。
String displayAccountOrName(dynamic account, dynamic name) {
  final a = (account ?? '').toString().trim();
  if (a.isNotEmpty) return a;
  final n = (name ?? '').toString().trim();
  return n;
}

/// 先顯示暱稱（name），name 為空才用社交帳號（account）。
/// 用於 Profile 頁面標題等「以暱稱為主」的場景。
String displayNameOrAccount(dynamic name, dynamic account) {
  final n = (name ?? '').toString().trim();
  if (n.isNotEmpty) return n;
  final a = (account ?? '').toString().trim();
  return a;
}

/// 從 user-like map 直接取顯示名（account 優先）。
/// 支援多種常見鍵名（user_account / account, user_name / name）。
String displayFromUserMap(Map? m) {
  if (m == null) return '';
  return displayAccountOrName(
    m['user_account'] ?? m['account'],
    m['user_name'] ?? m['name'],
  );
}

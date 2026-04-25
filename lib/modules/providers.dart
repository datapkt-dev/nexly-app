import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../unit/auth_service.dart';
import 'account_setting/controller/accountSetting_controller.dart';

/// ───────────────────────────────────────────────────────────────────────────
/// 全 App 共用的「使用者資料」單一來源（single source of truth）。
///
/// 設計目標：
/// 1) 任何頁面只要 `ref.watch(userProvider)` 即可即時拿到最新使用者資料。
/// 2) 任何頁面更新使用者資料（編輯、上傳頭像）只需呼叫
///    `ref.read(userProvider.notifier).merge(patch)`，全 App 自動同步。
/// 3) Stale-while-revalidate：開 App 時先用 secure storage 中的快取秒開畫面，
///    再背景 fetch /me 拿最新資料。
/// 4) 登出時 `clear()` 一次清空。
///
/// 維持 state 型別為 `Map<String, dynamic>`（空 Map = 未登入），
/// 與既有讀取端 `userProfileProvider` 完全相容。
/// ───────────────────────────────────────────────────────────────────────────
class UserNotifier extends StateNotifier<Map<String, dynamic>> {
  UserNotifier(this._auth, this._controller) : super(const {});

  final AuthService _auth;
  final AccountSettingController _controller;

  bool _refreshing = false;

  /// 從 secure storage 讀回快取（登入時 `saveProfile` 寫入），
  /// 接著背景刷新 /me。即使刷新失敗也不影響 UI。
  Future<void> bootstrap() async {
    final cached = await _auth.getProfile();
    if (cached != null) {
      state = Map<String, dynamic>.from(cached);
    }
    // 不 await，背景刷新
    refreshFromServer();
  }

  /// 從後端 /users/{id} 拿最新資料並寫回 storage。
  /// 同時呼叫多個地方時用 `_refreshing` 去重，避免重複打 API。
  Future<Map<String, dynamic>?> refreshFromServer() async {
    if (_refreshing) return null;
    _refreshing = true;
    try {
      var id = state['id'];
      if (id == null) {
        final cached = await _auth.getProfile();
        id = cached?['id'];
      }
      if (id == null) return null;

      final res = await _controller.getUserProfile(id as int);
      final raw = res['data'];
      if (raw == null) return null;

      final Map<String, dynamic> userData = (raw is Map && raw['user'] is Map)
          ? {
              ...Map<String, dynamic>.from(raw),
              ...Map<String, dynamic>.from(raw['user'] as Map),
            }
          : Map<String, dynamic>.from(raw as Map);

      // ⚠️ 重要：用 merge（而非覆蓋）合併。
      // 因為 GET /users/{id} 是「公開個人資料」端點，為了隱私
      // 通常不會回傳 account / email / phone 等私密欄位。
      // 若直接 `state = userData` 會把登入時 saveProfile 的私密欄位清空，
      // 導致 AccountSetting 看不到社交帳號（顯示「-」）。
      final merged = {...state, ...userData};
      state = merged;
      await _auth.saveProfile(merged);
      return merged;
    } catch (_) {
      return null;
    } finally {
      _refreshing = false;
    }
  }

  /// 部分更新並持久化（編輯資料、上傳頭像、社交帳號變更後使用）。
  Future<void> merge(Map<String, dynamic> patch) async {
    state = {...state, ...patch};
    await _auth.saveProfile(state);
  }

  /// 直接覆寫（登入完成、第三方登入回傳完整 user 時使用）。
  Future<void> setUser(Map<String, dynamic> user) async {
    state = Map<String, dynamic>.from(user);
    await _auth.saveProfile(state);
  }

  /// 登出時清空。注意：secure storage 的清除由 `AuthService.logout()` 負責，
  /// 這裡只負責記憶體中的 state。
  void clear() {
    state = const {};
  }
}

final userProvider =
    StateNotifierProvider<UserNotifier, Map<String, dynamic>>((ref) {
  return UserNotifier(AuthService(), AccountSettingController());
});

/// 向下相容的別名：原本各頁面使用 `userProfileProvider` 的讀取程式碼
/// 可以維持不變（`ref.watch(userProfileProvider)` 仍會拿到 Map）。
/// 寫入端則應改用 `ref.read(userProvider.notifier).xxx()`。
final userProfileProvider = userProvider;

/// 未讀通知數量（用於底部導航欄鈴鐺紅點/紅數字）
final unreadNotificationCountProvider = StateProvider<int>((ref) => 0);

/// 發文上傳進度狀態
class UploadProgressState {
  final bool isUploading;
  final double progress; // 0.0 ~ 1.0
  final String? thumbnailPath; // 縮圖路徑

  const UploadProgressState({
    this.isUploading = false,
    this.progress = 0.0,
    this.thumbnailPath,
  });

  UploadProgressState copyWith({
    bool? isUploading,
    double? progress,
    String? thumbnailPath,
  }) {
    return UploadProgressState(
      isUploading: isUploading ?? this.isUploading,
      progress: progress ?? this.progress,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }
}

final uploadProgressProvider =
    StateNotifierProvider<UploadProgressNotifier, UploadProgressState>(
  (ref) => UploadProgressNotifier(),
);

class UploadProgressNotifier extends StateNotifier<UploadProgressState> {
  UploadProgressNotifier() : super(const UploadProgressState());

  /// 開始上傳（設定縮圖、重置進度）
  void start({String? thumbnailPath}) {
    state = UploadProgressState(
      isUploading: true,
      progress: 0.0,
      thumbnailPath: thumbnailPath,
    );
  }

  /// 更新進度 (0.0 ~ 1.0)
  void updateProgress(double progress) {
    state = state.copyWith(progress: progress.clamp(0.0, 1.0));
  }

  /// 上傳完成
  void complete() {
    state = const UploadProgressState(isUploading: false, progress: 1.0);
  }

  /// 重置
  void reset() {
    state = const UploadProgressState();
  }
}


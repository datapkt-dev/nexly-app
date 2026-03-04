import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProfileProvider = StateProvider<Map<String, dynamic>>((ref) => {});

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


import 'package:flutter/widgets.dart';

/// 通知文案多國語言字典。
///
/// 使用後端傳的 `i18n_key`（如 `notification.comment.received`）+ `i18n_params`
/// 動態組合本地化文字。若找不到對應 key，退回後端傳來的 fallback（`content`）。
///
/// 支援語系：en / zh / ja
/// 若未來要新增語言，只要在 [_dict] 加一份對應 locale code 的 map 即可。
class NotificationI18n {
  NotificationI18n._();

  /// [locale] 取 `languageCode`（`en` / `zh` / `ja`）。
  /// [key] 後端傳的 `i18n_key`，如 `notification.comment.received`。
  /// [params] 後端傳的 `i18n_params`，如 `{actor_name: 'Derrick', tale_title: '...'}`。
  /// [fallback] 後端原始的英文 `content`，查不到 key 時使用。
  static String translate({
    required Locale locale,
    required String? key,
    Map<String, dynamic>? params,
    String? fallback,
  }) {
    final lang = _resolveLang(locale);
    String? template;

    if (key != null && key.isNotEmpty) {
      template = _dict[lang]?[key] ?? _dict['en']?[key];
    }

    // 查不到 → 用後端 fallback（content）
    template ??= fallback ?? '';
    return _interpolate(template, params ?? const {});
  }

  static String _resolveLang(Locale locale) {
    final code = locale.languageCode.toLowerCase();
    if (code == 'zh') return 'zh';
    if (code == 'ja') return 'ja';
    return 'en';
  }

  /// 將 `{actor_name}` 這類 placeholder 以 params 值替換。
  /// 找不到的 placeholder 維持原樣輸出。
  static String _interpolate(String template, Map<String, dynamic> params) {
    if (template.isEmpty || params.isEmpty) return template;
    return template.replaceAllMapped(
      RegExp(r'\{(\w+)\}'),
      (m) {
        final name = m.group(1)!;
        final value = params[name];
        return value?.toString() ?? m.group(0)!;
      },
    );
  }

  // ======================================================================
  //  字典：key 與後端定義完全一致（dot-notation）
  // ======================================================================
  static const Map<String, Map<String, String>> _dict = {
    // ---------------- English ----------------
    'en': {
      'notification.follow.received': '{actor_name} started following you',
      'notification.tale_like.received': '{actor_name} liked your post "{tale_title}"',
      'notification.comment_like.received': '{actor_name} liked your comment',
      'notification.comment.received': '{actor_name} commented on your post "{tale_title}"',
      'notification.reply.received': '{actor_name} replied to your comment',
      'notification.mention.received': '{actor_name} mentioned you',
      'notification.cotales_invite.received': '{actor_name} invited you to a co-tale',
      'notification.cotales_join_accepted.received': '{actor_name} accepted your join request',
      'notification.cotales_join_rejected.received': '{actor_name} declined your join request',
      'notification.cotales_new_tales.received': '{actor_name} added a new post "{tale_title}" to your co-tale',
      'notification.tales_share.received': '{actor_name} shared your post "{tale_title}"',
      'notification.system.received': 'System notification',
      'notification.admin.received': 'Announcement from admin',
      'notification.default.received': 'You have a new notification',
    },

    // ---------------- 繁體中文 ----------------
    'zh': {
      'notification.follow.received': '{actor_name} 開始追蹤你',
      'notification.tale_like.received': '{actor_name} 喜歡了你的貼文「{tale_title}」',
      'notification.comment_like.received': '{actor_name} 喜歡了你的留言',
      'notification.comment.received': '{actor_name} 在你的貼文「{tale_title}」上留言',
      'notification.reply.received': '{actor_name} 回覆了你的留言',
      'notification.mention.received': '{actor_name} 在留言中提到你',
      'notification.cotales_invite.received': '{actor_name} 邀請你加入協作',
      'notification.cotales_join_accepted.received': '{actor_name} 同意了你的加入邀請',
      'notification.cotales_join_rejected.received': '{actor_name} 拒絕了你的加入邀請',
      'notification.cotales_new_tales.received': '{actor_name} 在協作中新增了貼文「{tale_title}」',
      'notification.tales_share.received': '{actor_name} 分享了你的貼文「{tale_title}」',
      'notification.system.received': '系統通知',
      'notification.admin.received': '管理員公告',
      'notification.default.received': '你有一則新通知',
    },

    // ---------------- 日本語 ----------------
    'ja': {
      'notification.follow.received': '{actor_name}さんがあなたをフォローしました',
      'notification.tale_like.received': '{actor_name}さんがあなたの投稿「{tale_title}」にいいねしました',
      'notification.comment_like.received': '{actor_name}さんがあなたのコメントにいいねしました',
      'notification.comment.received': '{actor_name}さんがあなたの投稿「{tale_title}」にコメントしました',
      'notification.reply.received': '{actor_name}さんがあなたのコメントに返信しました',
      'notification.mention.received': '{actor_name}さんがあなたをメンションしました',
      'notification.cotales_invite.received': '{actor_name}さんがコラボに招待しました',
      'notification.cotales_join_accepted.received': '{actor_name}さんが参加リクエストを承認しました',
      'notification.cotales_join_rejected.received': '{actor_name}さんが参加リクエストを拒否しました',
      'notification.cotales_new_tales.received': '{actor_name}さんがコラボに新しい投稿「{tale_title}」を追加しました',
      'notification.tales_share.received': '{actor_name}さんがあなたの投稿「{tale_title}」をシェアしました',
      'notification.system.received': 'システム通知',
      'notification.admin.received': '管理者からのお知らせ',
      'notification.default.received': '新しい通知があります',
    },
  };
}

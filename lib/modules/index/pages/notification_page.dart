import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../features/notifications/notification_i18n.dart';
import '../../../features/tales/presentation/pages/tale_detail_page.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../controller/notification_controller.dart';
import '../widgets/NotificationItemShimmer.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  final NotificationController notificationController = NotificationController();

  List? notifications;

  bool _isAdminNotification(Map item) {
    return item['i18n_key'] == 'notification.admin.received' ||
        item['type'] == 'admin';
  }

  String _notificationText(BuildContext context, Map item) {
    if (_isAdminNotification(item)) {
      return (item['content'] ?? item['title'] ?? '').toString();
    }
    return NotificationI18n.translate(
      locale: Localizations.localeOf(context),
      key: item['i18n_key'] as String?,
      params: (item['i18n_params'] is Map)
          ? Map<String, dynamic>.from(item['i18n_params'] as Map)
          : null,
      fallback: item['content'] as String?,
    );
  }

  void _showAdminNotificationDetail(Map item) {
    final title = (item['title'] ?? '公告').toString().trim();
    final content = (item['content'] ?? '').toString().trim();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDADADA),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title.isEmpty ? '公告' : title,
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 18,
                          fontFamily: 'PingFang TC',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  content.isEmpty ? '（無內容）' : content,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadData() async {
    final result = await notificationController.getNotifications();
    if (!mounted) return;
    setState(() {
      notifications = result['data']?['items'];
    });
  }

  Future<void> _readOne(int id) async {
    await notificationController.postReadOne(id);
    await _refreshUnreadCount();
  }

  Future<void> _refreshUnreadCount() async {
    final count = await notificationController.getUnreadCount();
    ref.read(unreadNotificationCountProvider.notifier).state = count;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SafeArea(
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: false,
            title: Text(
              '通知',
              style: TextStyle(
                color: const Color(0xFF333333),
                fontSize: 20,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _loadData();
                await _refreshUnreadCount();
              },
              child: notifications == null
                  ? const NotificationItemShimmer()
                  : notifications!.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 120),
                            Center(
                              child: Column(
                                children: [
                                  const Icon(Icons.notifications_none, size: 48, color: Color(0xFFD9D9D9)),
                                  const SizedBox(height: 12),
                                  Text(t.no_notifications, style: const TextStyle(color: Color(0xFF838383), fontSize: 16)),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: notifications!.length,
                          itemBuilder: (context, index) {
                            final item = notifications![index];
                            final timeText = item['time_added']?.substring(0, 16).replaceFirst('T', ' ');
                            final String? taleImageUrl = item['related_tales_image_url'];
                            final hasTaleImage = taleImageUrl != null && taleImageUrl.isNotEmpty;

                            return InkWell(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                decoration: BoxDecoration(
                                  color: item['is_read'] == true
                                      ? Colors.transparent
                                      : const Color(0xFFF46C3F).withValues(alpha: 0.06),
                                ),
                                child: Row(
                                  children: [
                                    // 左側頭像
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: ShapeDecoration(
                                        image: DecorationImage(
                                          image: AssetImage('assets/images/ChatGPTphoto.png'),
                                          fit: BoxFit.cover,
                                        ),
                                        shape: OvalBorder(
                                          side: BorderSide(
                                            width: 2,
                                            color: const Color(0xFFE7E7E7),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // 中間文字
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _notificationText(context, item),
                                            style: const TextStyle(
                                              color: Color(0xFF333333),
                                              fontSize: 14,
                                              fontFamily: 'PingFang TC',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            timeText ?? '',
                                            style: const TextStyle(
                                              color: Color(0xFF838383),
                                              fontSize: 12,
                                              fontFamily: 'PingFang TC',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // 右側：文章縮圖
                                    if (hasTaleImage)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image(
                                          image: CachedNetworkImageProvider(taleImageUrl),
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                          gaplessPlayback: true,
                                          errorBuilder: (_, __, ___) => const SizedBox(width: 44, height: 44),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                await _readOne(item['id']);
                                if (!mounted) return;
                                setState(() {
                                  item['is_read'] = true;
                                });

                                if (_isAdminNotification(item)) {
                                  _showAdminNotificationDetail(item);
                                  return;
                                }

                                final taleId = item['related_tales_id'];
                                final commentId = item['related_comment_id'];
                                if (taleId != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Post(
                                        id: taleId,
                                        openCommentId: commentId,
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

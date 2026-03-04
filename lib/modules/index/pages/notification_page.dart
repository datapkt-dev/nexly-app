import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../features/tales/presentation/pages/tale_detail_page.dart';
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

  Future<void> _loadData() async {
    final result = await notificationController.getNotifications();
    if (!mounted) return;
    setState(() {
      notifications = result['data']?['items'];
    });
  }

  void _readAll() async {
    await notificationController.postReadAll();
    // ✅ 後端只清數字，前端手動把所有通知標為已讀（清紅點 + 淺色背景）
    setState(() {
      if (notifications != null) {
        for (final n in notifications!) {
          n['is_read'] = true;
        }
      }
    });
    _refreshUnreadCount();
  }

  void _readOne(id) async {
    await notificationController.postReadOne(id);
    _refreshUnreadCount();
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
            actions: [
              TextButton(
                onPressed: _readAll,
                child: Text(
                  '全部已讀',
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 16,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
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
                          children: const [
                            SizedBox(height: 120),
                            Center(
                              child: Column(
                                children: [
                                  Icon(Icons.notifications_none, size: 48, color: Color(0xFFD9D9D9)),
                                  SizedBox(height: 12),
                                  Text('目前沒有通知', style: TextStyle(color: Color(0xFF838383), fontSize: 16)),
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
                                            item['content'],
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
                              onTap: () {
                                _readOne(item['id']);
                                setState(() {
                                  item['is_read'] = true;
                                });

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

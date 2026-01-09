import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nexly/modules/account_setting/account_setting.dart';
import 'package:nexly/modules/cooperation/cooperation.dart';
import 'package:nexly/modules/progress/progress.dart';
import '../../../components/widgets/LabeledProgressBar.dart';
import '../../../l10n/app_localizations.dart';
import '../../../features/tales/presentation/pages/tale_detail_page.dart';
import '../../app/config/app_config.dart';
import '../../features/tales/presentation/widgets/report.dart';
import '../../unit/auth_service.dart';
import '../follow_list/follow_list.dart';
import '../index/widgets/collaboration_settings_sheet.dart';
import '../payment/widgets/NoticeBlock.dart';
import 'controller/profile_controller.dart';

class Profile extends ConsumerStatefulWidget {
  final bool isSelf;
  final int userId;

  const Profile.self({super.key, required this.userId})
      : isSelf = true;

  const Profile.other({super.key, required this.userId,})
      : isSelf = false;

  @override
  ConsumerState<Profile> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<Profile> {
  final ProfileController profileController = ProfileController();

  final ScrollController _scrollController = ScrollController();
  List items = [];
  int page = 1;
  bool isLoading = false;
  bool hasMore = true; // API 還有沒有下一頁

  late Future<Map<String, dynamic>> futureUser;
  late Future<void> futureData;

  bool? _isFollowing;
  int selectedIndex = 0;

  final List<String> img = [
    'assets/images/landscape/dog.jpg',
    'assets/images/landscape/egypt.jpg',
    'assets/images/landscape/goingup.jpg',
    'assets/images/landscape/hiking.jpg',
    'assets/images/postImg.png',
  ];

  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    final result = await _fetchData(
      index: selectedIndex,
      page: page,
    );

    // 假設未來三者都會回傳這種格式
    final List newItems;
    if (selectedIndex == 0) {
      newItems = result['data']['items'] ?? [];
    } else if (selectedIndex == 2) {
      newItems = result['data']['favorites'] ?? [];
    } else if (selectedIndex == 1) {
      newItems = result['data']['cotales'] ?? [];
    } else {
      newItems = [];
    }
    setState(() {
      page += 1;
      isLoading = false;
      items.addAll(newItems);
      if (newItems.isEmpty) {
        hasMore = false;
      }
    });
  }

  Future<Map<String, dynamic>> _fetchData({required int index, required int page,}) {
    switch (index) {
      case 0:
        return profileController.getUserTales(widget.userId, page);
      case 1:
        return profileController.getCoTales(widget.userId, page);
      case 2:
        return profileController.getFavorites(widget.userId, page);
      default:
        throw Exception('Unknown index');
    }
  }

  Future<void> _reloadData() async {
    setState(() {
      page = 1;
      hasMore = true;
      isLoading = false;
      items.clear();
    });

    await loadMore();
  }

  void onTabChanged(int index) {
    if (selectedIndex == index) return;

    setState(() {
      selectedIndex = index;
    });

    futureData = _reloadData();
  }

  @override
  void initState() {
    super.initState();
    futureUser = profileController.getProfile(widget.userId);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        loadMore();
      }
    });

    futureData = _reloadData();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    // final info = [
    //   t.tale,
    //   t.follower,
    //   t.following,
    //   t.trusted_circle,
    // ];
    final info = [
      '貼文',
      '粉絲',
      '追蹤中',
      '朋友圈',
    ];

    // final category = [
    //   t.tale,
    //   t.cooperation,
    //   t.collection,
    // ];
    final category = [
      '貼文',
      '協作',
      '收藏',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: widget.isSelf ? const SizedBox.shrink() : null,
        actions: [
          widget.isSelf
              ? _buildSelfMenu(context)
              : _buildOtherUserMenu(context),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FutureBuilder(
                  future: futureUser,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          '發生錯誤: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      );
                    }
                    final account = snapshot.data!['data'];
                    _isFollowing ??= account['is_following'] ?? false;
                    return _buildHeader(context, account, info, category);
                  },
                ),
              ),
              const SizedBox(height: 10),
              _buildCategoryTabs(category),
              const SizedBox(height: 10),
              FutureBuilder(
                future: futureData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        '發生錯誤: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    );
                  }
                  return _buildContent();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= Header =================

  Widget _buildHeader(
      BuildContext context,
      Map account,
      List<String> info,
      List<String> category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserRow(account),
        const SizedBox(height: 10),
        _buildInfoRow(info, account),
        const SizedBox(height: 20),
        _buildBio(account['bio']??'-'),
        const SizedBox(height: 20),
        _buildProgressCard(context, account['id']),
      ],
    );
  }

  Widget _buildUserRow(Map account) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: ShapeDecoration(
            image: DecorationImage(
              image: NetworkImage(account['avatar_url']),
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
        SizedBox(width: 10,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${account['name']}',
              style: TextStyle(
                color: const Color(0xFF333333),
                fontSize: 16,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${account['account']}',
              style: TextStyle(
                color: const Color(0xFF838383),
                fontSize: 14,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (!widget.isSelf) _buildFollowButton(account['id']),
      ],
    );
  }

  Widget _buildFollowButton(int id) {
    final following = _isFollowing ?? false;
    return InkWell(
      child: Container(
        width: 80,
        height: 32,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFE7E7E7)),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text('追蹤${following? '中' : ''}'),
      ),
      onTap: () {
        setState(() {
          _isFollowing = !following;
        });
        profileController.postFollow(id);
      },
    );
  }


  Widget _buildInfoRow(List<String> info, Map account) {
    final count = [account['tales_count'], account['followers_count'], account['following_count'], 0];
    return Wrap(
      spacing: 10,
      children: List.generate(info.length, (index) {
        final isClickable = index == 1 || index == 2;
        return InkWell(
          onTap: isClickable
              ? () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FollowList(userId: account['id'], userName: account['name'], act: index-1,)),
            ).then((result) {
              setState(() {
                futureUser = profileController.getProfile(widget.userId);
              });
            });
          }
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${count[index]}',
                style: TextStyle(
                  color: const Color(0xFF333333),
                  fontSize: 14,
                  fontFamily: 'PingFang TC',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 4,),
              Text(
                info[index],
                style: TextStyle(
                  color: const Color(0xFF333333),
                  fontSize: 14,
                  fontFamily: 'PingFang TC',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBio(String bio) {
    return Text(
      bio,
      style: TextStyle(
        color: const Color(0xFF333333),
        fontSize: 14,
        fontFamily: 'PingFang TC',
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, userId) {
    final t = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Progress(userId: userId,)),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.03, 0.97),
            end: Alignment(1.00, 0.05),
            colors: [const Color(0xFF2C538A), const Color(0xFF24B7BD)],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  t.progress,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.white,
                ),
              ],
            ),
            SizedBox(height: 13,),
            Row(
              children: [
                Text(
                  t.personal,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 10,),
                Text(
                  '10/42',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: LabeledProgressBar(percent: 0.5),
                ),
                SizedBox(width: 16,),
                Text(
                  '50%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'PingFangTC',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 13,),
            Row(
              children: [
                Text(
                  t.group,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 10,),
                Text(
                  '10/42',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: LabeledProgressBar(percent: 0.25),
                ),
                SizedBox(width: 16,),
                Text(
                  '25%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'PingFangTC',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(List<String> category) {
    return Container(
      width: double.infinity,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(2),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(99),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 4,
            offset: Offset(0, 0),
            spreadRadius: 0,
          )
        ],
      ),
      child: Row(
        children: List.generate(category.length, (index) {
          return Expanded(
            child: GestureDetector(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: ShapeDecoration(
                  color: selectedIndex == index ? const Color(0xFFF46C3F) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                child: Text(
                  category[index],
                  style: TextStyle(
                    color: selectedIndex == index ? Colors.white : const Color(0xFF333333),
                    fontSize: 14,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              onTap: () => onTabChanged(index),
            ),
          );
        }),
      ),
    );
  }

  // ================= Content =================

  Widget _buildContent() {
    if (selectedIndex == 1) return _buildCooperation();
    return _buildPostGrid();
  }

  Widget _buildPostGrid() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        mainAxisExtent: 171,
      ),
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Post(myself: selectedIndex==0, id: item['${selectedIndex==0 ? '' : 'tales_'}id'],), //按照是否為自己的貼文提供狀態
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(item['image_url']),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCooperation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: 162,
        ),
        itemCount: widget.isSelf ? items.length+1 : items.length,
        itemBuilder: (_, index) {
          if (widget.isSelf && index == 0) {
            return _buildAddFolderCard();
          }
          return _buildCooperationItem();
        },
      ),
    );
  }

  Widget _buildAddFolderCard() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const CollaborationSettingsSheet(),
          ),
          child: Container(
            height: 115,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: const Color(0x1924B7BD),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: Color(0xFF2C538A),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 30,),
                Icon(Icons.add),
                SizedBox(height: 4,),
                Text(
                  '新增資料夾',
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 14,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
        Spacer(),
      ],
    );
  }

  Widget _buildCooperationItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          child: Container(
            height: 115,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(img[3]), // ✅ 用 AssetImage
                          fit: BoxFit.cover,
                        ),
                        color: Color(0xFFE7E7E7),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(img[1]), // ✅ 用 AssetImage
                                fit: BoxFit.cover,
                              ),
                              color: Color(0xFFE7E7E7),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(img[2]), // ✅ 用 AssetImage
                                fit: BoxFit.cover,
                              ),
                              color: Color(0xFFE7E7E7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Cooperation()),
            );
          },
        ),
        SizedBox(height: 4,),
        Row(
          children: [
            Text(
              '協作資料夾名稱',
              style: TextStyle(
                color: const Color(0xFF333333),
                fontSize: 14,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w400,
              ),
            ),
            Spacer(),
          ],
        ),
        SizedBox(height: 1.5,),
        Text(
          '3 Tales • 5 參與者',
          style: TextStyle(
            color: const Color(0xFF898989),
            fontSize: 12,
            fontFamily: 'PingFang TC',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ================= Menus =================

  Widget _buildSelfMenu(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert),
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      shape: RoundedRectangleBorder(                 // 圓角 + 邊框
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEDEDED)),
      ),
      color: Colors.white,
      elevation: 8,
      constraints: const BoxConstraints(minWidth: 180),
      itemBuilder: (_) => const [
        PopupMenuItem(value: 0, child: Text('帳號設定')),
      ],
      onSelected: (_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AccountSetting()),
        ).then((result) {
          setState(() {
            futureUser = profileController.getProfile(widget.userId);
          });
        });
      },
    );
  }

  Widget _buildOtherUserMenu(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert),
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),                    // 往下偏移一點
      shape: RoundedRectangleBorder(                 // 圓角 + 邊框
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEDEDED)),
      ),
      color: Colors.white,
      elevation: 8,
      constraints: const BoxConstraints(minWidth: 180), // 控制寬度（可調）
      onSelected: (value) async {
        switch (value) {
          case 0:
            final result = await ReportBottomSheet.show(
              context,
              targetId: 'post_123',
              targetType: ReportTarget.user, // 或 ReportTarget.user
            );
            break;
          case 1:
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent, // 讓我們自訂圓角容器
              builder: (ctx) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 16,),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      // 小手把
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
                      const SizedBox(height: 22),

                      // 標題列 + 關閉
                      Align(
                        alignment: AlignmentGeometry.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      NoticeBlock(
                        title: '封鎖後此用戶將無法',
                        items: [
                          '查看你個人頁面及已發布的tales',
                          '解除你們彼此的追蹤關係',
                          '從彼此所屬的co-tales中移除',
                          '無法邀請你至co-tales',
                          '分享訊息給你',
                        ],
                      ),
                      SizedBox(height: 20,),
                      GestureDetector(
                        child: Container(
                          width: double.infinity,
                          height: 40,
                          padding: const EdgeInsets.all(10),
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF2C538A),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          child: Text(
                            '確定',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'PingFang TC',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        onTap: () async {
                          Navigator.pop(context); // 關閉選單
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('已封鎖'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 30,),
                    ],
                  ),
                );// 自訂內容（見下）;
              },
            );
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Text('檢舉此用戶'),
        ),
        PopupMenuItem(
          value: 1,
          child: Text('封鎖此用戶'),
        ),
      ],
    );
  }
}

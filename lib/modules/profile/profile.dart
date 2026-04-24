import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nexly/modules/account_setting/account_setting.dart';
import 'package:nexly/modules/cooperation/cooperation.dart';
import 'package:nexly/modules/profile/widgets/ProfileTaleShimmer.dart';
import 'package:nexly/modules/profile/widgets/ProfileUserShimmer.dart';
import 'package:nexly/modules/progress/progress.dart';
import '../../../components/widgets/LabeledProgressBar.dart';
import '../../../l10n/app_localizations.dart';
import '../../../features/tales/presentation/pages/tale_detail_page.dart';
import '../../features/tales/presentation/widgets/report.dart';
import '../account_setting/controller/accountSetting_controller.dart';
import '../follow_list/follow_list.dart';
import '../index/widgets/collaboration_settings_sheet.dart';
import '../payment/widgets/NoticeBlock.dart';
import '../providers.dart';
import 'controller/profile_controller.dart';

class Profile extends ConsumerStatefulWidget {
  final int userId;

  const Profile({super.key, required this.userId});

  @override
  ConsumerState<Profile> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<Profile> {
  bool myself = false;

  final ProfileController profileController = ProfileController();

  final ScrollController _scrollController = ScrollController();
  List items = [];
  int page = 1;
  bool isLoading = false;
  bool hasMore = true; // API 還有沒有下一頁
  bool isPrivate = false; // 對方隱私設定關閉

  late Future<Map<String, dynamic>> futureUser;
  late Future<Map<String, dynamic>> futureAchievement;
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

    // 隱私設定關閉時，API 回傳 code 40300000
    if (result['code'] == 40300000) {
      setState(() {
        isLoading = false;
        hasMore = false;
        isPrivate = true;
      });
      return;
    }

    // 假設未來三者都會回傳這種格式
    final List newItems;
    if (selectedIndex == 0) {
      newItems = result['data']['items'] ?? [];
    } else if (selectedIndex == 1) {
      newItems = result['data']['favorites'] ?? [];
    } else {
      newItems = [];
    }

    // ✅ 預載所有圖片，完成後再一次顯示
    if (newItems.isNotEmpty && mounted) {
      await Future.wait(
        newItems
            .where((item) => item['image_url'] != null && item['image_url'].toString().isNotEmpty)
            .map((item) => _precacheImage(item['image_url']))
            .toList(),
      );
    }

    if (!mounted) return;

    setState(() {
      page += 1;
      isLoading = false;
      items.addAll(newItems);
      if (newItems.isEmpty) {
        hasMore = false;
      }
    });
  }

  Future<void> _precacheImage(String url) async {
    try {
      await precacheImage(CachedNetworkImageProvider(url), context);
    } catch (_) {}
  }

  Future<Map<String, dynamic>> _fetchData({required int index, required int page,}) {
    switch (index) {
      case 0:
        return profileController.getUserTales(widget.userId, page);
      // case: cooperation 暫時隱藏
      case 1:
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
      isPrivate = false;
      items.clear();
    });

    await loadMore();
  }

  Future<void> _onRefreshProfile() async {
    setState(() {
      futureUser = profileController.getProfile(widget.userId);
      futureAchievement = profileController.getAchievement(widget.userId);
      _isFollowing = null;
    });
    await _reloadData();
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
    final userData = ref.read(userProfileProvider);
    if (userData['id'] == widget.userId) myself = true;

    futureUser = profileController.getProfile(widget.userId);
    futureAchievement = profileController.getAchievement(widget.userId);
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

    final info = [
      t.tale,
      t.follower,
      t.following,
      t.trusted_circle,
    ];

    final category = [
      t.tale,
      // t.cooperation,
      t.collection,
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: myself ? const SizedBox.shrink() : null,
        actions: [
          myself
              ? _buildSelfMenu(context)
              : _buildOtherUserMenu(context, widget.userId),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefreshProfile,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FutureBuilder(
                  future: futureUser,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ProfileUserShimmer();
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          '發生錯誤: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      );
                    }
                    if (snapshot.data == null || snapshot.data!['data'] == null) {
                      return ProfileUserShimmer();
                    }
                    final raw = snapshot.data!['data'] as Map;
                    // 相容兩種 API 回傳格式：
                    //   1) { data: { name, avatar_url, ... } }
                    //   2) { data: { user: { name, avatar_url, ... }, ... } }
                    final account = (raw['user'] is Map)
                        ? {...raw, ...(raw['user'] as Map)}
                        : raw;
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
                    return ProfileTaleShimmer();
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
        FutureBuilder(
          future: futureAchievement,
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
            return _buildProgressCard(context, account['id'], snapshot.data!['data']);
          },
        ),
      ],
    );
  }

  Widget _buildUserRow(Map account) {
    return Row(
      children: [
        ClipOval(
          child: Image(
            image: CachedNetworkImageProvider(account['avatar_url'] ?? ''),
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => Container(
              width: 60,
              height: 60,
              color: const Color(0xFFE7E7E7),
              child: const Icon(Icons.person, color: Colors.grey),
            ),
          ),
        ),
        SizedBox(width: 10,),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${account['name']}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF333333),
                  fontSize: 16,
                  fontFamily: 'PingFang TC',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${account['account']}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF838383),
                  fontSize: 14,
                  fontFamily: 'PingFang TC',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        if (!myself) _buildFollowButton(account['id']),
      ],
    );
  }

  Widget _buildFollowButton(int id) {
    final following = _isFollowing ?? false;
    return InkWell(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 80,
        height: 32,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: following ? Colors.transparent : const Color(0xFFF46C3F),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: following ? const Color(0xFFE7E7E7) : const Color(0xFFF46C3F),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(
            color: following ? const Color(0xFF333333) : Colors.white,
            fontSize: 14,
            fontFamily: 'PingFang TC',
            fontWeight: FontWeight.w500,
          ),
          child: Text('追蹤${following ? '中' : ''}'),
        ),
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        final willFollow = !following;
        setState(() {
          _isFollowing = willFollow;
        });
        profileController.postFollow(id);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              willFollow ? '已追蹤' : '已取消追蹤',
              textAlign: TextAlign.center,
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
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

  bool _bioExpanded = false;

  Widget _buildBio(String bio) {
    const int maxLength = 200;
    final bool needsTruncate = bio.length > maxLength && !_bioExpanded;
    final String displayText = needsTruncate
        ? bio.substring(0, maxLength)
        : bio;

    return GestureDetector(
      onTap: bio.length > maxLength
          ? () => setState(() => _bioExpanded = !_bioExpanded)
          : null,
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 14,
            fontFamily: 'PingFang TC',
            fontWeight: FontWeight.w400,
          ),
          children: [
            TextSpan(text: displayText),
            if (needsTruncate)
              const TextSpan(
                text: '…more',
                style: TextStyle(
                  color: Color(0xFF838383),
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, userId, Map<String, dynamic> achievement) {
    final t = AppLocalizations.of(context)!;

    final int personalDone = achievement['personal_tales']['completed'] ?? 0;
    final int personalTotal = achievement['personal_tales']['total'] ?? 0;
    final double personalPercent = personalTotal == 0 ? 0.0 : personalDone / personalTotal;

    final int groupDone = achievement['co_tales']['completed'] ?? 0;
    final int groupTotal = achievement['co_tales']['total'] ?? 0;
    final double groupPercent = groupTotal == 0 ? 0.0 : groupDone / groupTotal;

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
                  '$personalDone/$personalTotal',
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
                  child: LabeledProgressBar(percent: personalPercent),
                ),
                SizedBox(width: 16,),
                Text(
                  '${(personalPercent * 100).toInt()}%',
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
                  '$groupDone/$groupTotal',
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
                  child: LabeledProgressBar(percent: groupPercent),
                ),
                SizedBox(width: 16,),
                Text(
                  '${(groupPercent * 100).toInt()}%',
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
    final tabCount = category.length;
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
        shadows: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 4,
            offset: Offset(0, 0),
            spreadRadius: 0,
          )
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / tabCount;
          return Stack(
            children: [
              // ===== 橘色滑塊 =====
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: selectedIndex * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF46C3F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
              // ===== 文字標籤 =====
              Row(
                children: List.generate(tabCount, (index) {
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTabChanged(index),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: TextStyle(
                            color: selectedIndex == index
                                ? Colors.white
                                : const Color(0xFF333333),
                            fontSize: 14,
                            fontFamily: 'PingFang TC',
                            fontWeight: FontWeight.w500,
                          ),
                          child: Text(category[index]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= Content =================

  Widget _buildContent() {
    if (isPrivate) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.lock_outline, size: 48, color: Color(0xFFB0B0B0)),
              SizedBox(height: 12),
              Text(
                '此內容為私人',
                style: TextStyle(
                  color: Color(0xFF838383),
                  fontSize: 16,
                  fontFamily: 'PingFang TC',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return _buildPostGrid();
  }

  Widget _buildPostGrid() {
    // ✅ 首次載入或切 tab 載入中：顯示 shimmer 佔位
    if (items.isEmpty && isLoading) {
      return _buildGridShimmer();
    }

    if (items.isEmpty && !hasMore) {
      final t = AppLocalizations.of(context)!;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            t.no_tales,
            style: const TextStyle(color: Color(0xFF838383), fontSize: 14),
          ),
        ),
      );
    }

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
        final itemId = item['${selectedIndex == 0 ? '' : 'tales_'}id'];
        final heroTag = 'profile-$selectedIndex-tale-image-$itemId';
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Post(
                id: itemId,
                previewData: item,
                heroTag: heroTag,
              ),
            ),
          ).then((result) {
            if (result == 'refresh') {
              futureUser = profileController.getProfile(widget.userId);
              futureAchievement = profileController.getAchievement(widget.userId);
              futureData = _reloadData();
            }
          }),
          child: Hero(
            tag: heroTag,
            child: ClipRect(
              child: Image(
                image: CachedNetworkImageProvider(item['image_url'] ?? ''),
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFE7E7E7),
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 載入中的 shimmer 佔位格
  Widget _buildGridShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
          mainAxisExtent: 171,
        ),
        itemCount: 9,
        itemBuilder: (_, __) => Container(color: Colors.grey),
      ),
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
        itemCount: myself ? items.length+1 : items.length,
        itemBuilder: (_, index) {
          if (myself && index == 0) {
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

  Widget _buildOtherUserMenu(BuildContext context, int userId) {
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
            final result = await ReportBottomSheet.showAndSubmit(
              context,
              targetId: userId,
              targetType: ReportTarget.user,
              onSubmit: (report) async {
                final controller = AccountSettingController();
                return await controller.postReport(
                  report.targetType.name,
                  report.targetId,
                  report.reasonId,
                  reasonDetail: report.note,
                );
              },
            );
            if (result?['message'] == 'Report submitted successfully') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已送出檢舉')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${result?['message']}')),
              );
            }
            break;
          case 1:
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
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
                          final accountSettingController = AccountSettingController();
                          final result = await accountSettingController.postBlock(userId);
                          if (result['message'] == 'Blocked successfully') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('已封鎖'),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('發生錯誤'),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 30,),
                    ],
                  ),
                );
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

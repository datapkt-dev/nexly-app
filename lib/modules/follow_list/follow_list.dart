import 'package:flutter/material.dart';

import '../../unit/auth_service.dart';
import 'controller/followed_controller.dart';

class FollowList extends StatefulWidget {
  final int userId;
  final String userName;
  final int act;
  const FollowList({super.key, required this.userId, required this.userName, this.act = 0});

  @override
  State<FollowList> createState() => _FollowedState();
}

class _FollowedState extends State<FollowList> {
  final AuthService authStorage = AuthService();
  final FollowedController followedController = FollowedController();
  Future<Map<String, dynamic>> futureData = Future.value({});

  int selectedIndex = 0;
  final List<String> category = [' 粉絲', ' 追蹤',];
  bool followed = true;

  late String? userName;
  late final List<List> lists;
  List<dynamic> followingList = [];
  List<dynamic> followerList = [];

  Future<Map<String, dynamic>> _loadData(int id) async {
    print('load');
    // 兩個請求併發，提高速度
    final f1 = followedController.getFollowingList(id);
    final f2 = followedController.getFollowerList(id);
    final results = await Future.wait([f1, f2]);

    final followings  = results[0];
    // followingList = following['data']['items'];

    final followers = results[1];
    // followerList = follower['data']['items'];

    setState(() {
      followerList
        ..clear()
        ..addAll(followers['data']['items']);
      followingList
        ..clear()
        ..addAll(followings['data']['items']);
      // lists 會自動反映兩個來源的最新內容
    });

    return {
      'followings' : followings['data']?['user'],
      'followers' : followers['data']?['user'],
      // 'blacklist': List<Map<String, dynamic>>.from(blackRes['data']?['items'] ?? []),
    };
  }

  @override
  void initState() {
    super.initState();
    userName = widget.userName;
    lists = [followerList, followingList];
    futureData = _loadData(widget.userId);
    selectedIndex = widget.act;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        // leading: SizedBox.shrink(),
        title: Text(
          '$userName',
          style: TextStyle(
            color: const Color(0xFF333333),
            fontSize: 18,
            fontFamily: 'PingFang TC',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16,),
              child: Container(
                width: double.infinity,
                height: 32,
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
                            '${lists[index].length}${category[index]}',
                            style: TextStyle(
                              color: selectedIndex == index ? Colors.white : const Color(0xFF333333),
                              fontSize: 14,
                              fontFamily: 'PingFang TC',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            setState(() {
                              selectedIndex = index;
                            });
                          });
                        },
                      ),
                    );
                  }),
                ),
              ),
            ),
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
                return Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    itemCount: lists[selectedIndex].length,
                    separatorBuilder: (_, __) => SizedBox.shrink(),
                    itemBuilder: (_, i) {
                      return Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 9),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Container(
                                //   width: 40,
                                //   height: 40,
                                //   decoration: BoxDecoration(
                                //     shape: BoxShape.circle,
                                //     border: Border.all(color: const Color(0xFFE7E7E7)),
                                //   ),
                                //   child: SvgPicture.asset('assets/images/avatar_1.svg'),
                                // ),
                                Container(
                                  width: 40,
                                  height: 40,
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${lists[selectedIndex][i]['name']}',
                                      style: TextStyle(
                                        color: Color(0xFF333333),
                                        fontSize: 14,
                                        fontFamily: 'PingFang TC',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 4,),
                                    Text(
                                      '${lists[selectedIndex][i]['email']}',
                                      style: TextStyle(
                                        color: Color(0xFF898989),
                                        fontSize: 12,
                                        fontFamily: 'PingFang TC',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            child: Container(
                              width: 88,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: followed
                                  ? ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: const Color(0xFFD9E0E3),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ) : ShapeDecoration(
                                color: const Color(0xFF2C538A),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              child: Text(
                                '${followed ? '取消' : ''}追蹤',
                                style: TextStyle(
                                  color: followed ? const Color(0xFF333333) : Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'PingFang TC',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                followed = !followed;
                              });
                            },
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

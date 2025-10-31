import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nexly/modules/cooperation/cooperation.dart';
import 'package:nexly/modules/profile/profile.dart';
import 'package:nexly/modules/progress/progress.dart';
import 'package:nexly/modules/setting/setting.dart';
import '../../../components/widgets/LabeledProgressBar.dart';
import '../../../l10n/app_localizations.dart';
import '../../followed/followed.dart';
import '../../post/post.dart';
import '../widgets/collaboration_settings_sheet.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  int selectedIndex = 0;
  final List<String> img = [
    'assets/images/landscape/dog.jpg',
    'assets/images/landscape/egypt.jpg',
    'assets/images/landscape/goingup.jpg',
    'assets/images/landscape/hiking.jpg',
    'assets/images/postImg.png',
  ];
  bool light = true;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final info = <String>[
      t.tale,            // 你 ARB 需要有 "tale"
      t.follower,       // 建議補 "followers"
      t.following,       // 建議補 "following"
      t.trusted_circle,   // 建議補 "trustedCircle"
    ];

    final category = <String>[
      t.tale,        // 建議補 "talesTab"
      t.cooperation,    // 建議補 "cooperateTab"
      t.collection,    // 建議補 "favoritesTab"
    ];

    return SafeArea(
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            scrolledUnderElevation: 0,
            leading: SizedBox.shrink(),
            actions: [
              PopupMenuButton<int>(
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
                onSelected: (value) {
                  switch (value) {
                    case 0: // 帳號設定
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Profile()),
                      );
                      break;
                    // case 1: // 前往語言設定
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => const Setting()),
                    //   );
                    //   break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 0,
                    child: Text('帳號設定'),
                  ),
                  // PopupMenuItem(
                  //   value: 1,
                  //   child: Text('語言設定'),
                  // ),
                ],
              )

              // IconButton(
              //   onPressed: () {},
              //   icon: Icon(Icons.more_vert),
              // ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Container(
                            //   width: 60,
                            //   height: 60,
                            //   // decoration: ShapeDecoration(
                            //   //   // image: DecorationImage(
                            //   //   //   image: NetworkImage("https://placehold.co/60x60"),
                            //   //   //   fit: BoxFit.cover,
                            //   //   // ),
                            //   //   shape: OvalBorder(
                            //   //     side: BorderSide(
                            //   //       width: 1,
                            //   //       color: const Color(0xFFE7E7E7),
                            //   //     ),
                            //   //   ),
                            //   // ),
                            //   child: SvgPicture.asset('assets/images/avatar_1.svg'),
                            // ),
                            Container(
                              width: 60,
                              height: 60,
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
                            SizedBox(width: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sam',
                                  style: TextStyle(
                                    color: const Color(0xFF333333),
                                    fontSize: 16,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'sam9527',
                                  style: TextStyle(
                                    color: const Color(0xFF838383),
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Wrap(
                          spacing: 10,
                          children: List.generate(info.length, (index) {
                            final isClickable = index == 1 || index == 2;
                            return InkWell(
                              onTap: isClickable
                                  ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Followed()),
                                );
                              }
                                  : null,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '100',
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
                        ),
                        SizedBox(height: 20,),
                        Text(
                          '個人簡介寫在這裡，個人簡介寫在這裡個人簡介寫在這裡，個人簡介寫在這裡',
                          style: TextStyle(
                            color: const Color(0xFF333333),
                            fontSize: 14,
                            fontFamily: 'PingFang TC',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 20,),
                        GestureDetector(
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Progress()),
                            );
                          },
                        ),
                        SizedBox(height: 10,),
                        Container(
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
                                      category[index],
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
                        SizedBox(height: 10,),
                      ],
                    ),
                  ),
                  _buildContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (selectedIndex) {
      case 1:
        return cooperation();
      default:
        return GridView.builder(
          padding: const EdgeInsets.all(0),
          shrinkWrap: true, // 高度隨內容變化
          physics: NeverScrollableScrollPhysics(), // 交給外層滾動
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,     // 一列 2 個
            crossAxisSpacing: 1,   // 左右間距
            mainAxisSpacing: 1,   // 上下間距
            mainAxisExtent: 171,   // ✅ 固定每個 item 的高度 (250 圖片 + 文字空間)
          ),
          itemCount: 7, // 資料數量
          itemBuilder: (context, index) {
            // final post = posts[index]; // 換成你的資料
            return GestureDetector(
              child: Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(img[index%5]), // ✅ 用 AssetImage
                    fit: BoxFit.cover,
                  ),
                  color: Color(0xFFE7E7E7),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Post(myself: true,)),
                );
              },
            );
          },
        );
    }
  }

  Widget cooperation() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        padding: const EdgeInsets.all(0),
        shrinkWrap: true, // 高度隨內容變化
        physics: NeverScrollableScrollPhysics(), // 交給外層滾動
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,     // 一列 2 個
          crossAxisSpacing: 10,   // 左右間距
          mainAxisSpacing: 10,   // 上下間距
          mainAxisExtent: 162,   // ✅ 固定每個 item 的高度 (250 圖片 + 文字空間)
        ),
        itemCount: 4, // 資料數量
        itemBuilder: (context, index) {
          // final post = posts[index]; // 換成你的資料
          if (index == 0) {
            return Column(
              children: [
                GestureDetector(
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
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => const CollaborationSettingsSheet(),
                    );
                  },
                ),
                Spacer(),
              ],
            );
          } else {
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
                      MaterialPageRoute(builder: (context) => const Cooperation(myself: true,)),
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
                )
              ],
            );
          }
        },
      ),
    );
  }
}

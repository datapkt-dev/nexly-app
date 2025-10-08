import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nexly_temp/modules/setting/setting.dart';
import 'package:provider/provider.dart';
import '../../../components/widgets/LabeledProgressBar.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/l10n.dart';
import '../../../models/locale.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  List<String> info = [/*'Tales', '粉絲', '追蹤中', 'Trusted Circle'*/];
  List<String> category = [/*'Tales', '協作', '收藏'*/];
  final List<String> img = [
    'assets/images/landscape/dog.jpg',
    'assets/images/landscape/egypt.jpg',
    'assets/images/landscape/goingup.jpg',
    'assets/images/landscape/hiking.jpg',
    'assets/images/postImg.png',
  ];

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
            leading: SizedBox.shrink(),
            actions: [
              PopupMenuButton<int>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 0: // 前往設定/編輯
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Setting()),
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 0,
                    child: Text('語言設定'),
                  ),
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
                            Container(
                              width: 60,
                              height: 60,
                              // decoration: ShapeDecoration(
                              //   // image: DecorationImage(
                              //   //   image: NetworkImage("https://placehold.co/60x60"),
                              //   //   fit: BoxFit.cover,
                              //   // ),
                              //   shape: OvalBorder(
                              //     side: BorderSide(
                              //       width: 1,
                              //       color: const Color(0xFFE7E7E7),
                              //     ),
                              //   ),
                              // ),
                              child: SvgPicture.asset('assets/images/avatar_1.svg'),
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
                            return Row(
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
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    t.progress,
                                    style: TextStyle(
                                      color: const Color(0xFF333333),
                                      fontSize: 16,
                                      fontFamily: 'PingFang TC',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(Icons.keyboard_arrow_right),
                                ],
                              ),
                              SizedBox(height: 13,),
                              Row(
                                children: [
                                  Text(
                                    t.personal,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFF333333),
                                      fontSize: 14,
                                      fontFamily: 'PingFang TC',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Text(
                                    '10/42',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFF333333),
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
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFF333333),
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
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFF333333),
                                      fontSize: 14,
                                      fontFamily: 'PingFang TC',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Text(
                                    '10/42',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFF333333),
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
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFF333333),
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
                        Row(
                          children: List.generate(category.length, (index) {
                            return Expanded(
                              child: Container(
                                padding: EdgeInsets.only(top: 18,),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      category[index],
                                      style: const TextStyle(
                                        color: Color(0xFF241172),
                                        fontSize: 14,
                                        fontFamily: 'PingFang TC',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      height: 2,
                                      width: 40, // 這裡你可以改成固定長度 或 動態依文字寬度
                                      color: const Color(0xFF241172),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 1,),
                      ],
                    ),
                  ),
                  GridView.builder(
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
                        onTap: () {},
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

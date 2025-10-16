import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nexly_temp/modules/setting/setting.dart';
import '../../../components/widgets/LabeledProgressBar.dart';
import '../../../l10n/app_localizations.dart';

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
              onTap: () {},
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
                      isScrollControlled: true,           // 解除預設高度限制
                      backgroundColor: Colors.transparent, // 讓我們自訂圓角容器
                      builder: (ctx) {
                        return FractionallySizedBox(
                          heightFactor: 0.9, // 90% 螢幕高度
                          child: Container(
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
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: SizedBox.shrink()),
                                    Text(
                                      '協作設定',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(0xFF333333),
                                        fontSize: 18,
                                        fontFamily: 'PingFang TC',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            child: Text(
                                              '完成',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: const Color(0xFF333333),
                                                fontSize: 16,
                                                fontFamily: 'PingFang TC',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: const Color(0xFFEEEEEE),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextField(
                                    // controller: controller,
                                    maxLines: 1,
                                    decoration: const InputDecoration(
                                      hintText: '輸入資料夾名稱',
                                      hintStyle: TextStyle(
                                        color: Color(0xFFB0B0B0),
                                        fontSize: 16,
                                        fontFamily: 'PingFang TC',
                                        fontWeight: FontWeight.w400,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(
                                      color: const Color(0xFF333333),
                                      fontSize: 16,
                                      fontFamily: 'PingFang TC',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20,),
                                Text(
                                  '協作隱私權限',
                                  style: TextStyle(
                                    color: const Color(0xFF333333),
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '公開',
                                      style: TextStyle(
                                        color: const Color(0xFF333333),
                                        fontSize: 14,
                                        fontFamily: 'PingFang TC',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Spacer(),
                                    Switch(
                                      // This bool value toggles the switch.
                                      value: light,
                                      activeColor: Color(0xFFE9416C),
                                      onChanged: (bool value) {
                                        // This is called when the user toggles the switch.
                                        setState(() {
                                          light = value;
                                        });
                                      },
                                    )
                                  ],
                                ),
                                SizedBox(height: 20,),
                                Container(
                                  width: double.infinity,
                                  height: 46,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFEEEEEE),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.search,
                                        size: 18,
                                        color: Color(0xFFABABAB),
                                      ),
                                      Expanded(
                                        child: TextField(
                                          // controller: controller,
                                          maxLines: 1,
                                          decoration: const InputDecoration(
                                            hintText: '好友帳號、名稱',
                                            hintStyle: TextStyle(
                                              color: Color(0xFFB0B0B0),
                                              fontSize: 16,
                                              fontFamily: 'PingFang TC',
                                              fontWeight: FontWeight.w400,
                                            ),
                                            border: InputBorder.none,
                                          ),
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
                                ),
                                // 可滾動內容
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: List.generate(10, (index) {
                                        return Container(
                                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10,),
                                          padding: EdgeInsets.symmetric(vertical: 4),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: ShapeDecoration(
                                                  // image: DecorationImage(
                                                  //   image: NetworkImage("https://placehold.co/60x60"),
                                                  //   fit: BoxFit.cover,
                                                  // ),
                                                  shape: OvalBorder(
                                                    side: BorderSide(
                                                      width: 1,
                                                      color: const Color(0xFFE7E7E7),
                                                    ),
                                                  ),
                                                ),
                                                child: SvgPicture.asset('assets/images/avatar_1.svg'),
                                              ),
                                              SizedBox(width: 8,),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'jane',
                                                    style: TextStyle(
                                                      color: const Color(0xFF333333),
                                                      fontSize: 14,
                                                      fontFamily: 'PingFang TC',
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    'jane05171921',
                                                    style: TextStyle(
                                                      color: const Color(0xFF898989),
                                                      fontSize: 12,
                                                      fontFamily: 'PingFang TC',
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Spacer(),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    '已加入',
                                                    style: TextStyle(
                                                      color: const Color(0xFF333333),
                                                      fontSize: 14,
                                                      fontFamily: 'PingFang TC',
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  Text(
                                                    '2025.01.01 加入',
                                                    style: TextStyle(
                                                      color: const Color(0xFF898989),
                                                      fontSize: 12,
                                                      fontFamily: 'PingFang TC',
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width: 4,),
                                              Icon(Icons.more_vert),
                                            ],
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),// 自訂內容（見下）
                        );
                      },
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
                Container(
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
                    Icon(Icons.more_vert),
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

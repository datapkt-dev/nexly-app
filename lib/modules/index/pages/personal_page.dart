import 'package:flutter/material.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  List<String> info = ['Tales', '粉絲', '追蹤中', 'Trusted Circle'];
  List<String> category = ['Tales', '協作', '收藏'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            leading: SizedBox.shrink(),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_vert),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
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
                        Row(
                          children: List.generate(info.length, (index) {
                            return Row(
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
                                SizedBox(width: 10,),
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
                                    'progress 成就',
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
                                    '個人',
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
                                    '團體',
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
                                        color: Color(0xFF24B7BD),
                                        fontSize: 14,
                                        fontFamily: 'PingFang TC',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      height: 2,
                                      width: 40, // 這裡你可以改成固定長度 或 動態依文字寬度
                                      color: const Color(0xFF24B7BD),
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
                          decoration: ShapeDecoration(
                            // image: DecorationImage(
                            //   image: AssetImage('assets/images/sample.png'), // ✅ 用 AssetImage
                            //   fit: BoxFit.cover,
                            // ),
                            color: Color(0xFFE7E7E7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
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

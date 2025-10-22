import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Cooperation extends StatefulWidget {
  const Cooperation({super.key});

  @override
  State<Cooperation> createState() => _CooperationState();
}

enum _PostMenu {create, setting, delete,}

class _CooperationState extends State<Cooperation> {
  final List<String> img = [
    'assets/images/landscape/dog.jpg',
    'assets/images/landscape/egypt.jpg',
    'assets/images/landscape/goingup.jpg',
    'assets/images/landscape/hiking.jpg',
    'assets/images/postImg.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          '協作資料夾名稱',
          style: TextStyle(
            color: const Color(0xFF333333),
            fontSize: 18,
            fontFamily: 'PingFang TC',
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.open_in_new),
            onPressed: () {},
          ),
          PopupMenuButton<_PostMenu>(
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
            onSelected: (v) async {
              switch (v) {
                case _PostMenu.create:
                // TODO: 編輯貼文
                  break;
                case _PostMenu.setting:
                // TODO: 複製至協作
                  break;
                case _PostMenu.delete:
                  final ok = await showDialog<bool>(
                    context: context,
                    // builder: (_) => AlertDialog(
                    //   title: const Text('刪除貼文'),
                    //   content: const Text('確定要刪除此貼文嗎？'),
                    //   actions: [
                    //     TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
                    //     TextButton(onPressed: () => Navigator.pop(context, true),  child: const Text('確定')),
                    //   ],
                    // ),
                    builder: (context) {
                      return Dialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFF4A4A4A), width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20), // 四邊 20
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              Text(
                                '是否確定刪除OOO協作資料夾?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF333333),
                                  fontSize: 16,
                                  fontFamily: 'PingFang TC',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 60),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      child: Container(
                                        height: 40,
                                        alignment: Alignment.center,
                                        decoration: ShapeDecoration(
                                          color: Color(0xFF2C538A),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                        ),
                                        child: const Text(
                                          '確定',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'PingFang TC',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12,),
                                  Expanded(
                                    child: GestureDetector(
                                      child: Container(
                                        height: 40,
                                        alignment: Alignment.center,
                                        decoration: ShapeDecoration(
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: 1,
                                              color: const Color(0xFFE7E7E7),
                                            ),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ),
                                        child: const Text(
                                          '取消',
                                          style: TextStyle(
                                            color: const Color(0xFF333333),
                                            fontSize: 14,
                                            fontFamily: 'PingFang TC',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                  if (ok == true) {
                    // TODO: 呼叫刪除 API
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _PostMenu.create,
                child: Text('建立Tales'),
              ),
              const PopupMenuItem(
                value: _PostMenu.setting,
                child: Text('協作設定'),
              ),
              // const PopupMenuDivider(),
              const PopupMenuItem(
                value: _PostMenu.delete,
                child: Text(
                  '刪除協作資料夾',
                  style: TextStyle(color: Color(0xFFE9416C)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: 16,),
                SizedBox(
                  height: 40,
                  width: 200,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        // child: Container(
                        //   width: 40,
                        //   height: 40,
                        //   decoration: ShapeDecoration(
                        //     // image: DecorationImage(
                        //     //   image: NetworkImage("https://placehold.co/40x40"),
                        //     //   fit: BoxFit.cover,
                        //     // ),
                        //     shape: OvalBorder(
                        //       side: BorderSide(
                        //         width: 1,
                        //         color: const Color(0xFFE7E7E7),
                        //       ),
                        //     ),
                        //   ),
                        //   child: SvgPicture.asset('assets/images/avatar_1.svg'),
                        // ),
                        child: Container(
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
                      ),
                      Positioned(
                        left: 30,
                        // child: Container(
                        //   width: 40,
                        //   height: 40,
                        //   decoration: ShapeDecoration(
                        //     // image: DecorationImage(
                        //     //   image: NetworkImage("https://placehold.co/40x40"),
                        //     //   fit: BoxFit.cover,
                        //     // ),
                        //     shape: OvalBorder(
                        //       side: BorderSide(
                        //         width: 1,
                        //         color: const Color(0xFFE7E7E7),
                        //       ),
                        //     ),
                        //   ),
                        //   child: SvgPicture.asset('assets/images/avatar_1.svg'),
                        // ),
                        child: Container(
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
                      ),
                      Positioned(
                        left: 60,
                        // child: Container(
                        //   width: 40,
                        //   height: 40,
                        //   decoration: ShapeDecoration(
                        //     // image: DecorationImage(
                        //     //   image: NetworkImage("https://placehold.co/40x40"),
                        //     //   fit: BoxFit.cover,
                        //     // ),
                        //     shape: OvalBorder(
                        //       side: BorderSide(
                        //         width: 1,
                        //         color: const Color(0xFFE7E7E7),
                        //       ),
                        //     ),
                        //   ),
                        //   child: SvgPicture.asset('assets/images/avatar_1.svg'),
                        // ),
                        child: Container(
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
                      ),
                      Positioned(
                        left: 90,
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF5F5F5),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xFFE7E7E7),
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: Text(
                            '+10',
                            style: TextStyle(
                              color: const Color(0xFF2C538A),
                              fontSize: 16,
                              fontFamily: 'PingFang TC',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Text(
                  '3 Tales • 5 參與者',
                  style: TextStyle(
                    color: const Color(0xFF898989),
                    fontSize: 14,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 16,),
              ],
            ),
            SizedBox(height: 10,),
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
              itemCount: 9, // 資料數量
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
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onTap: () {},
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:nexly_temp/modules/payment/payment.dart';
import 'package:nexly_temp/modules/post/post.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexState();
}

class _IndexState extends State<IndexPage> {
  bool _showOverlay = false;
  final List<String> tags = ['全部', '旅遊', '學習', '挑戰', '冒險',];
  final List<String> img = [
    'assets/images/landscape/dog.jpg',
    'assets/images/landscape/egypt.jpg',
    'assets/images/landscape/goingup.jpg',
    'assets/images/landscape/hiking.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10,),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(tags.length, (index) {
                              return Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(right: 10,),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6,),
                                decoration: ShapeDecoration(
                                  color: index == 0 ? Color(0xFF2C538A) : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: index == 0 ? Color(0xFF2C538A) : Color(0xFF2C538A),
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  tags[index],
                                  style: TextStyle(
                                    color: index == 0 ? Colors.white : Color(0xFF2C538A),
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showOverlay = true;
                          });
                        },
                        child: Icon(Icons.expand_more),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(0),
                      shrinkWrap: true, // 高度隨內容變化
                      physics: NeverScrollableScrollPhysics(), // 交給外層滾動
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,     // 一列 2 個
                        crossAxisSpacing: 6,   // 左右間距
                        mainAxisSpacing: 10,   // 上下間距
                        mainAxisExtent: 278,   // ✅ 固定每個 item 的高度 (250 圖片 + 文字空間)
                      ),
                      itemCount: 6, // 資料數量
                      itemBuilder: (context, index) {
                        // final post = posts[index]; // 換成你的資料
                        return GestureDetector(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 250,
                                    decoration: ShapeDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(img[index%4]), // ✅ 用 AssetImage
                                        fit: BoxFit.cover,
                                      ),
                                      color: Color(0xFFE7E7E7),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    left: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                      decoration: ShapeDecoration(
                                        color: Colors.black.withValues(alpha: 0.30),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Text(
                                        '旅遊',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: 'PingFang TC',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      child: Icon(
                                        Icons.bookmark_border,
                                        color: Colors.white,
                                      ),
                                      onTap: () {
                                        setState(() {
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
                                                    Text(
                                                      '你的Tales已達上限。\n「升級至 nexly+，解鎖無限 Tales 與 Co-Tales，讓你的故事沒有界限。」',
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
                                                        height: 40,
                                                        padding: const EdgeInsets.all(10),
                                                        alignment: Alignment.center,
                                                        decoration: ShapeDecoration(
                                                          color: const Color(0xFF2C538A),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                        ),
                                                        child: Text(
                                                          '去了解',
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontFamily: 'PingFang TC',
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(builder: (context) => Payment()),
                                                        );
                                                      },
                                                    ),
                                                    SizedBox(height: 30,),
                                                  ],
                                                ),
                                              );// 自訂內容（見下）;
                                            },
                                          );
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '標題文字',
                                    style: TextStyle(
                                      color: const Color(0xFF333333),
                                      fontSize: 14,
                                      fontFamily: 'PingFang TC',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Spacer(),
                                  GestureDetector(
                                    child: Icon(Icons.more_vert),
                                    onTap: () {

                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Post()),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showOverlay) ...[
            GestureDetector(
              onTap: () {
                setState(() {
                  _showOverlay = false;
                });
              },
              child: AnimatedOpacity(
                opacity: _showOverlay ? 1.0 : 0.0,
                duration: Duration(milliseconds: 300),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20,),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x19333333),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '類型',
                        style: TextStyle(
                          color: const Color(0xFF333333),
                          fontSize: 14,
                          fontFamily: 'PingFang TC',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showOverlay = false;
                          });
                        },
                        child: Icon(Icons.expand_more),
                      ),
                    ],
                  ),
                  SizedBox(height: 15,),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(tags.length, (index) {
                      return IntrinsicWidth(
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(right: 10,),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6,),
                          decoration: ShapeDecoration(
                            color: index == 0 ? Color(0xFF2C538A) : Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: index == 0 ? Color(0xFF2C538A) : Color(0xFF2C538A),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            tags[index],
                            style: TextStyle(
                              color: index == 0 ? Colors.white : Color(0xFF2C538A),
                              fontSize: 14,
                              fontFamily: 'PingFang TC',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

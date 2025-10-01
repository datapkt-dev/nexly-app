import 'package:flutter/material.dart';
import 'package:nexly_temp/modules/post/post.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexState();
}

class _IndexState extends State<IndexPage> {
  bool _showOverlay = false;
  final List<String> tags = ['全部', '旅遊', '學習', '挑戰', '冒險',];

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
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: index == 0 ? Color(0xFF24B7BD) : Color(0xFFE7E7E7),
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  tags[index],
                                  style: TextStyle(
                                    color: index == 0 ? Color(0xFF24B7BD) :  Color(0xFF333333),
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
                      itemCount: 5, // 資料數量
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
                                  Icon(Icons.more_vert),
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
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: index == 0 ? Color(0xFF24B7BD) :  Color(0xFFE7E7E7),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            tags[index],
                            style: TextStyle(
                              color: index == 0 ? Color(0xFF24B7BD) :  Color(0xFF333333),
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

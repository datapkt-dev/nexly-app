import 'package:flutter/material.dart';
import 'package:nexly/features/tales/presentation/pages/create_tale_page.dart';

class NewPost extends StatefulWidget {
  const NewPost({super.key});

  @override
  State<NewPost> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
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
        title: Text(
          '新貼文',
          style: TextStyle(
            color: const Color(0xFF333333),
            fontSize: 18,
            fontFamily: 'PingFang TC',
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              '下一步',
              style: TextStyle(
                color: const Color(0xFF333333),
                fontSize: 16,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w400,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PostContentEdit()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                '我的相簿',
                style: TextStyle(
                  color: const Color(0xFF333333),
                  fontSize: 16,
                  fontFamily: 'PingFang TC',
                  fontWeight: FontWeight.w400,
                ),
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
                mainAxisExtent: 130,   // ✅ 固定每個 item 的高度 (250 圖片 + 文字空間)
              ),
              itemCount: 6, // 資料數量
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: const Color(0xFFEAEAEA)),
                    child: Icon(Icons.photo_camera_outlined),
                  );
                } else {
                  return GestureDetector(
                    child: Container(
                      width: double.infinity,
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
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

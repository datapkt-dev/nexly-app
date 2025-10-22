import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final List<String> group = ['挑戰', '學習', '旅遊',];
  final List<String> img = [
    'assets/images/landscape/goingup.jpg',
    'assets/images/landscape/egypt.jpg',
    'assets/images/postImg.png',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Container(
              height: 34,
              margin: EdgeInsets.symmetric(vertical: 9),
              decoration: ShapeDecoration(
                color: const Color(0xFFEEEEEE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    size: 18,
                    color: Color(0xFFABABAB),
                  ),
                  const SizedBox(width: 6), // icon 和文字之間的間距
                  Expanded(
                    child: TextField(
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontFamily: 'PingFang TC',
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: '搜尋關鍵字',
                        hintStyle: TextStyle(
                          color: Color(0xFFABABAB),
                          fontSize: 16,
                          fontFamily: 'PingFang TC',
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(height: 10,),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        height: 40,
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Text(
                              group[index % 3],
                              style: TextStyle(
                                color: const Color(0xFF333333),
                                fontSize: 16,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                            Icon(Icons.keyboard_arrow_right),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(6, (index) {
                            return Container(
                              width: 125,
                              height: 125,
                              margin: EdgeInsets.only(right: 4),
                              alignment: Alignment.center,
                              decoration: ShapeDecoration(
                                image: DecorationImage(
                                  image: AssetImage(img[index%3]),
                                  fit: BoxFit.cover,
                                ),
                                color: Color(0xFFE7E7E7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              // child: Text('${index+1}'),
                            );
                          }),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

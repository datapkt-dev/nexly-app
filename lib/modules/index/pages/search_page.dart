import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '挑戰',
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(5, (index) {
                          return Container(
                            width: 123.66,
                            height: 123.66,
                            margin: EdgeInsets.only(right: 4),
                            alignment: Alignment.center,
                            decoration: ShapeDecoration(
                              // image: DecorationImage(
                              //   image: NetworkImage("https://placehold.co/124x124"),
                              //   fit: BoxFit.cover,
                              // ),
                              color: Color(0xFFE7E7E7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('${index+1}'),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 18,),
                    Row(
                      children: [
                        Text(
                          '學習',
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(5, (index) {
                          return Container(
                            width: 123.66,
                            height: 123.66,
                            margin: EdgeInsets.only(right: 4),
                            alignment: Alignment.center,
                            decoration: ShapeDecoration(
                              // image: DecorationImage(
                              //   image: NetworkImage("https://placehold.co/124x124"),
                              //   fit: BoxFit.cover,
                              // ),
                              color: Color(0xFFE7E7E7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('${index+1}'),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 18,),
                    Row(
                      children: [
                        Text(
                          '旅遊',
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(5, (index) {
                          return Container(
                            width: 123.66,
                            height: 123.66,
                            margin: EdgeInsets.only(right: 4),
                            alignment: Alignment.center,
                            decoration: ShapeDecoration(
                              // image: DecorationImage(
                              //   image: NetworkImage("https://placehold.co/124x124"),
                              //   fit: BoxFit.cover,
                              // ),
                              color: Color(0xFFE7E7E7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('${index+1}'),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

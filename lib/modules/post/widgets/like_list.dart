import 'package:flutter/material.dart';

class LikeList extends StatefulWidget {
  const LikeList({super.key});

  @override
  State<LikeList> createState() => _LikeListState();
}

class _LikeListState extends State<LikeList> {
  bool followed = true;
  bool defaultHeight = false;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: defaultHeight ? 0.9 : 0.7,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
            // 把手
            const SizedBox(height: 10),
            GestureDetector(
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDADADA),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              onTap: () {
                setState(() {
                  defaultHeight = !defaultHeight;
                });
              },
            ),
            const SizedBox(height: 22),

            // 標題列
            Center(
              child: const Text(
                '按讚的用戶',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 18,
                  fontFamily: 'PingFang TC',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // 成員列表
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: 10,
                separatorBuilder: (_, __) => SizedBox.shrink(),
                itemBuilder: (_, __) {
                  return Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 9),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Container(
                            //   width: 40,
                            //   height: 40,
                            //   decoration: BoxDecoration(
                            //     shape: BoxShape.circle,
                            //     border: Border.all(color: const Color(0xFFE7E7E7)),
                            //   ),
                            //   child: SvgPicture.asset('assets/images/avatar_1.svg'),
                            // ),
                            Container(
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
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'jane',
                                  style: TextStyle(
                                    color: Color(0xFF333333),
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4,),
                                Text(
                                  'jane05171921',
                                  style: TextStyle(
                                    color: Color(0xFF898989),
                                    fontSize: 12,
                                    fontFamily: 'PingFang TC',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        child: Container(
                          width: 88,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xFFD9E0E3),
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            '${followed ? '取消' : ''}追蹤',
                            style: TextStyle(
                              color: const Color(0xFF333333),
                              fontSize: 14,
                              fontFamily: 'PingFang TC',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            followed = !followed;
                          });
                        },
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

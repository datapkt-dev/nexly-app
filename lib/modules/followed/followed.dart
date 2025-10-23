import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class Followed extends StatefulWidget {
  const Followed({super.key});

  @override
  State<Followed> createState() => _FollowedState();
}

class _FollowedState extends State<Followed> {
  int selectedIndex = 0;
  final List<String> category = ['100 粉絲', '100 追蹤',];
  bool followed = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        // leading: SizedBox.shrink(),
        title: Text(
          'jasmine05171921',
          style: TextStyle(
            color: const Color(0xFF333333),
            fontSize: 18,
            fontFamily: 'PingFang TC',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16,),
              child: Container(
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
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
                          decoration: followed
                              ? ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xFFD9E0E3),
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ) : ShapeDecoration(
                            color: const Color(0xFF2C538A),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: Text(
                            '${followed ? '取消' : ''}追蹤',
                            style: TextStyle(
                              color: followed ? const Color(0xFF333333) : Colors.white,
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

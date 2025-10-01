import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            centerTitle: false,
            title: Text(
              '通知',
              style: TextStyle(
                color: const Color(0xFF333333),
                fontSize: 20,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {},
                child: Text(
                  '全部已讀',
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(4, (index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20,),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: ShapeDecoration(
                            // image: DecorationImage(
                            //   image: NetworkImage("https://placehold.co/48x48"),
                            //   fit: BoxFit.cover,
                            // ),
                            shape: OvalBorder(
                              side: BorderSide(
                                width: 2,
                                color: const Color(0xFFE7E7E7),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sam 已經開始追蹤你',
                              style: TextStyle(
                                color: const Color(0xFF333333),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 4,),
                            Text(
                              '5 小時',
                              style: TextStyle(
                                color: const Color(0xFF838383),
                                fontSize: 12,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        SizedBox(width: 8,),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF24B7BD),
                            shape: OvalBorder(),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

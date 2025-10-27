import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<String> message = [
    'Sam 已經開始追蹤你',
    'Sam 邀請您協作「巴黎旅遊三天」的資料夾',
    'Roxy 分享了Tales「標題名稱」給您',
    'Roxy 新增了Tales至「協作資料夾名稱」的資料夾',
  ];

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
                children: List.generate(message.length, (index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20,),
                    child: Row(
                      children: [
                        // Container(
                        //   width: 48,
                        //   height: 48,
                        //   decoration: ShapeDecoration(
                        //     image: DecorationImage(
                        //       image: NetworkImage("https://placehold.co/48x48"),
                        //       fit: BoxFit.cover,
                        //     ),
                        //     shape: OvalBorder(
                        //       side: BorderSide(
                        //         width: 2,
                        //         color: const Color(0xFFE7E7E7),
                        //       ),
                        //     ),
                        //   ),
                        //   child: SvgPicture.asset('assets/images/avatar_2.svg'),
                        // ),
                        Container(
                          width: 48,
                          height: 48,
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
                        SizedBox(width: 8,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message[index],
                                style: TextStyle(
                                  color: const Color(0xFF333333),
                                  fontSize: 14,
                                  fontFamily: 'PingFang TC',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              if (index == 2) ...[
                                SizedBox(height: 4,),
                                Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 24,
                                      alignment: Alignment.center,
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFF2C538A),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      ),
                                      child: Text(
                                        '同意',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: 'PingFang TC',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10,),
                                    Container(
                                      width: 60,
                                      height: 24,
                                      alignment: Alignment.center,
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            width: 1,
                                            color: const Color(0xFFE7E7E7),
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      child: Text(
                                        '婉拒',
                                        style: TextStyle(
                                          color: const Color(0xFF333333),
                                          fontSize: 14,
                                          fontFamily: 'PingFang TC',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
                        ),
                        SizedBox(width: 8,),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFE9416C),
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

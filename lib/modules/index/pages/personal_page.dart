import 'package:flutter/material.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            leading: SizedBox.shrink(),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_vert),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: ShapeDecoration(
                            // image: DecorationImage(
                            //   image: NetworkImage("https://placehold.co/60x60"),
                            //   fit: BoxFit.cover,
                            // ),
                            shape: OvalBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xFFE7E7E7),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sam',
                              style: TextStyle(
                                color: const Color(0xFF333333),
                                fontSize: 16,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'sam9527',
                              style: TextStyle(
                                color: const Color(0xFF838383),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),

                    SizedBox(height: 10,),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

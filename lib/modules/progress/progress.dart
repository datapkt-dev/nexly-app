import 'dart:ui';

import 'package:flutter/material.dart';

import 'widgets/ringchart.dart';

class Progress extends StatefulWidget {
  const Progress({super.key});

  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  List<String> tags = ['最近完成活動', '未完成活動',];
  int selectedTag = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            image: const DecorationImage(
              image: AssetImage('assets/images/progress_bg.png'),
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
          foregroundDecoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6), // 直接一層黑紗
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              '帳號設定',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // 模糊強度可調
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    // 這層只負責著色，不會影響背後以外的內容
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),       // 玻璃白霧
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.30),     // 可選：玻璃邊緣亮線
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        RingChart(percent: 0.5, centerTitle: '個人', subtitle: '50%',),
                        SizedBox(width: 40,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '已完成',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Text(
                                  '10',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [
                                Text(
                                  '未完成',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Text(
                                  '32',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [
                                Text(
                                  '總計',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Text(
                                  '42',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30,),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 20, left: 16, right: 16,),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
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
                          children: List.generate(tags.length, (index) {
                            return Expanded(
                              child: GestureDetector(
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: ShapeDecoration(
                                    color: selectedTag == index ? const Color(0xFFF46C3F) : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                  ),
                                  child: Text(
                                    tags[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: selectedTag == index ? Colors.white : const Color(0xFF333333),
                                      fontSize: 14,
                                      fontFamily: 'PingFang TC',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedTag = index;
                                  });
                                },
                              ),
                            );
                          }),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          itemCount: 6, // 你的資料長度
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                // 圖片卡（給固定寬/高避免擠壓）
                                Container(
                                  width: 125,
                                  height: 95,
                                  decoration: ShapeDecoration(
                                    image: DecorationImage(
                                      image: AssetImage('assets/images/landscape/goingup.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // 右側文字塊
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        '巴黎喝咖啡活動',
                                        style: TextStyle(
                                          color: Color(0xFF333333),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        '2025.01.03',
                                        style: TextStyle(
                                          color: Color(0xFF24B7BD),
                                          fontSize: 14,
                                          fontFamily: 'PingFang TC',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
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
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nexly/modules/payment/widgets/NoticeBlock.dart';
import 'package:nexly/modules/payment/widgets/PlanComparison.dart';

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top; // 狀態列高度
    const fadeHeight = 230; // 模糊＋淡出的高度

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/payment_bg.png',
              fit: BoxFit.contain,                 // 填滿
              alignment: Alignment.topCenter,    // 對齊上方
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: fadeHeight + topInset,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.10), // 最上緣一點點霧白
                      Colors.white.withOpacity(0.60),
                      Colors.white,                    // 與下方白底銜接
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: GestureDetector(
                child: Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    color: Colors.black.withValues(alpha: 0.30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Icon(Icons.close, color: Colors.white,),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ),
            body: Column(
              children: [
                SizedBox(height: 175,),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        PlanComparison(),
                        SizedBox(height: 20,),
                        Container(
                          width: double.infinity,
                          height: 86,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xFFE7E7E7),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '每月方案',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF333333),
                                  fontSize: 16,
                                  fontFamily: 'PingFang TC',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '\$ 120',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF333333),
                                  fontSize: 16,
                                  fontFamily: 'PingFang TC',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10,),
                        Container(
                          width: double.infinity,
                          height: 86,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF5B86FF), // 左上藍
                                Color(0xFF79E2E8), // 右下青
                              ],
                            ),
                            boxShadow: [
                              // 很淡的外光/陰影，讓邊緣更柔
                              BoxShadow(
                                color: const Color(0xFF5B86FF).withOpacity(0.10),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16 - 0.5),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '一年方案',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(0xFF333333),
                                        fontSize: 16,
                                        fontFamily: 'PingFang TC',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(height: 6,),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        // 藍→青 的線性漸層
                                        gradient: const LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [Color(0xFF5B86FF), Color(0xFF79E2E8)],
                                        ),
                                        borderRadius: BorderRadius.circular(999),
                                        // 淡淡白色外框，讓邊緣更乾淨
                                        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
                                        // 可選：一點陰影
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        '20% OFF',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    )

                                  ],
                                ),
                                Spacer(),
                                Text(
                                  '\$ 120',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFF333333),
                                    fontSize: 16,
                                    fontFamily: 'PingFang TC',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20,),
                        const NoticeBlock(
                          items: [
                            '訂閱將於到期時自動續訂，可隨時於帳號設定中取消。',
                            '所有費用將透過 App Store / Google Play 扣款，依地區可能有所不同。',
                            '購買後不可退款。',
                            'nexly 保留調整功能與方案的權利。',
                          ],
                        ),
                        SizedBox(height: 175,),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x19333333),
                        blurRadius: 4,
                        offset: Offset(0, -2),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF2C538A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text(
                      '我要升級',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'PingFang TC',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30,)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

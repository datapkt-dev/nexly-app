import 'package:flutter/material.dart';

class Progress extends StatefulWidget {
  const Progress({super.key});

  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        image: const DecorationImage(
          image: AssetImage('assets/images/progress_bg.png'),
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
        ),

      ),
      foregroundDecoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35), // 直接一層黑紗
      ),
      child: Scaffold(
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
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: ShapeDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class VehicleManage extends StatefulWidget {
  final List<dynamic>? vehicle;
  const VehicleManage({super.key, required this.vehicle});

  @override
  State<VehicleManage> createState() => _VehicleManageState();
}

class _VehicleManageState extends State<VehicleManage> {
  List<dynamic>? vehicleList;

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      vehicleList = widget.vehicle;
    } else {
      vehicleList = [];
    }
    print(vehicleList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF282828),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFFEFEFEF)),
        title: Text(
          '車籍管理',
          style: TextStyle(
            color: const Color(0xFFEFEFEF),
            fontSize: 18,
            fontFamily: 'PingFang TC',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: vehicleList!.isNotEmpty
              ? Column(
            children: List.generate(vehicleList!.length, (index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index > 0) ...[
                    SizedBox(height: 10,),
                  ],
                  Text(
                    '車輛${index+1}',
                    style: TextStyle(
                      color: const Color(0xFFEFEFEF),
                      fontSize: 14,
                      fontFamily: 'Noto Sans TC',
                      fontWeight: FontWeight.w400,
                      height: 1.20,
                    ),
                  ),
                  SizedBox(height: 4,),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: ShapeDecoration(
                            color: const Color(0xFF333333),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: Text(
                            '${vehicleList?[index]['car_type']}',
                            style: TextStyle(
                              color: const Color(0xFFEFEFEF),
                              fontSize: 16,
                              fontFamily: 'Noto Sans TC',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        child: Container(
                          height: 48,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: ShapeDecoration(
                            color: const Color(0xFF333333),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: Text(
                            '${vehicleList?[index]['car_number']}',
                            style: TextStyle(
                              color: const Color(0xFFEFEFEF),
                              fontSize: 16,
                              fontFamily: 'Noto Sans TC',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 75,),
              SvgPicture.asset(
                'assets/icons/unready.svg',
                color: Colors.white,
              ),
              SizedBox(height: 32,),
              Text(
                '尚無紀錄',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF999999),
                  fontSize: 14,
                  fontFamily: 'Noto Sans TC',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

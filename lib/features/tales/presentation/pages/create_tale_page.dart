import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../app/config/app_config.dart';
import '../../../../unit/auth_service.dart';

class PostContentEdit extends StatefulWidget {
  final String? filePath;
  const PostContentEdit({super.key, this.filePath});

  @override
  State<PostContentEdit> createState() => _ContentEditState();
}

class _ContentEditState extends State<PostContentEdit> {
  Future<Map<String, dynamic>> futureData = Future.value({});

  TextEditingController controllerTitle = TextEditingController();
  TextEditingController controllerContent = TextEditingController();
  List<String> tags = ['情感', '個人', '挑戰', '冒險', '冒險', '冒險', '冒險', '冒險'];
  List<bool> selectedClass = [false, false, false, false, false, false, false, false];
  List<bool> selectedTarget = [false, false, false, false, false, false, false, false];
  String filePath = '';

  Future<Map<String, dynamic>> uploadImg(String filePath) async {
    final String baseUrl = AppConfig.baseURL;
    final file = File(filePath);
    if (!await file.exists()) {
      return {'error': 'File not found: $filePath'};
    }

    final uri = Uri.parse('$baseUrl/upload-image'); // 若有 HTTPS 請改 https
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath('files', filePath), // 不帶 contentType
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    return body;
  }

  Future<Map<String, dynamic>> postTale(Map<String, dynamic> temp) async {
    final String baseUrl = AppConfig.baseURL;
    final AuthService authStorage = AuthService();

    final url = Uri.parse('$baseUrl/projects/1/tales');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode(temp);

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }

  @override
  void initState() {
    super.initState();
    print(widget.filePath);
    if (widget.filePath != null) {
      filePath = widget.filePath!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          '新貼文',
          style: TextStyle(
            color: const Color(0xFF333333),
            fontSize: 18,
            fontFamily: 'PingFang TC',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '發生錯誤: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10,),
                        decoration: ShapeDecoration(
                          image: DecorationImage(
                            image: AssetImage(filePath),
                            fit: BoxFit.cover,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16,),
                        // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                            // color: const Color(0xFFEEEEEE),
                            // width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: controllerTitle,
                          maxLines: 1,
                          decoration: const InputDecoration(
                            hintText: '標題',
                            hintStyle: TextStyle(
                              color: Color(0xFFB0B0B0),
                              fontSize: 16,
                              fontFamily: 'PingFang TC',
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            color: Color(0xFF454545),
                            fontSize: 16,
                            fontFamily: 'PingFang TC',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16,),
                        child: TextField(
                          controller: controllerContent,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          minLines: 1,         // 起始 1 行
                          maxLines: null,      // 不限制行數 → 自動換行並增高
                          decoration: const InputDecoration(
                            hintText: '描述',
                            hintStyle: TextStyle(
                              color: Color(0xFFB0B0B0),
                              fontSize: 16,
                              fontFamily: 'PingFang TC',
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            color: Color(0xFF454545),
                            fontSize: 16,
                            fontFamily: 'PingFang TC',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Divider(color: Color(0xFFEEEEEE),),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/new_post/tag.svg',
                              width: 20,
                              height: 20,
                            ),
                            SizedBox(width: 10,),
                            Text(
                              '領域',
                              style: TextStyle(
                                color: const Color(0xFF333333),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                              ),
                            ),
                            Spacer(),
                            Icon(Icons.keyboard_arrow_right),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(tags.length+2, (index) {
                            if (index == 0) {
                              return SizedBox(width: 16,);
                            } else if (index == tags.length+1) {
                              return SizedBox(width: 16,);
                            }
                            return GestureDetector(
                              child: Container(
                                height: 30,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(left: 8, right: 4),
                                margin: EdgeInsets.only(left: index > 1 ? 10 : 0,),
                                decoration: ShapeDecoration(
                                  color: selectedClass[index-1] ? Color(0xFF2C538A) : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: const Color(0xFF2C538A),
                                    ),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      tags[index-1],
                                      style: TextStyle(
                                        color: selectedClass[index-1] ? Colors.white : Color(0xFF2C538A),
                                        fontSize: 14,
                                        fontFamily: 'PingFang TC',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Icon(
                                      selectedClass[index-1] ? Icons.close : Icons.add,
                                      size: 16,
                                      color: selectedClass[index-1] ? Colors.white : Color(0xFF2C538A),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  selectedClass[index-1] = !selectedClass[index-1];
                                });
                              },
                            );
                          }),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/new_post/postTo.svg',
                              width: 20,
                              height: 20,
                            ),
                            SizedBox(width: 10,),
                            Text(
                              '發佈至',
                              style: TextStyle(
                                color: const Color(0xFF333333),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                              ),
                            ),
                            Spacer(),
                            Icon(Icons.keyboard_arrow_right),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(tags.length+2, (index) {
                            if (index == 0) {
                              return SizedBox(width: 16,);
                            } else if (index == tags.length+1) {
                              return SizedBox(width: 16,);
                            }
                            return GestureDetector(
                              child: Container(
                                height: 30,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(left: 8, right: 4),
                                margin: EdgeInsets.only(left: index > 1 ? 10 : 0,),
                                decoration: ShapeDecoration(
                                  color: selectedTarget[index-1] ? Color(0xFF2C538A) : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: const Color(0xFF2C538A),
                                    ),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      tags[index-1],
                                      style: TextStyle(
                                        color: selectedTarget[index-1] ? Colors.white : Color(0xFF2C538A),
                                        fontSize: 14,
                                        fontFamily: 'PingFang TC',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Icon(
                                      selectedTarget[index-1] ? Icons.close : Icons.add,
                                      size: 16,
                                      color: selectedTarget[index-1] ? Colors.white :  Color(0xFF2C538A),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  selectedTarget[index-1] = !selectedTarget[index-1];
                                });
                              },
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                child: Container(
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
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF2C538A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text(
                      '發佈',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'PingFang TC',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  print('press');
                  if (controllerTitle.text != '' && controllerContent.text != '') {
                    setState(() {
                      futureData = uploadImg(filePath);
                      futureData.then((result) {
                        if (result['message'] == 'Upload successful') {
                          futureData = postTale({
                            "title": controllerTitle.text,
                            "content": controllerContent.text,
                            "category_id": 1,
                            "image_url": result['data']['urls'][0],
                            "publish_type": "personal" ,
                          });
                          Navigator.pop(context);
                        }
                      });
                    });
                  }
                },
              ),
              SizedBox(height: 30,),
            ],
          );
        },
      ),
    );
  }
}

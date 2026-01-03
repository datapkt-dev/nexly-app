import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nexly/features/tales/presentation/widgets/submit_button.dart';
import '../../../../app/config/app_config.dart';
import '../../../../unit/auth_service.dart';
import '../widgets/category_chips.dart';

class PostContentEdit extends StatefulWidget {
  final String? filePath;
  const PostContentEdit({super.key, this.filePath});

  @override
  State<PostContentEdit> createState() => _ContentEditState();
}

class _ContentEditState extends State<PostContentEdit> {
  Future<void>? futureData;

  TextEditingController controllerTitle = TextEditingController();
  TextEditingController controllerContent = TextEditingController();
  List<Map<String, dynamic>> tags = [
    {'name' : '個人頁', 'is_active': false,},
    {'name' : '資料夾A', 'is_active': false,},
    {'name' : '資料夾B', 'is_active': false,},
    {'name' : '資料夾C', 'is_active': false,},
    {'name' : '資料夾D', 'is_active': false,},
    {'name' : '資料夾E', 'is_active': false,},
  ];
  List<Map<String, dynamic>> categories = [];
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

  Future<List<Map<String, dynamic>>> getCategories() async {
    final AuthService authStorage = AuthService();
    final String baseUrl = AppConfig.baseURL;

    final url = Uri.parse('$baseUrl/projects/1/categories');
    final token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);
    final responseData = jsonDecode(response.body);

    final List apiCategories = responseData['data'] as List;
    print(apiCategories);

    return apiCategories.asMap().entries.map<Map<String, dynamic>>((entry) {
      final index = entry.key;
      final c = entry.value;

      return {
        ...Map<String, dynamic>.from(c),
        'is_active': index == 0, // ⭐ 第一筆 true，其餘 false
      };
    }).toList();
  }

  Future<void> _initPage() async {
    final result = await getCategories();

    setState(() {
      categories = result;
    });
  }

  Future<void> _submitPost() async {
    final selectedCategory = categories.firstWhere(
          (c) => c['is_active'] == true,
      orElse: () => {},
    );

    final uploadResult = await uploadImg(filePath);

    if (uploadResult['message'] != 'Upload successful') {
      throw Exception('Upload failed');
    }

    await postTale({
      "title": controllerTitle.text,
      "content": controllerContent.text,
      "category_id": selectedCategory['id'],
      "image_url": uploadResult['data']['urls'][0],
      "publish_type": "personal",
    });

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('發佈成功')));
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    futureData = _initPage();

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
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
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
                      CategoryChips(
                        categories: categories,
                        onTap: (index) {
                          setState(() {
                            for (int i = 0; i < categories.length; i++) {
                              categories[i]['is_active'] = i == index;
                            }
                          });
                        },
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
                      CategoryChips(
                        categories: tags,
                        onTap: (index) {
                          setState(() {
                            tags[index]['is_active'] = !tags[index]['is_active'];
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
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
                child: SubmitButton(
                  buttonName: '發佈',
                  onPressed: () {
                    if (controllerTitle.text.isEmpty || controllerContent.text.isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('標題與描述不可為空')));
                      return;
                    }
                    setState(() {
                      futureData = _submitPost(); // ⭐ 關鍵
                    });
                  },
                ),
              ),
              SizedBox(height: 30,),
            ],
          );
        },
      ),
    );
  }
}

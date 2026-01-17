import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../app/config/app_config.dart';
import '../../../../unit/auth_service.dart';
import '../widgets/category_chips.dart';
import '../widgets/submit_button.dart';

class EditTalePage extends StatefulWidget {
  final Map<String, dynamic> postContent;
  const EditTalePage({super.key, required this.postContent});

  @override
  State<EditTalePage> createState() => _EditTalePageState();
}

class _EditTalePageState extends State<EditTalePage> {
  Map<String, dynamic> content = {};
  Future<void>? futureData;

  TextEditingController controllerTitle = TextEditingController();
  TextEditingController controllerContent = TextEditingController();
  List<Map<String, dynamic>> categories = [];
  bool completed = false;

  Future<Map<String, dynamic>> patchEditTale(int taleId, Map<String, dynamic> temp) async {
    final String baseUrl = AppConfig.baseURL;
    final AuthService authStorage = AuthService();

    final url = Uri.parse('$baseUrl/projects/1/tales/$taleId');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode(temp);

    try {
      final response = await http.patch(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }

  Future<void> _submitPost() async {
    final selectedCategory = categories.firstWhere(
          (c) => c['is_active'] == true,
      orElse: () => {},
    );

    // final uploadResult = await uploadImg(filePath);

    // if (uploadResult['message'] != 'Upload successful') {
    //   throw Exception('Upload failed');
    // }

    await patchEditTale(
      content['id'],
      {
        "title": controllerTitle.text,
        "content": controllerContent.text,
        "category_id": selectedCategory['id'],
        "image_url": content['image_url'],
        "is_completed": completed,
      },
    ).then((result) {

      if (result['message'] == 'Tale updated successfully') {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('編輯成功')));
        Navigator.pop(context, 'refresh');
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${result['message']}')));
      }
    });
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

    final int? activeCategoryId = content['category']?['id'];

    return apiCategories.map<Map<String, dynamic>>((c) {
      final category = Map<String, dynamic>.from(c);
      return {
        ...category,
        'is_active': category['id'] == activeCategoryId,
      };
    }).toList();
  }

  Future<void> _initPage() async {
    final result = await getCategories();

    setState(() {
      categories = result;
    });
  }

  @override
  void initState() {
    super.initState();

    content = widget.postContent;
    controllerTitle.text = content['title'];
    controllerContent.text = content['content'];
    futureData = _initPage();
    completed = content['is_completed'];
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
                            image: NetworkImage(content['image_url']),
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
                            Icon(Icons.check_circle_outline_rounded, size: 20,),
                            SizedBox(width: 10,),
                            Text(
                              '完成Tales',
                              style: TextStyle(
                                color: const Color(0xFF333333),
                                fontSize: 14,
                                fontFamily: 'PingFang TC',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                              ),
                            ),
                            Spacer(),
                            Switch(
                              value: completed,
                              activeColor: Colors.white, // 白色圓鈕
                              activeTrackColor: const Color(0xFFD63C95), // 粉色背景
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: const Color(0xFFE5E5E5),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              onChanged: (bool value) {
                                setState(() {
                                  completed = value;
                                });
                              },
                            ),
                          ],
                        ),
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
                  buttonName: '儲存',
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

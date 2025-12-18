import 'package:flutter/material.dart';
import 'package:nexly/features/tales/presentation/pages/tale_detail_page.dart';
import '../../../../modules/index/widgets/action_menu_bottom_sheet.dart';
import '../widgets/filter_overlay.dart';
import '../widgets/tag_selector.dart';
import '../widgets/tale_card.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexState();
}

class _IndexState extends State<IndexPage> {
  bool _showOverlay = false;
  final List<String> tags = ['全部', '旅遊', '學習', '挑戰', '冒險',];
  List<bool> tagsActive = [true, false, false, false, false,];
  final List<String> img = [
    'assets/images/landscape/dog.jpg',
    'assets/images/landscape/egypt.jpg',
    'assets/images/landscape/goingup.jpg',
    'assets/images/landscape/hiking.jpg',
  ];
  List<bool> collected = [true, false, false, false, false, false,];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10,),
                  child: Row(
                    children: [
                      Expanded(
                        child: TagSelector(
                          tags: tags,
                          active: tagsActive,
                          scrollable: true,
                          onTap: (index) {
                            setState(() {
                              if (index == 0) {
                                // 點擊「全部」
                                for (int i = 0; i < tagsActive.length; i++) {
                                  tagsActive[i] = (i == 0);
                                }
                              } else {
                                tagsActive[0] = false;
                                tagsActive[index] = !tagsActive[index];
                              }
                            });
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showOverlay = true;
                          });
                        },
                        child: Icon(Icons.expand_more),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(0),
                      shrinkWrap: true, // 高度隨內容變化
                      physics: NeverScrollableScrollPhysics(), // 交給外層滾動
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,     // 一列 2 個
                        crossAxisSpacing: 6,   // 左右間距
                        mainAxisSpacing: 10,   // 上下間距
                        mainAxisExtent: 278,   // ✅ 固定每個 item 的高度 (250 圖片 + 文字空間)
                      ),
                      itemCount: 6, // 資料數量
                      itemBuilder: (context, index) {
                        return TaleCard(
                          imageAsset: img[index % 4],
                          tag: '旅遊',
                          title: '標題文字',
                          isCollected: collected[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => Post()),
                            );
                          },
                          onCollectTap: () {
                            setState(() {
                              collected[index] = !collected[index];
                            });
                          },
                          onMoreTap: () {
                            ActionMenuBottomSheet.show(
                              context,
                              rootContext: context,
                              targetId: 'post_123',
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          FilterOverlay(
            show: _showOverlay,
            tags: tags,
            active: tagsActive,
            onClose: () {
              setState(() {
                _showOverlay = false;
              });
            },
            onTagTap: (index) {
              setState(() {
                if (index == 0) {
                  // 點擊「全部」
                  for (int i = 0; i < tagsActive.length; i++) {
                    tagsActive[i] = (i == 0);
                  }
                } else {
                  tagsActive[0] = false;
                  tagsActive[index] = !tagsActive[index];
                }
              });
            },
          ),

        ],
      ),
    );
  }
}

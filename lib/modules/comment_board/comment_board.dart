import 'package:flutter/material.dart';
import 'package:nexly_temp/components/widgets/keyboard_dismiss.dart';

class CommentBoard extends StatefulWidget {
  const CommentBoard({super.key});

  @override
  State<CommentBoard> createState() => _CommentBoardState();
}

class _CommentBoardState extends State<CommentBoard> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  bool _isFocused = false;
  bool _replyMode = false;
  List<bool> like = [false, false];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
        if (!_isFocused) _replyMode = false;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.7,
      child: KeyboardDismissOnTap(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16,),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // 小手把
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDADADA),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              // 標題列 + 關閉
              Center(
                child: Text(
                  '留言',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 18,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 8,),
              // 可滾動內容
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: 1, // 你的資料長度
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        GestureDetector(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
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
                              const SizedBox(width: 8),
                              // 右側文字塊
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Ella_1019',
                                          style: TextStyle(
                                            color: const Color(0xFF333333),
                                            fontSize: 14,
                                            fontFamily: 'PingFang TC',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        GestureDetector(
                                          child: Icon(
                                            Icons.favorite,
                                            size: 20,
                                            color: like[0] ? Colors.red : Color(0xFFD9D9D9),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              like[0] = !like[0];
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '＠chris1123 ',
                                            style: TextStyle(
                                              color: Color(0xFF3B5AF8),
                                              fontSize: 14,
                                              fontFamily: 'PingFang TC',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '來看看這個',
                                            style: TextStyle(
                                              color: const Color(0xFF333333),
                                              fontSize: 14,
                                              fontFamily: 'PingFang TC',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '今天 12:00',
                                          style: TextStyle(
                                            color: Color(0xFF888888),
                                            fontSize: 12,
                                            fontFamily: 'PingFang TC',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        SizedBox(width: 10,),
                                        GestureDetector(
                                          child: Text(
                                            '回覆 1',
                                            style: TextStyle(
                                              color: Color(0xFF888888),
                                              fontSize: 12,
                                              fontFamily: 'PingFang TC',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _replyMode = true;
                                              Future.delayed(Duration(milliseconds: 50), () {
                                                FocusScope.of(context).requestFocus(_focusNode);
                                              });
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // 用 InkWell 的 onLongPressStart 來拿到全域座標
                          onLongPressStart: (LongPressStartDetails details) async {
                            // ✅ 取得「最上層」的 overlay（跨過 bottom sheet）
                            final overlayState = Navigator.of(context, rootNavigator: true).overlay!;
                            final overlayContext = overlayState.context;
                            final RenderBox overlayBox = overlayContext.findRenderObject() as RenderBox;

                            // ✅ 直接用事件提供的 globalPosition
                            final Offset globalPos = details.globalPosition;

                            final selected = await showMenu<String>(
                              context: overlayContext, // ← 用最上層 overlay 的 context
                              position: RelativeRect.fromLTRB(
                                globalPos.dx,
                                globalPos.dy + 8,                                // 往下偏一點
                                overlayBox.size.width - globalPos.dx,
                                overlayBox.size.height - globalPos.dy,
                              ),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFFEDEDED)),
                              ),
                              constraints: const BoxConstraints(minWidth: 180),
                              items: const [
                                PopupMenuItem(value: 'reply',  child: Text('回覆')),
                                PopupMenuItem(value: 'edit',   child: Text('編輯')),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('刪除', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );

                            if (selected != null) {
                              debugPrint('選擇: $selected');
                              // TODO: 依 selected 做事
                            }
                          },

                        ),
                        if (true) ...[
                          SizedBox(height: 20,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 48,),
                              Container(
                                width: 40,
                                height: 40,
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
                              const SizedBox(width: 8),
                              // 右側文字塊
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Chris1122',
                                          style: TextStyle(
                                            color: const Color(0xFF333333),
                                            fontSize: 14,
                                            fontFamily: 'PingFang TC',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        GestureDetector(
                                          child: Icon(
                                            Icons.favorite,
                                            size: 20,
                                            color: like[1] ? Colors.red : Color(0xFFD9D9D9),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              like[1] = !like[1];
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '看起來很讚欸',
                                      style: TextStyle(
                                        color: const Color(0xFF333333),
                                        fontSize: 14,
                                        fontFamily: 'PingFang TC',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '今天 12:00',
                                      style: TextStyle(
                                        color: Color(0xFF888888),
                                        fontSize: 12,
                                        fontFamily: 'PingFang TC',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
              Divider(),
              if (_replyMode) ...[
                Row(
                  children: [
                    Text(
                      '正在回覆Ella_1019',
                      style: TextStyle(
                        color: const Color(0xFF898989),
                        fontSize: 14,
                        fontFamily: 'PingFang TC',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      child: Icon(Icons.close),
                      onTap: () {
                        setState(() {
                          _focusNode.unfocus();
                        });
                      },
                    ),
                  ],
                ),
              ],
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFECF0F2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: TextField(
                        focusNode: _focusNode,
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: '新增留言',
                          hintStyle: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 16,
                            fontFamily: 'PingFang TC',
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  if (_isFocused) ...[
                    SizedBox(width: 10,),
                    GestureDetector(
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: ShapeDecoration(
                          color: const Color(0xFF2C538A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _controller.text = '';
                          _focusNode.unfocus();
                        });
                      },
                    )
                  ],
                ],
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

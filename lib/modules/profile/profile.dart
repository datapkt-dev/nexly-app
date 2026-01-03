import 'package:flutter/material.dart';
import 'package:nexly/modules/account_setting/account_setting.dart';
import 'package:nexly/modules/cooperation/cooperation.dart';
import 'package:nexly/modules/progress/progress.dart';
import '../../../components/widgets/LabeledProgressBar.dart';
import '../../../l10n/app_localizations.dart';
import '../../../features/tales/presentation/pages/tale_detail_page.dart';
import '../followed/followed.dart';
import '../index/widgets/collaboration_settings_sheet.dart';

class ProfilePage extends StatefulWidget {
  final bool isSelf;
  final String? userId;

  const ProfilePage.self({super.key})
      : isSelf = true,
        userId = null;

  const ProfilePage.other({
    super.key,
    required this.userId,
  }) : isSelf = false;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedIndex = 0;

  final List<String> img = [
    'assets/images/landscape/dog.jpg',
    'assets/images/landscape/egypt.jpg',
    'assets/images/landscape/goingup.jpg',
    'assets/images/landscape/hiking.jpg',
    'assets/images/postImg.png',
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final info = [
      t.tale,
      t.follower,
      t.following,
      t.trusted_circle,
    ];

    final category = [
      t.tale,
      t.cooperation,
      t.collection,
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: widget.isSelf ? const SizedBox.shrink() : null,
        actions: [
          widget.isSelf
              ? _buildSelfMenu(context)
              : _buildOtherUserMenu(context),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildHeader(context, info, category),
              ),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= Header =================

  Widget _buildHeader(
      BuildContext context,
      List<String> info,
      List<String> category,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserRow(),
        const SizedBox(height: 10),
        _buildInfoRow(info),
        const SizedBox(height: 20),
        _buildBio(),
        const SizedBox(height: 20),
        _buildProgressCard(context),
        const SizedBox(height: 10),
        _buildCategoryTabs(category),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildUserRow() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
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
        const Spacer(),
        if (!widget.isSelf) _buildFollowButton(),
      ],
    );
  }

  Widget _buildFollowButton() {
    return InkWell(
      child: Container(
        width: 80,
        height: 32,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFE7E7E7)),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: const Text('追蹤'),
      ),
      onTap: () {},
    );
  }

  Widget _buildInfoRow(List<String> info) {
    return Wrap(
      spacing: 10,
      children: List.generate(info.length, (index) {
        final isClickable = index == 1 || index == 2;
        return InkWell(
          onTap: isClickable
              ? () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Followed()),
            );
          }
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '100',
                style: TextStyle(
                  color: const Color(0xFF333333),
                  fontSize: 14,
                  fontFamily: 'PingFang TC',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 4,),
              Text(
                info[index],
                style: TextStyle(
                  color: const Color(0xFF333333),
                  fontSize: 14,
                  fontFamily: 'PingFang TC',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBio() {
    return const Text(
      '個人簡介寫在這裡，個人簡介寫在這裡個人簡介寫在這裡',
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Progress()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.03, 0.97),
            end: Alignment(1.00, 0.05),
            colors: [const Color(0xFF2C538A), const Color(0xFF24B7BD)],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  t.progress,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.white,
                ),
              ],
            ),
            SizedBox(height: 13,),
            Row(
              children: [
                Text(
                  t.personal,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 10,),
                Text(
                  '10/42',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: LabeledProgressBar(percent: 0.5),
                ),
                SizedBox(width: 16,),
                Text(
                  '50%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'PingFangTC',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 13,),
            Row(
              children: [
                Text(
                  t.group,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 10,),
                Text(
                  '10/42',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: LabeledProgressBar(percent: 0.25),
                ),
                SizedBox(width: 16,),
                Text(
                  '25%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'PingFangTC',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(List<String> category) {
    return Container(
      width: double.infinity,
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
        children: List.generate(category.length, (index) {
          return Expanded(
            child: GestureDetector(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: ShapeDecoration(
                  color: selectedIndex == index ? const Color(0xFFF46C3F) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                child: Text(
                  category[index],
                  style: TextStyle(
                    color: selectedIndex == index ? Colors.white : const Color(0xFF333333),
                    fontSize: 14,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              onTap: () {
                setState(() {
                  setState(() {
                    selectedIndex = index;
                  });
                });
              },
            ),
          );
        }),
      ),
    );
  }

  // ================= Content =================

  Widget _buildContent() {
    if (selectedIndex == 1) return _buildCooperation();
    return _buildPostGrid();
  }

  Widget _buildPostGrid() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        mainAxisExtent: 171,
      ),
      itemCount: 7,
      itemBuilder: (_, index) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Post(myself: true,), //按照是否為自己的貼文提供狀態
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(img[index % img.length]),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCooperation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: 162,
        ),
        itemCount: widget.isSelf ? 5 : 4,
        itemBuilder: (_, index) {
          if (widget.isSelf && index == 0) {
            return _buildAddFolderCard();
          }
          return _buildCooperationItem();
        },
      ),
    );
  }

  Widget _buildAddFolderCard() {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const CollaborationSettingsSheet(),
      ),
      child: Container(
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: const Color(0x1924B7BD),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFF2C538A)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCooperationItem() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Cooperation(myself: widget.isSelf),
        ),
      ),
      child: Container(
        color: Colors.grey.shade200,
      ),
    );
  }

  // ================= Menus =================

  Widget _buildSelfMenu(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (_) => const [
        PopupMenuItem(value: 0, child: Text('帳號設定')),
      ],
      onSelected: (_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AccountSetting()),
        );
      },
    );
  }

  Widget _buildOtherUserMenu(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (_) => const [
        PopupMenuItem(value: 0, child: Text('檢舉此用戶')),
        PopupMenuItem(value: 1, child: Text('封鎖此用戶')),
      ],
      onSelected: (_) {},
    );
  }
}

import 'package:flutter/material.dart';

class PlanComparison extends StatelessWidget {
  const PlanComparison({super.key});

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(fontSize: 14, color: Color(0xFF222222));
    const cellStyle  = TextStyle(fontSize: 14, color: Color(0xFF222222));
    const headerStyle= TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

    // 勾叉圖示（可改成自家 Icon）
    Widget _tick() => const Icon(Icons.check, size: 18, color: Color(0xFF2E7D32));
    Widget _cross()=> const Icon(Icons.close, size: 18, color: Color(0xFF9E9E9E));

    TableRow _row(String title, Widget free, Widget plus) => TableRow(
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(title, style: titleStyle)),
        Center(child: free),
        Center(child: plus),
      ],
    );

    return Table(
      // 左寬右窄：第一欄彈性、後兩欄固定寬度，讓數字/勾叉對齊
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FixedColumnWidth(64),
        2: FixedColumnWidth(80),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // 表頭
        TableRow(
          children: const [
            SizedBox(), // 左側空白（與設計相同）
            Center(child: Text('Free',   style: headerStyle)),
            Center(child: Text('nexly +',style: headerStyle)),
          ],
        ),
        const TableRow(children: [SizedBox(height: 8), SizedBox(), SizedBox()]),

        // 內容列
        _row('可分享 Tales 數量', Text('10', style: cellStyle), const Text('無限', style: cellStyle)),
        _row('建立 Co-Tales（多人合作）', _cross(), _tick()),
        _row('收藏 Tales 數量', const Text('限制', style: cellStyle), const Text('更多', style: cellStyle)),
        _row('優先客服支援', _cross(), _tick()),
        _row('專屬功能持續解鎖', _cross(), _tick()),
      ],
    );
  }
}

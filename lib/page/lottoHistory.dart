import 'package:flutter/material.dart';

class CheckRewardHistoryPage extends StatefulWidget {
  const CheckRewardHistoryPage({super.key});

  @override
  State<CheckRewardHistoryPage> createState() => _CheckRewardHistoryPageState();
}

class _CheckRewardHistoryPageState extends State<CheckRewardHistoryPage> {
  // ข้อมูลจำลอง (dummy data) ไว้แสดงใน ListView
  final List<Map<String, String>> history = [
    {"date": "12 ก.ย. 2565", "number": "123456", "result": "ถูกรางวัลเลขท้าย 2 ตัว"},
    {"date": "16 ส.ค. 2565", "number": "987654", "result": "ไม่ถูกรางวัล"},
    {"date": "1 ส.ค. 2565", "number": "555555", "result": "ถูกรางวัลที่ 5"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        title: Image.network(
          'https://raw.githubusercontent.com/FarmHouse2263/lotto/refs/heads/main/image%202.png',
          height: 30,
          width: 80,
          fit: BoxFit.cover,
        ),
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: ListTile(
              leading: const Icon(Icons.history),
              title: Text("งวดวันที่: ${item['date']}"),
              subtitle: Text("หมายเลข: ${item['number']}\nผล: ${item['result']}"),
            ),
          );
        },
      ),
    );
  }
}

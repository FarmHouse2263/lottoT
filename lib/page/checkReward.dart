import 'package:flutter/material.dart';

class CheckRewardPage extends StatefulWidget {
  const CheckRewardPage({super.key});

  @override
  State<CheckRewardPage> createState() => _CheckRewardPageState();
}

class _CheckRewardPageState extends State<CheckRewardPage> {
  final TextEditingController _controller = TextEditingController();
  String? result;

  // mock ข้อมูลรางวัล
  final String winningNumber = "253795";

  void checkReward() {
    setState(() {
      if (_controller.text == winningNumber) {
        result = "🎉 ยินดีด้วย! ถูกรางวัล 1 (50,000 บาท)";
      } else {
        result = "😢 ไม่ถูกรางวัล";
      }
    });
  }

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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "กรอกเลขหวย",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: checkReward,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            if (result != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: result!.contains("ยินดี")
                      ? Colors.green[100]
                      : Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  result!,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

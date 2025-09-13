import 'package:flutter/material.dart';

class CheckRewardPage extends StatefulWidget {
  final List<Map<String, dynamic>> loctoList;

  const CheckRewardPage({super.key, required this.loctoList});

  @override
  State<CheckRewardPage> createState() => _CheckRewardPageState();
}

class _CheckRewardPageState extends State<CheckRewardPage> {
  final TextEditingController _controller = TextEditingController();
  String result = "";
  final String winningNumber = "253795"; // mock เลขถูกรางวัล
  bool showBoughtOnly = false;

  void checkReward() {
    setState(() {
      if (_controller.text == winningNumber) {
        result = "win";
      } else {
        result = "lose";
      }
    });
  }

  void buyData(int index) {
    setState(() {
      if (widget.loctoList[index]['status'] == 'มีอยู่') {
        widget.loctoList[index]['status'] = 'ซื้อแล้ว';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // กรองรายการตาม showBoughtOnly
    final displayedList = showBoughtOnly
        ? widget.loctoList
              .where((item) => item['status'] == 'ซื้อแล้ว')
              .toList()
        : widget.loctoList;

    return Scaffold(
      appBar: AppBar(
        title: Image.network(
          'https://raw.githubusercontent.com/FarmHouse2263/lotto/refs/heads/main/image%202.png',
          width: 80,
        ),
      ),
      body: Column(
        children: [
          // ช่องกรอกเลข + ปุ่มตรวจรางวัล
          // ปุ่มสลับการแสดงผล
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => showBoughtOnly = true),
                    child: const Text("แสดงที่ซื้อแล้ว"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: showBoughtOnly
                          ? Colors.orange[400]
                          : Colors.grey[300],
                      foregroundColor: showBoughtOnly
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => showBoughtOnly = false),
                    child: const Text("แสดงทั้งหมด"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !showBoughtOnly
                          ? const Color.fromARGB(255, 222, 192, 44)
                          : Colors.grey[300],
                      foregroundColor: !showBoughtOnly
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "กรอกเลขหวย",
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: checkReward,
                  child: Icon(Icons.search,size: 30,),
                  
                ),
              ],
            ),
          ),

          // แสดงรายการหวย
          Expanded(
            child: ListView.builder(
              itemCount: displayedList.length,
              itemBuilder: (context, index) {
                final lotto = displayedList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text("เลข: ${lotto['number']}"),
                    subtitle: Text(
                      "ราคา: ${lotto['price']} | งวดที่: ${lotto['round']}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(lotto['status']),
                        const SizedBox(width: 8),
                        if (lotto['status'] == 'มีอยู่')
                          ElevatedButton(
                            onPressed: () =>
                                buyData(widget.loctoList.indexOf(lotto)),
                            child: const Text("ซื้อ"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightGreen,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // แสดงผลการตรวจรางวัล
          if (result.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                result == "win"
                    ? "🎉 ถูกรางวัลเลข: $winningNumber"
                    : "😢 ไม่ถูกรางวัลเลข: ${_controller.text}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: result == "win" ? Colors.green : Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lotto/page/checkReward.dart';
import 'package:lotto/page/lottoHistory.dart';
import 'package:lotto/page/profileFram.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> lottoList = [
    {'number': '253795', 'price': 100, 'status': 'มีอยู่', 'round': 1},
    {'number': '112233', 'price': 80, 'status': 'หมด', 'round': 2},
    {'number': '998877', 'price': 120, 'status': 'มีอยู่', 'round': 3},
    {'number': '445566', 'price': 100, 'status': 'มีอยู่', 'round': 4},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Image.network(
          'https://raw.githubusercontent.com/FarmHouse2263/lotto/refs/heads/main/image%202.png',
          height: 30,
          width: 80,
          fit: BoxFit.cover,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header + ปุ่มตรวจรางวัล
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'LOTTO',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.orange[200],
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckRewardPage(
                              loctoList: lottoList,
                            ),
                          ),
                        );
                      },
                      child: const Text('ตรวจรางวัล'),
                    ),
                  ],
                ),
              ),

              // แสดงรายการล็อตเตอรี่
              ...lottoList.map(
                (item) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 232, 232, 232),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'เลขหวย: ${item["number"]}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ราคา: ${item["price"]}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'สถานะ: ${item["status"]}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'งวดที่: ${item["round"]}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          FilledButton(
                            onPressed: item['status'] == 'มีอยู่'
                                ? () => buyData(lottoList.indexOf(item))
                                : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: item['status'] == 'มีอยู่'
                                  ? Colors.lightGreenAccent
                                  : Colors.grey,
                              foregroundColor: Colors.black,
                            ),
                            child: Text(
                              item['status'] == 'มีอยู่' ? 'ซื้อ' : 'ซื้อแล้ว',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.purple[300],
        unselectedItemColor: Colors.grey[600],
        onTap: (index) {
          if (index == 0) {
            // อยู่หน้า Home
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckRewardPage(loctoList: lottoList),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CheckRewardHistoryPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'ตรวจหวย'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'ประวัติ'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  void buyData(int index) {
    setState(() {
      if (lottoList[index]['status'] == 'มีอยู่') {
        lottoList[index]['status'] = 'ซื้อแล้ว';
      }
    });
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/config.dart';
import 'package:flutter_application_1/pages/checkReward.dart';
import 'package:flutter_application_1/pages/lottoHistory.dart';
import 'package:flutter_application_1/pages/profile.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final bool isAdmin;
  final int userId;

  const HomePage({
    super.key,
    this.isAdmin = false,
    required this.userId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String url = "";
  bool isLoadingConfig = true;
  bool isLoadingTickets = true;
  bool currentDrawOpen = false;

  final List<Map<String, dynamic>> lottoList = [];
  int latestDrawId = 0;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await AppConfig.load();
    setState(() {
      url = config.apiEndpoint;
      isLoadingConfig = false;
    });
    await fetchTickets();
  }

  // ซื้อ Lotto
  Future<void> buyLotto(int index) async {
    final item = lottoList[index];
    if (item['status'] != 'มีอยู่' || !currentDrawOpen) return;

    try {
      final response = await http.post(
        Uri.parse("$url/tickets/buy/${item['ticket_id']}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": widget.userId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          lottoList[index]['status'] = 'ซื้อแล้ว';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ซื้อ Lotto สำเร็จ')),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ซื้อ Lotto ไม่สำเร็จ: ${data['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  // สร้างงวดใหม่ (Admin)
  Future<String> createLottoDraw() async {
    if (!widget.isAdmin) return "คุณไม่มีสิทธิ์สร้างงวดใหม่";
    if (currentDrawOpen) return "ยังมีงวดที่เปิดอยู่ ไม่สามารถสร้างใหม่ได้";

    try {
      final response = await http.post(Uri.parse("$url/tickets/draws"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await fetchTickets();
        return "สร้างงวดใหม่สำเร็จ (ID: ${data['drawId']})";
      } else {
        return "สร้างงวดไม่สำเร็จ (${response.statusCode})";
      }
    } catch (e) {
      return "เกิดข้อผิดพลาด: $e";
    }
  }

  // ปิดการซื้อขาย (Admin)
  Future<void> closeCurrentDraw() async {
    if (!widget.isAdmin || !currentDrawOpen) return;

    try {
      if (latestDrawId == 0) return;

      final response =
          await http.post(Uri.parse("$url/tickets/draws/$latestDrawId/close"));

      if (response.statusCode == 200) {
        setState(() {
          currentDrawOpen = false;
          lottoList.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ปิดการซื้อขายเรียบร้อย")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("ปิดการซื้อขายไม่สำเร็จ (${response.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
      );
    }
  }

  // ดึง ticket ล่าสุด
  Future<void> fetchTickets() async {
    if (url.isEmpty) return;
    setState(() {
      isLoadingTickets = true;
    });

    try {
      final response = await http.get(Uri.parse("$url/tickets"));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          latestDrawId = data
              .map((item) => item['draw_id'] as int)
              .reduce((a, b) => a > b ? a : b);

          final latestTickets =
              data.where((item) => item['draw_id'] == latestDrawId);

          setState(() {
            lottoList.clear();
            lottoList.addAll(latestTickets.map((item) => {
                  'ticket_id': item['ticket_id'],
                  'number': item['ticket_number'],
                  'price': item['price'],
                  'status':
                      item['status'] == 'available' ? 'มีอยู่' : 'ซื้อแล้ว',
                  'round': item['draw_id'],
                }));
            currentDrawOpen =
                lottoList.any((item) => item['status'] == 'มีอยู่');
          });
        } else {
          setState(() {
            lottoList.clear();
            currentDrawOpen = false;
          });
        }
      }
    } catch (e) {
      print("Error fetchTickets: $e");
    } finally {
      setState(() {
        isLoadingTickets = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Image.network(
          'https://raw.githubusercontent.com/FarmHouse2263/lotto/refs/heads/main/image%202.png',
          height: 80,
          width: 80,
          fit: BoxFit.cover,
        ),
      ),
      body: SafeArea(
        child: isLoadingConfig
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header + ปุ่มตรวจรางวัล + ปุ่ม admin
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Header section with Lotto title and Check Reward button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Lotto',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange[300]!,
                                      Colors.orange[400]!
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white,
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CheckRewardPage(
                                          drawId: latestDrawId,
                                          apiEndpoint: url,
                                          userId: widget.userId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Icon(Icons.card_giftcard, size: 18),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'ตรวจรางวัล',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Admin controls section (if admin)
                          if (widget.isAdmin) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Admin Controls',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            gradient: currentDrawOpen
                                                ? LinearGradient(
                                                    colors: [
                                                      Colors.grey[300]!,
                                                      Colors.grey[400]!
                                                    ],
                                                  )
                                                : LinearGradient(
                                                    colors: [
                                                      Colors.green[300]!,
                                                      Colors.green[400]!
                                                    ],
                                                  ),
                                            boxShadow: currentDrawOpen
                                                ? null
                                                : [
                                                    BoxShadow(
                                                      color: Colors.green
                                                          .withOpacity(0.3),
                                                      spreadRadius: 1,
                                                      blurRadius: 3,
                                                      offset: Offset(0, 1),
                                                    ),
                                                  ],
                                          ),
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            onPressed: currentDrawOpen
                                                ? null
                                                : () async {
                                                    final result =
                                                        await createLottoDraw();
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            content:
                                                                Text(result)),
                                                      );
                                                    }
                                                  },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.add_circle_outline,
                                                    size: 18),
                                                const SizedBox(width: 8),
                                                const Text(
                                                  'สร้าง Lotto',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            gradient: currentDrawOpen
                                                ? LinearGradient(
                                                    colors: [
                                                      Colors.red[300]!,
                                                      Colors.red[400]!
                                                    ],
                                                  )
                                                : LinearGradient(
                                                    colors: [
                                                      Colors.grey[300]!,
                                                      Colors.grey[400]!
                                                    ],
                                                  ),
                                            boxShadow: currentDrawOpen
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.red
                                                          .withOpacity(0.3),
                                                      spreadRadius: 1,
                                                      blurRadius: 3,
                                                      offset: Offset(0, 1),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            onPressed: currentDrawOpen
                                                ? closeCurrentDraw
                                                : null,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.stop_circle_outlined,
                                                    size: 18),
                                                const SizedBox(width: 8),
                                                const Text(
                                                  'ปิดการซื้อขาย',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // แสดงเลขล็อตโต้ หรือข้อความเมื่อไม่มี draw active
                    if (isLoadingTickets)
                      const Center(child: CircularProgressIndicator())
                    else if (lottoList.isEmpty)
                      const Center(
                        child: Text(
                          'ยังไม่มีการซื้อขาย หรือกำลังประกาศรางวัล',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      )
                    else
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'งวดที่: ${item["round"]}',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  FilledButton(
                                    onPressed: item['status'] == 'มีอยู่' &&
                                            currentDrawOpen
                                        ? () =>
                                            buyLotto(lottoList.indexOf(item))
                                        : null,
                                    style: FilledButton.styleFrom(
                                      backgroundColor:
                                          item['status'] == 'มีอยู่' &&
                                                  currentDrawOpen
                                              ? Colors.lightGreenAccent
                                              : Colors.grey,
                                      foregroundColor: Colors.black,
                                    ),
                                    child: Text(
                                      item['status'] == 'มีอยู่' &&
                                              currentDrawOpen
                                          ? 'ซื้อ'
                                          : 'ซื้อแล้ว',
                                    ),
                                  )
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
                  builder: (context) => CheckRewardPage(
                        drawId: latestDrawId,
                        apiEndpoint: url,
                        userId: widget.userId,
                      )),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckRewardHistoryPage(
                  userId: widget.userId,
                  apiEndpoint: url, // url ของ API endpoint
                ),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(userId: widget.userId),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'ตรวจหวย'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'ประวัติ'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

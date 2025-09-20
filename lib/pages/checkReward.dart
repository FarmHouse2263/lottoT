import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/lottoHistory.dart';
import 'package:flutter_application_1/pages/profile.dart';
import 'package:http/http.dart' as http;

class CheckRewardPage extends StatefulWidget {
  final int drawId; // งวดที่ต้องการตรวจ
  final String apiEndpoint; // URL ของ Backend
  final int userId; // รหัสผู้ใช้

  const CheckRewardPage({
    super.key,
    required this.drawId,
    required this.apiEndpoint,
    required this.userId,
  });

  @override
  State<CheckRewardPage> createState() => _CheckRewardPageState();
}

class _CheckRewardPageState extends State<CheckRewardPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> myTickets = [];
  String drawStatus = "active"; // สถานะงวด: active/closed
  String selectedTab = "ทั้งหมด"; // Current selected tab

  @override
  void initState() {
    super.initState();
    fetchRewards();
  }

  Future<void> claimReward(int purchaseId) async {
    try {
      final response = await http.post(
        Uri.parse("${widget.apiEndpoint}/tickets/claim"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "purchaseId": purchaseId,
          "userId": widget.userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ขึ้นรางวัลแล้ว: ${data['amount']} บาท")),
        );

        // รีโหลดข้อมูลใหม่
        fetchRewards();
      } else {
        final err = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ผิดพลาด: ${err['error']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> fetchRewards() async {
    try {
      final response = await http.get(Uri.parse(
          "${widget.apiEndpoint}/tickets/reward/${widget.drawId}/${widget.userId}"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        setState(() {
          drawStatus = data['drawStatus'];
          myTickets = (data['rewards'] as List)
              .map((e) => {
                    'purchase_id': e['purchase_id'],
                    'ticket_number': e['ticket_number'],
                    'status': e['status'],
                    'prize': e['prize'],
                    'prize_type': e['prize_type'],
                    'already_claimed': e['already_claimed'] ?? false,
                    'claimed':
                        e['status'] == 'win' && (e['already_claimed'] ?? false),
                  })
              .toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print("Failed to fetch rewards: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetchRewards: $e");
    }
  }

  Widget _buildTabButton(String title) {
    bool isSelected = selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = title;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange[300] : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> item, int index) {
    bool isWin = item['status'] == 'win';
    bool isClaimed = item['claimed'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // หัวข้อ
          Text(
            isWin ? "รางวัลที่ ${index + 1}" : "ไม่ถูกรางวัล",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // เลขหวย
          Text(
            "เลขหวย : ${item['ticket_number']}",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),

          // สถานะ
          Text(
            "สถานะ : ${_getStatusText(item['status'])}",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),

          // งวดที่
          Text(
            "งวดที่ : ${widget.drawId}",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),

          // จำนวนเงิน
          Text(
            "จำนวนเงิน : ${isWin ? '${item['prize'] ?? 0}' : '--'}",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // ปุ่ม
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isWin && !isClaimed
                  ? () => claimReward(item['purchase_id'] as int)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isWin && !isClaimed ? Colors.green[400] : Colors.grey[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _getButtonText(item),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'win':
        return 'ถูกรางวัล';
      case 'lose':
        return 'ไม่ถูก';
      case 'pending':
        return 'รอประกาศ';
      default:
        return 'ไม่ทราบสถานะ';
    }
  }

  String _getButtonText(Map<String, dynamic> item) {
    if (item['status'] == 'win') {
      return item['claimed'] ? "ขึ้นรางวัลแล้ว" : "รับรางวัล";
    } else {
      return "ถูกแดก";
    }
  }

  List<Map<String, dynamic>> _getDisplayTickets() {
    if (selectedTab == "ถูก") {
      return myTickets.where((ticket) => ticket['status'] == 'win').toList();
    }
    return myTickets;
  }

  @override
  Widget build(BuildContext context) {
    final displayTickets = _getDisplayTickets();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Image.network(
          'https://raw.githubusercontent.com/FarmHouse2263/lotto/refs/heads/main/image%202.png',
          height: 30,
          width: 80,
          fit: BoxFit.cover,
        ),
      ),
      body: Column(
        children: [
          // Tab buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildTabButton("ทั้งหมด"),
                const SizedBox(width: 8),
                _buildTabButton("ถูก"),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    "เลขหวย",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.search,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayTickets.isEmpty
                    ? Center(
                        child: Text(
                          selectedTab == "ถูก"
                              ? "ไม่มีรางวัลที่ถูก"
                              : "คุณยังไม่มีเลขในงวดนี้",
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: displayTickets.length,
                        itemBuilder: (context, index) {
                          return _buildTicketCard(displayTickets[index], index);
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.purple[300],
        unselectedItemColor: Colors.grey[600],
        // แก้ไข BottomNavigationBar onTap
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.popUntil(
                  context, (route) => route.isFirst); // กลับหน้า Home
              break;
            case 1:
              // ไม่ต้อง push ตัวเองซ้ำ
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckRewardHistoryPage(
                    userId: widget.userId,
                    apiEndpoint: widget.apiEndpoint,
                  ),
                ),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(userId: widget.userId),
                ),
              );
              break;
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

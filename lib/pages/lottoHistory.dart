import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/profile.dart';
import 'package:http/http.dart' as http;

class CheckRewardHistoryPage extends StatefulWidget {
  final int userId;
  final String apiEndpoint;

  const CheckRewardHistoryPage({
    super.key,
    required this.userId,
    required this.apiEndpoint,
  });

  @override
  State<CheckRewardHistoryPage> createState() => _CheckRewardHistoryPageState();
}

class _CheckRewardHistoryPageState extends State<CheckRewardHistoryPage> {
  List<Map<String, dynamic>> history = [];
  bool isLoading = true;
  bool showOnlyWon = false;
  String selectedTab = "ทั้งหมด";

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      final response = await http.get(
        Uri.parse("${widget.apiEndpoint}/tickets/history/${widget.userId}"),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> data = json['history'] ?? [];

        setState(() {
          history = data.map((e) {
            return {
              'ticket_number':
                  e['ticket_number'] ?? e['number'] ?? 'ไม่พบเลขหวย',
              'price': e['price'] ?? 0,
              'reward_amount': e['reward_amount'] ?? 0,
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('โหลดประวัติไม่สำเร็จ (${response.statusCode})')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Widget _buildTabButton(String title) {
    bool isSelected = selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = title;
            showOnlyWon = title == "ถูกรางวัล";
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

  Widget _buildHistoryCard(Map<String, dynamic> item, int index) {
    final rewardAmount = int.tryParse(item['reward_amount']?.toString() ?? '0') ?? 0;
    final won = rewardAmount > 0;
    final ticketNumber = item['ticket_number'];
    
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
            won ? "รางวัลที่ ${index + 1}" : "ไม่ถูกรางวัล",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          
          // เลขหวย
          Text(
            "เลขหวย : $ticketNumber",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          
          // สถานะ
          Text(
            "สถานะ : ${won ? 'ถูกรางวัล' : 'ครอบครอง'}",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          
          // งวดที่
          Text(
            "งวดที่ : 1",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          
          // จำนวนเงิน
          Text(
            "จำนวนเงิน : ${won ? rewardAmount.toString() : '--'}",
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
              onPressed: won ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: won ? Colors.green[400] : Colors.grey[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                won ? "รับรางวัล" : "ไม่ถูกรางวัล",
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

  List<Map<String, dynamic>> _getFilteredHistory() {
    if (showOnlyWon) {
      return history.where((item) {
        final rewardAmount = int.tryParse(item['reward_amount']?.toString() ?? '0') ?? 0;
        return rewardAmount > 0;
      }).toList();
    }
    return history;
  }

  @override
  Widget build(BuildContext context) {
    final filteredHistory = _getFilteredHistory();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Image.network(
          'https://raw.githubusercontent.com/FarmHouse2263/lotto/refs/heads/main/image%202.png',
          height: 80,
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
                _buildTabButton("ถูกรางวัล"),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredHistory.isEmpty
                    ? Center(
                        child: Text(
                          selectedTab == "ถูกรางวัล" ? "ไม่มีรางวัลที่ถูก" : "ไม่มีประวัติ",
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredHistory.length,
                        itemBuilder: (context, index) {
                          return _buildHistoryCard(filteredHistory[index], index);
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
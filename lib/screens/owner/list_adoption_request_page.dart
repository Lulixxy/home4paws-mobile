// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use, unused_element

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home4paws/constants/api_config.dart';
import 'package:home4paws/screens/login_page.dart';
import 'package:http/http.dart' as http;
import '../../constants/app_colors.dart'; // ✅ Import สี

class ListAdoptionRequestPage extends StatefulWidget {
  final String? currentUsername;

  const ListAdoptionRequestPage({super.key, required this.currentUsername});

  @override
  State<ListAdoptionRequestPage> createState() =>
      _ListAdoptionRequestPageState();
}

class _ListAdoptionRequestPageState extends State<ListAdoptionRequestPage> {
  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  // ดึงข้อมูลคำขอที่เข้ามา
  Future<void> _fetchRequests() async {
    if (widget.currentUsername == null) return;

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(
        "${ApiConfig.incomingRequests}?username=${widget.currentUsername}",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _requests = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _requests = [];
          _isLoading = false;
        });
        print("Error fetch: ${response.body}");
      }
    } catch (e) {
      print("Error connecting: $e");
      setState(() => _isLoading = false);
    }
  }

  // ฟังก์ชันอนุมัติ
  Future<void> _approveRequest(String requestId, String animalName) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "ยืนยันการอนุมัติ",
              style: TextStyle(
                color: AppColors.textDarkGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              "คุณต้องการมอบสิทธิ์การเลี้ยงดูน้อง \"$animalName\" ให้กับผู้ขอนี้ใช่หรือไม่?\n\n(คำขอของคนอื่นสำหรับสัตว์ตัวนี้จะถูกปฏิเสธโดยอัตโนมัติ)",
              style: const TextStyle(color: AppColors.textDarkGreen),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "ยกเลิก",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                ),
                child: const Text(
                  "ยืนยันอนุมัติ",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
    );

    try {
      final url = Uri.parse("${ApiConfig.approveRequest}/$requestId/approve");
      final response = await http.post(url);

      Navigator.pop(context);

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.primaryGreen),
                SizedBox(width: 10),
                Text(
                  "สำเร็จ!",
                  style: TextStyle(color: AppColors.textDarkGreen),
                ),
              ],
            ),
            content: const Text(
              "บันทึกการรับเลี้ยงเรียบร้อยแล้วค่ะ 🎉",
              style: TextStyle(color: AppColors.textDarkGreen),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(c);
                  _fetchRequests();
                },
                child: const Text(
                  "ตกลง",
                  style: TextStyle(color: AppColors.primaryGreen),
                ),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("เกิดข้อผิดพลาด: ${response.body}"),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // UI ส่วนแสดงผล
  @override
  Widget build(BuildContext context) {
    if (widget.currentUsername == null) {
      return const LoginPage();
    }

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text("คำขอรับเลี้ยงที่รออยู่ 📬"),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            )
          : _requests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 80,
                    color: AppColors.textDarkGreen.withOpacity(0.2),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "ยังไม่มีคำขอใหม่เข้ามาค่ะ",
                    style: TextStyle(
                      color: AppColors.textDarkGreen.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final req = _requests[index];
                return _buildRequestCard(req);
              },
            ),
    );
  }

  Widget _buildRequestCard(dynamic req) {
    final String requestId = req['requestId'];
    final String animalName = req['animalName'] ?? "Unknown";
    final String animalImage = req['animalImage'] ?? "";

    final String adopterName = req['adopterName'] ?? "Unknown";
    final String phone = req['adopterPhone'] ?? "-";
    final String date = req['requestDate'] ?? "-";
    final String adopterImage = req['adopterImage'] ?? ""; // รับค่ารูปภาพมา

    final String province = req['adopterAddress'] ?? "-";
    final String houseType = req['adopterAddType'] ?? "-";
    final String age = req['adopterAge']?.toString() ?? "-";

    final double incomeVal = req['adopterIncome'] ?? 0.0;
    final String income = "${incomeVal.toStringAsFixed(0)} ฿";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // ZONE 1: Header (สัตว์ที่ถูกขอ)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.accentCopper.withOpacity(0.15),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: animalImage.isNotEmpty
                      ? Image.memory(
                          base64Decode(animalImage),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          color: AppColors.white,
                          child: Icon(
                            Icons.pets,
                            color: AppColors.accentCopper.withOpacity(0.5),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "คำขอรับเลี้ยงน้อง:",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textDarkGreen.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      animalName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDarkGreen,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textDarkGreen.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ZONE 2: ข้อมูลผู้ขอ
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ชื่อและอายุ
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                      radius: 26,
                      backgroundImage: adopterImage.isNotEmpty
                          ? MemoryImage(base64Decode(adopterImage))
                          : null,
                      child: adopterImage.isEmpty
                          ? const Icon(
                              Icons.person,
                              color: AppColors.primaryGreen,
                              size: 28,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            adopterName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDarkGreen,
                            ),
                          ),
                          Text(
                            "อายุ $age ปี",
                            style: TextStyle(
                              color: AppColors.textDarkGreen.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                          // เพิ่มส่วนแสดงจังหวัด
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on, // ไอคอนหมุด
                                color: AppColors.errorRed, // สีแดงให้เด่น
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  province, // แสดงชื่อจังหวัด
                                  style: const TextStyle(
                                    color: AppColors.textDarkGreen,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          // ✅✅ จบส่วนเพิ่มจังหวัด
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // การ์ดข้อมูลย่อย
                Row(
                  children: [
                    // รายได้
                    Expanded(
                      child: _buildInfoBox(
                        icon: Icons.monetization_on_rounded,
                        color: AppColors.primaryGreen,
                        label: "รายได้/เดือน",
                        value: income,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // ที่อยู่ (ปรับ Label ออก เพราะโชว์จังหวัดข้างบนแล้ว)
                    Expanded(
                      child: _buildInfoBox(
                        icon: Icons.home_work_rounded,
                        color: AppColors.accentCopper,
                        label: "ประเภทที่พัก", // เอา ($province) ออกจะได้ไม่ซ้ำ
                        value: houseType,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // เบอร์โทร
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgCream,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone_in_talk,
                        color: AppColors.textDarkGreen.withOpacity(0.5),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        phone,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDarkGreen,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ZONE 3: Action Buttons
          Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("ระบบปฏิเสธยังไม่เปิดใช้งาน"),
                        backgroundColor: Colors.grey,
                      ),
                    );
                  },
                  icon: const Icon(Icons.close, color: AppColors.errorRed),
                  label: const Text(
                    "ปฏิเสธ",
                    style: TextStyle(color: AppColors.errorRed),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.grey.withOpacity(0.2),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _approveRequest(requestId, animalName),
                  icon: const Icon(
                    Icons.check_circle,
                    color: AppColors.primaryGreen,
                  ),
                  label: const Text(
                    "อนุมัติ",
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget ย่อยสำหรับสร้างกล่องข้อมูล
  Widget _buildInfoBox({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textDarkGreen,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

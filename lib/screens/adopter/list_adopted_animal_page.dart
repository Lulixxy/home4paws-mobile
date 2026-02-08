// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home4paws/constants/api_config.dart';
import 'package:home4paws/constants/app_colors.dart';
import 'package:http/http.dart' as http;
import '../monitor_animal_page.dart';

class ListAdoptedAnimalPage extends StatefulWidget {
  final String username;
  const ListAdoptedAnimalPage({super.key, required this.username});

  @override
  State<ListAdoptedAnimalPage> createState() => _ListAdoptedAnimalPageState();
}

class _ListAdoptedAnimalPageState extends State<ListAdoptedAnimalPage> {
  List<dynamic> _myAdoptedAnimals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdoptedAnimals();
  }

  // ดึงข้อมูลจาก API
  Future<void> _fetchAdoptedAnimals() async {
    final String url =
        "${ApiConfig.adoptionHistory}?username=${widget.username}";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        if (mounted) {
          setState(() {
            _myAdoptedAnimals = [];
            for (var item in data) {
              String status = item['requestStatus'] ?? 'Pending';

              if (status == 'Approved' ||
                  status == 'Completed' ||
                  status == 'Handover') {
                Map<String, dynamic> uiData = {
                  "adoptionId": item['adoptionId'],
                  "animalName": item['animalName'] ?? "Unknown",
                  "animalImage": item['animalImage'] ?? "",
                  "status": status,
                  "date": item['requestDate'],
                };
                _myAdoptedAnimals.add(uiData);
              }
            }
            _isLoading = false;
          });
        }
      } else {
        print("Error fetching data: ${response.statusCode}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Exception: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text(
          "รายการสัตว์ที่รับเลี้ยง",
          style: TextStyle(
            color: AppColors.textDarkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textDarkGreen,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            )
          : _buildList(),
    );
  }

  Widget _buildList() {
    if (_myAdoptedAnimals.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _myAdoptedAnimals.length,
      separatorBuilder: (c, i) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        final item = _myAdoptedAnimals[index];
        return _buildAdoptedCard(item);
      },
    );
  }

  // การ์ดแสดงสัตว์ที่รับเลี้ยง
  Widget _buildAdoptedCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // ไปยังหน้าติดตามสัตว์ที่รับเลี้ยง
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MonitorAnimalPage(
                  adoptionId: item['adoptionId'],
                  animalName: item['animalName'],
                  animalImage: item['animalImage'],
                  canPost: true,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 1. รูปภาพ
                Hero(
                  tag: 'pet_${item['adoptionId']}',
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: AppColors.bgCream,
                      image:
                          (item['animalImage'] != null &&
                              item['animalImage'].isNotEmpty)
                          ? DecorationImage(
                              image: MemoryImage(
                                base64Decode(item['animalImage']),
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child:
                        (item['animalImage'] == null ||
                            item['animalImage'].isEmpty)
                        ? Icon(
                            Icons.pets,
                            color: AppColors.primaryGreen.withOpacity(0.3),
                            size: 40,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 15),

                // 2. ข้อมูลตรงกลาง
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ชื่อสัตว์
                      Text(
                        item['animalName'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDarkGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // วันที่รับ
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "รับเมื่อ: ${_formatDate(item['date'])}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentCopper,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentCopper.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 5),
                            Text(
                              "อัปเดตชีวิตน้อง",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. ลูกศรขวาสุด
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // หน้าจอว่างเปล่า
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.volunteer_activism,
              size: 60,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "ยังไม่มีสัตว์ที่รับเลี้ยง",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "น้องๆ กำลังรอคุณอยู่ที่หน้าแรกนะ 🐶🐱",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return "${dt.day}/${dt.month}/${dt.year}";
    } catch (e) {
      return dateStr;
    }
  }
}

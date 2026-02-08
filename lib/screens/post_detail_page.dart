// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../constants/app_colors.dart';
import '../models/post_animal.dart';
import 'login_page.dart';

class PostDetailPage extends StatelessWidget {
  final PostAnimal animal;
  final bool isGuest;
  final String? currentUsername;
  final bool isRequested;

  const PostDetailPage({
    super.key,
    required this.animal,
    this.isGuest = true,
    this.currentUsername,
    this.isRequested = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMale = animal.gender.toLowerCase() == 'male';
    final genderColor = isMale ? Colors.blue.shade100 : Colors.pink.shade100;
    final genderIconColor = isMale
        ? Colors.blue.shade700
        : Colors.pink.shade700;
    final genderIcon = isMale ? Icons.male : Icons.female;

    // เช็คว่าเป็นเจ้าของโพสต์หรือไม่?
    bool isOwner =
        currentUsername != null && currentUsername == animal.username;

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: CustomScrollView(
        slivers: [
          // ส่วนรูปภาพด้านบน (App Bar)
          SliverAppBar(
            expandedHeight: 400.0,
            pinned: true,
            backgroundColor: AppColors.primaryGreen,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: AppColors.textDarkGreen,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'animal_${animal.animalName}',
                    child: animal.animalImage.isNotEmpty
                        ? Image.memory(
                            base64Decode(animal.animalImage),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildPlaceholderImage(),
                          )
                        : _buildPlaceholderImage(),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ส่วนรายละเอียด
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -30, 0),
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.bgCream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // ชื่อและเพศ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          animal.animalName,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDarkGreen,
                            height: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: genderColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          genderIcon,
                          color: genderIconColor,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // ที่อยู่
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 20,
                          color: AppColors.accentCopper,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            animal.location,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // การ์ดข้อมูล (ประเภท, อายุ)
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          "ประเภท",
                          animal.animalType,
                          Icons.pets,
                          Colors.orange.shade50,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildStatCard(
                          "อายุ",
                          "${animal.age} ปี",
                          Icons.cake,
                          Colors.purple.shade50,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // การ์ดสายพันธุ์
                  _buildWideStatCard(
                    "สายพันธุ์",
                    animal.breed,
                    Icons.category,
                    AppColors.primaryGreen.withOpacity(0.1),
                    AppColors.primaryGreen,
                  ),
                  const SizedBox(height: 30),

                  // นิสัย
                  const Text(
                    "เกี่ยวกับน้อง 📝",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Text(
                      animal.personality,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // ปุ่ม Action ด้านล่าง
      floatingActionButton: isOwner
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.accentCopper.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppColors.accentCopper.withOpacity(0.3),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_user, color: AppColors.accentCopper),
                  SizedBox(width: 8),
                  Text(
                    "นี่คือประกาศของคุณ",
                    style: TextStyle(
                      color: AppColors.accentCopper,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  // ถ้า isRequested เป็น true ให้ onPressed เป็น null (ปุ่มจะกดไม่ได้)
                  onPressed: isRequested
                      ? null
                      : () => _onRequestPressed(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    // สีตอนปุ่มถูก Disable (ขอแล้ว)
                    disabledBackgroundColor: Colors.grey[300],
                    elevation: isRequested ? 0 : 5, // ถ้าขอแล้วไม่ต้องมีเงา
                    shadowColor: AppColors.primaryGreen.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // เปลี่ยนไอคอนและสี
                      Icon(
                        isRequested
                            ? Icons.access_time_filled
                            : Icons.volunteer_activism,
                        color: isRequested ? Colors.grey : Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          // เปลี่ยนข้อความ
                          isRequested
                              ? "ส่งคำขอแล้ว (รอการตอบรับ)"
                              : "ส่งคำขอรับเลี้ยงน้อง",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            // เปลี่ยนสีตัวหนังสือ
                            color: isRequested ? Colors.grey : Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void _onRequestPressed(BuildContext context) {
    if (isGuest || currentUsername == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock, color: AppColors.primaryGreen),
              SizedBox(width: 10),
              Text(
                "สมาชิกเท่านั้น",
                style: TextStyle(color: AppColors.textDarkGreen),
              ),
            ],
          ),
          content: const Text(
            "กรุณาเข้าสู่ระบบเพื่อดำเนินการส่งคำขอรับเลี้ยง\nเราต้องการข้อมูลของคุณเพื่อความปลอดภัยของน้องสัตว์ค่ะ 🐾",
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "ไว้ก่อน",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
              ),
              child: const Text(
                "เข้าสู่ระบบ",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else {
      _showAdoptionRules(context);
    }
  }

  void _showAdoptionRules(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "ข้อควรรู้ก่อนรับเลี้ยง",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDarkGreen,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // เนื้อหา
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRuleSection(
                      "1. ความพร้อมของผู้เลี้ยง",
                      "• ท่านมีเวลาดูแล เอาใจใส่ และเล่นกับน้องหรือไม่?\n"
                          "• สมาชิกในครอบครัวหรือที่พักอาศัยอนุญาตให้เลี้ยงสัตว์หรือไม่?\n"
                          "• ท่านมีความพร้อมทางการเงินสำหรับค่าอาหารและค่ารักษาพยาบาลยามเจ็บป่วยหรือไม่?",
                      Icons.accessibility_new,
                    ),
                    const SizedBox(height: 20),
                    _buildRuleSection(
                      "2. ความรับผิดชอบ",
                      "• การรับเลี้ยงคือภาระผูกพันระยะยาว (10-15 ปี)\n"
                          "• ห้ามนำสัตว์ไปทิ้งขว้าง หรือส่งต่อให้ผู้อื่นโดยไม่แจ้งเจ้าของเดิม",
                      Icons.favorite,
                    ),
                    const SizedBox(height: 20),
                    _buildRuleSection(
                      "3. ข้อตกลงทางกฎหมาย",
                      "• ห้ามนำสัตว์ไปซื้อ-ขายต่อในเชิงพาณิชย์เด็ดขาด 🚫\n"
                          "• ยินยอมให้เจ้าของเดิมติดต่อสอบถามความเป็นอยู่ได้เป็นครั้งคราว",
                      Icons.gavel,
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.bgCream,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.accentCopper.withOpacity(0.5),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.accentCopper,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "เมื่อกดยืนยัน จะถือว่าท่านยอมรับข้อตกลงและเงื่อนไขข้างต้นทั้งหมด",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDarkGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // ปุ่ม Confirm
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _sendAdoptRequest(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "ยอมรับและส่งคำขอ (Confirm)",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendAdoptRequest(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
    );

    try {
      final url = Uri.parse(ApiConfig.makeRequest);

      final body = jsonEncode({
        "username": currentUsername,
        "animalId": animal.animalId,
      });

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

      if (response.statusCode == 200 || response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.primaryGreen,
                  size: 30,
                ),
                SizedBox(width: 10),
                Text(
                  "ส่งคำขอสำเร็จ!",
                  style: TextStyle(color: AppColors.textDarkGreen),
                ),
              ],
            ),
            content: const Text(
              "เจ้าของโพสต์ได้รับคำขอแล้วค่ะ 💌\nกรุณารอการแจ้งเตือนจากเจ้าของสัตว์",
              style: TextStyle(color: AppColors.textDarkGreen),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // ปิดหน้า Detail
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
        String errorMessage = response.body;
        if (errorMessage.contains("already submitted")) {
          errorMessage = "คุณได้ส่งคำขอรับเลี้ยงน้องตัวนี้ไปแล้วค่ะ";
        }
        _showErrorSnackBar(context, errorMessage);
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      print("Error sending request: $e");
      _showErrorSnackBar(context, "เกิดข้อผิดพลาดในการเชื่อมต่อ: $e");
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  Widget _buildRuleSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.accentCopper),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDarkGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.bgCream,
      child: Center(
        child: Icon(Icons.pets, size: 80, color: Colors.grey.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
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

  Widget _buildWideStatCard(
    String title,
    String value,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDarkGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

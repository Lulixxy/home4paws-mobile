// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:home4paws/constants/app_colors.dart';
import 'owner/my_posts_page.dart';
import 'owner/list_adoption_request_page.dart';
import 'owner/list_approved_adoption_page.dart';
import 'adopter/list_adopted_animal_page.dart';

class ActivityMenuPage extends StatelessWidget {
  final String username;
  final VoidCallback? onPostUpdate;

  const ActivityMenuPage({
    super.key,
    required this.username,
    this.onPostUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text(
          "ศูนย์รวมกิจกรรม 📝",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        foregroundColor: AppColors.textDarkGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // โซน Owner
            _buildSectionHeader("🐶 สำหรับผู้หาบ้าน (Owner)"),
            const SizedBox(height: 10),

            _buildMenuCard(
              context,
              icon: Icons.edit_document,
              title: "ประกาศของฉัน",
              subtitle: "ดู แก้ไข หรือลบประกาศที่คุณลงไว้",
              color: AppColors.accentCopper.withOpacity(0.15),
              iconColor: AppColors.accentCopper,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => MyPostsPage(
                      username: username,
                      onPostUpdate: onPostUpdate,
                    ),
                  ),
                );
              },
            ),
            _buildMenuCard(
              context,
              icon: Icons.notifications_active_rounded,
              title: "คำขอรับเลี้ยงที่เข้ามา",
              subtitle: "ตรวจสอบและอนุมัติบ้านให้น้องๆ",
              color: AppColors.primaryGreen.withOpacity(0.15),
              iconColor: AppColors.primaryGreen,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) =>
                        ListAdoptionRequestPage(currentUsername: username),
                  ),
                );
              },
            ),
            _buildMenuCard(
              context,
              icon: Icons.assignment_turned_in_rounded,
              title: "ติดตามผลการรับเลี้ยง",
              subtitle: "บันทึกการส่งมอบ, ติดตามความเป็นอยู่",
              color: AppColors.textDarkGreen.withOpacity(0.15),
              iconColor: AppColors.textDarkGreen,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) =>
                        ListApprovedAdoptionPage(username: username),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // โซน Adopter
            _buildSectionHeader("🏠 สำหรับผู้รับเลี้ยง (Adopter)"),
            const SizedBox(height: 10),

            _buildMenuCard(
              context,
              icon: Icons.pets_rounded,
              title: "รายการสัตว์ที่รับเลี้ยง",
              subtitle: "ดูรายชื่อน้องๆ ที่คุณรับมาดูแล",
              color: Colors.blue.withOpacity(0.15),
              iconColor: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => ListAdoptedAnimalPage(username: username),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget ช่วยสร้าง Header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 5),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textDarkGreen,
        ),
      ),
    );
  }

  // Widget ช่วยสร้าง Card เมนู
  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDarkGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/screens/owner/my_posts_page.dart

// ignore_for_file: avoid_print, deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants/api_config.dart';
import '../../constants/app_colors.dart';
import '../../models/post_animal.dart';
import '../post_animal_page.dart';

class MyPostsPage extends StatefulWidget {
  final String username;
  final VoidCallback? onPostUpdate;

  const MyPostsPage({super.key, required this.username, this.onPostUpdate});

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  late Future<List<PostAnimal>> _futureMyPosts;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureMyPosts = _fetchMyPosts();
    });
  }

  // --- API: ดึงประกาศของฉัน ---
  Future<List<PostAnimal>> _fetchMyPosts() async {
    final String url = "${ApiConfig.listPostByUser}/${widget.username}";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> body = jsonDecode(responseBody);
        return body.map((item) => PostAnimal.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching my posts: $e");
      return [];
    }
  }

  // --- Logic: ลบประกาศ ---
  Future<void> _deletePost(String animalId) async {
    final url = "${ApiConfig.deletePost}/$animalId";
    print("🔴 Deleting: $url");

    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        print("✅ Delete Success");
        _loadData();
        widget.onPostUpdate?.call();

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("ลบประกาศเรียบร้อยแล้ว"),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(20),
          ),
        );
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("ลบไม่สำเร็จ: ${response.body}"),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      print("💥 Exception: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }

  void _confirmDelete(String animalId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.errorRed,
              size: 30,
            ),
            SizedBox(width: 10),
            Text(
              "ลบประกาศ?",
              style: TextStyle(
                color: AppColors.textDarkGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          "เมื่อลบแล้วจะไม่สามารถกู้คืนได้\nคุณแน่ใจหรือไม่ที่จะลบประกาศนี้?",
          style: TextStyle(fontSize: 14, color: AppColors.textDarkGreen),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => _deletePost(animalId),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "ลบประกาศ",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text(
          "ประกาศของฉัน 📝",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: AppColors.primaryGreen,
        child: FutureBuilder<List<PostAnimal>>(
          future: _futureMyPosts,
          builder: (context, snapshot) {
            // 1. Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              );
            }

            // 2. Empty or Error
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_off,
                      size: 80,
                      color: AppColors.textDarkGreen.withOpacity(0.2),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "คุณยังไม่เคยลงประกาศ",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textDarkGreen.withOpacity(0.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "กดปุ่ม + ที่หน้าหลักเพื่อเริ่มประกาศหาบ้าน",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textDarkGreen.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              );
            }

            // 3. List Data
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final animal = snapshot.data![index];
                return _buildManagementCard(animal);
              },
            );
          },
        ),
      ),
    );
  }

  // Widget การ์ดแบบใหม่: Management Style
  Widget _buildManagementCard(PostAnimal animal) {
    // --- 1. ส่วนกำหนด Logic สีและข้อความตามสถานะ ---
    String status = animal.animalStatus.toLowerCase();
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    if (status == 'available') {
      statusColor = AppColors.primaryGreen;
      statusLabel = "หาบ้านอยู่";
      statusIcon = Icons.check_circle;
    } else if (status == 'pending') {
      statusColor = AppColors.accentCopper;
      statusLabel = "รอตรวจสอบ";
      statusIcon = Icons.hourglass_bottom_rounded;
    } else {
      statusColor = Colors.grey;
      statusLabel = "ได้บ้านแล้ว";
      statusIcon = Icons.home;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. ส่วนข้อมูล (แสดงผลเฉยๆ กดไม่ได้)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // รูปภาพ
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 90,
                    height: 90,
                    color: AppColors.bgCream,
                    child: animal.animalImage.isNotEmpty
                        ? Image.memory(
                            base64Decode(animal.animalImage),
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.pets, color: Colors.grey[300]),
                  ),
                ),
                const SizedBox(width: 15),
                // ข้อมูล
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge สถานะ
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(statusIcon, size: 14, color: statusColor),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                      Text(
                        animal.animalName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDarkGreen,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "${animal.animalType} • ${animal.breed}",
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.cake,
                            size: 12,
                            color: AppColors.accentCopper,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${animal.age} ปี",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey[200]),

          // 2. ส่วนปุ่มจัดการ (Action Bar)
          Row(
            children: [
              // ปุ่มแก้ไข
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostAnimalPage(
                          username: widget.username,
                          animalToEdit: animal,
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadData();
                      widget.onPostUpdate?.call();
                    }
                  },
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppColors.accentCopper,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "แก้ไข",
                          style: TextStyle(
                            color: AppColors.accentCopper,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Container(width: 1, height: 25, color: Colors.grey[300]),

              // ปุ่มลบ
              Expanded(
                child: InkWell(
                  onTap: () => _confirmDelete(animal.animalId),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.errorRed,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "ลบประกาศ",
                          style: TextStyle(
                            color: AppColors.errorRed,
                            fontWeight: FontWeight.bold,
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
    );
  }
}

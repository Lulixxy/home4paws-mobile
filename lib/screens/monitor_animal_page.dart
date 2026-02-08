// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use, curly_braces_in_flow_control_structures

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:home4paws/constants/api_config.dart';
import 'package:home4paws/constants/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MonitorAnimalPage extends StatefulWidget {
  final String adoptionId;
  final String animalName;
  final String animalImage;
  final bool canPost; // true = Adopter (โพสต์ได้), false = Owner (รีวิวได้)

  const MonitorAnimalPage({
    super.key,
    required this.adoptionId,
    required this.animalName,
    required this.animalImage,
    this.canPost = true,
  });

  @override
  State<MonitorAnimalPage> createState() => _MonitorAnimalPageState();
}

class _MonitorAnimalPageState extends State<MonitorAnimalPage> {
  List<dynamic> _timelineList = [];
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchTimeline();
  }

  // 1. ดึงข้อมูล Timeline
  Future<void> _fetchTimeline() async {
    final String url =
        "${ApiConfig.wellbeingList}?adoptionId=${widget.adoptionId}";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _timelineList = jsonDecode(utf8.decode(response.bodyBytes));
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error fetching timeline: $e");
      setState(() => _isLoading = false);
    }
  }

  //  2. Adopter: อัปเดตชีวิตน้อง
  Future<void> _addNewUpdate(File imageFile, String description) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
    );

    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      final String url = ApiConfig.wellbeingAdd;

      Map<String, dynamic> body = {
        "adoptionId": widget.adoptionId,
        "images": base64Image,
        "description": description,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      Navigator.pop(context); // ปิด Loading

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("อัปเดตชีวิตน้องสำเร็จ! 🎉"),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        _fetchTimeline(); // รีโหลดหน้าจอ
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
      print("Error posting update: $e");
    }
  }

  //  3. Owner: ส่งรีวิว
  Future<void> _submitReview(
    String wellbeingId,
    double rating,
    String comment,
  ) async {
    // ใช้ URL จาก ApiConfig
    final String url = ApiConfig.addReview;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "rating": rating,
          "comment": comment,
          "wellbeingId": wellbeingId,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context); // ปิด Dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("ส่งรีวิวเรียบร้อย! ขอบคุณค่ะ ⭐"),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        _fetchTimeline(); // รีโหลดเพื่อโชว์ดาวที่เพิ่งให้ไป
      } else {
        print("Error submitting review: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("ส่งรีวิวไม่สำเร็จ ลองใหม่อีกครั้ง"),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      print("Exception submitting review: $e");
    }
  }

  //  Modal: สำหรับ Adopter เพิ่มโพสต์
  void _showAddModal() {
    File? selectedImage;
    TextEditingController descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 25,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "📸 อัปเดตความเป็นอยู่",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // เลือกรูป
                  GestureDetector(
                    onTap: () async {
                      final XFile? file = await _picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 800,
                      );
                      if (file != null)
                        setModalState(() => selectedImage = File(file.path));
                    },
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.bgCream,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.3),
                        ),
                        image: selectedImage != null
                            ? DecorationImage(
                                image: FileImage(selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: selectedImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_rounded,
                                  size: 50,
                                  color: AppColors.primaryGreen.withOpacity(
                                    0.5,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "แตะเพื่อเพิ่มรูปภาพ",
                                  style: TextStyle(
                                    color: AppColors.textDarkGreen.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ข้อความ
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "เล่าเรื่องราวน่ารักๆ ของวันนี้...",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.all(15),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // ปุ่มส่ง
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedImage != null && descCtrl.text.isNotEmpty) {
                          Navigator.pop(context);
                          _addNewUpdate(selectedImage!, descCtrl.text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "โพสต์เลย",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  //  Dialog: สำหรับ Owner ให้ดาว
  void _showReviewDialog(String wellbeingId) {
    double rating = 5.0;
    TextEditingController commentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "ให้คะแนนการดูแล 🌟",
          style: TextStyle(
            color: AppColors.textDarkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (ratingValue) => rating = ratingValue,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: commentCtrl,
              decoration: InputDecoration(
                labelText: "ความคิดเห็น (Optional)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryGreen),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () =>
                _submitReview(wellbeingId, rating, commentCtrl.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "ส่งรีวิว",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Diary ของน้อง 📔",
          style: TextStyle(
            color: AppColors.textDarkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white.withOpacity(0.8),
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
      body: SafeArea(
        child: Column(
          children: [
            //  Header: ข้อมูลสัตว์
            Container(
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              padding: const EdgeInsets.all(15),
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
              child: Row(
                children: [
                  Hero(
                    tag: 'pet_profile',
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accentCopper,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: AppColors.bgCream,
                        backgroundImage: widget.animalImage.isNotEmpty
                            ? MemoryImage(base64Decode(widget.animalImage))
                            : null,
                        child: widget.animalImage.isEmpty
                            ? const Icon(Icons.pets, color: Colors.grey)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "น้อง ${widget.animalName}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDarkGreen,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "สมาชิกครอบครัว 🏠",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //  Body: Timeline List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    )
                  : _timelineList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: _timelineList.length,
                      itemBuilder: (context, index) {
                        return _buildTimelineItem(
                          _timelineList[index],
                          index == _timelineList.length - 1,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      //  FAB: แสดงเฉพาะ Adopter
      floatingActionButton: widget.canPost
          ? FloatingActionButton.extended(
              onPressed: _showAddModal,
              backgroundColor: AppColors.accentCopper,
              elevation: 4,
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text(
                "เพิ่มบันทึก",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  //  Widget: สร้างแต่ละ Item ใน Timeline
  Widget _buildTimelineItem(dynamic item, bool isLast) {
    String dateStr = item['updateDate'] != null
        ? DateFormat('d MMM yyyy').format(DateTime.parse(item['updateDate']))
        : "-";
    String timeStr = item['updateDate'] != null
        ? DateFormat('HH:mm').format(DateTime.parse(item['updateDate']))
        : "";

    // ดึงข้อมูลรีวิว (ถ้ามี)
    final review = item['review'];
    bool hasReview = review != null;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. เส้น Timeline
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.accentCopper,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: Colors.grey[300])),
            ],
          ),
          const SizedBox(width: 15),

          // 2. การ์ดเนื้อหา
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDarkGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeStr,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item['images'] != null && item['images'].isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            child: Image.memory(
                              base64Decode(item['images']),
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            item['description'] ?? "",
                            style: const TextStyle(
                              color: AppColors.textDarkGreen,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ),

                        //  ส่วนแสดงรีวิว
                        if (hasReview) ...[
                          Container(
                            margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.amber.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "รีวิวจากเจ้าของ: ",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textDarkGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    RatingBarIndicator(
                                      rating: (review['rating'] ?? 0)
                                          .toDouble(),
                                      itemBuilder: (context, index) =>
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                      itemCount: 5,
                                      itemSize: 16.0,
                                      direction: Axis.horizontal,
                                    ),
                                  ],
                                ),
                                if (review['comment'] != null &&
                                    review['comment'].isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    "\"${review['comment']}\"",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textDarkGreen
                                          .withOpacity(0.8),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ]
                        // ถ้ายังไม่มีรีวิว + เป็น Owner -> แสดงปุ่มให้คะแนน
                        else if (!widget.canPost) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () =>
                                    _showReviewDialog(item['wellbeingId']),
                                icon: const Icon(
                                  Icons.star_rate_rounded,
                                  color: Colors.amber,
                                ),
                                label: const Text(
                                  "ให้คะแนน",
                                  style: TextStyle(
                                    color: AppColors.textDarkGreen,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.amber.withOpacity(
                                    0.1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //  Widget: หน้าจอว่างเปล่า
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
              Icons.auto_stories,
              size: 60,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "ยังไม่มีบันทึก",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDarkGreen,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "เรื่องราวดีๆ กำลังจะเริ่มต้นขึ้น...",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

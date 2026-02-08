// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../constants/api_config.dart';
import '../constants/app_colors.dart';

class NotificationPage extends StatefulWidget {
  final String username;

  const NotificationPage({super.key, required this.username});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  bool _hasChanges = false; // ตัวแปรเช็คว่ามีการกดอ่านไปบ้างหรือยัง

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final String url =
        "${ApiConfig.notificationList}?username=${widget.username}";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _notifications = jsonDecode(utf8.decode(response.bodyBytes));
            _isLoading = false;
          });
        }
      } else {
        print("Error fetching noti: ${response.statusCode}");
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Exception: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String notiId, int index) async {
    if (_notifications[index]['read'] == true) return;

    setState(() {
      _notifications[index]['read'] = true;
      _hasChanges = true; // Mark ว่ามีการเปลี่ยนแปลง
    });

    final String url = "${ApiConfig.baseUrl}/notifications/$notiId/read";
    try {
      await http.put(Uri.parse(url));
    } catch (e) {
      print("Mark read error: $e");
      // Optional: ถ้า Error อาจจะ setState กลับเป็น false ก็ได้ แต่ส่วนมากปล่อยผ่าน
    }
  }

  Widget _buildIcon(String? iconType) {
    // รับเป็น Nullable เผื่อ null
    IconData iconData;
    Color color;

    // ถ้าหลังบ้านส่งมาเป็น "fas fa-bell..." Code นี้จะตกไปที่ default
    switch (iconType) {
      case "new_request":
        iconData = Icons.pets;
        color = AppColors.accentCopper;
        break;
      case "approved":
        iconData = Icons.check_circle_outline;
        color = AppColors.primaryGreen;
        break;
      case "rejected":
        iconData = Icons.cancel_outlined;
        color = AppColors.errorRed;
        break;
      case "camera":
        iconData = Icons.camera_alt_outlined;
        color = Colors.blue;
        break;
      case "star":
        iconData = Icons.star_border_rounded;
        color = Colors.amber;
        break;
      default:
        // ถ้าไม่ตรงเคสไหนเลย หรือเป็นไอคอน FontAwesome String ให้ใช้รูปกระดิ่งทั่วไป
        iconData = Icons.notifications_active_outlined;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 24),
    );
  }

  // ฟังก์ชันกด Back แล้วส่งค่ากลับ
  void _onBackPressed() {
    Navigator.pop(context, _hasChanges); // ส่ง true กลับไปถ้ามีการอ่าน
  }

  @override
  Widget build(BuildContext context) {
    // PopScope ดักจับการกดปุ่ม Back ของ Android
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _onBackPressed();
      },
      child: Scaffold(
        backgroundColor: AppColors.bgCream,
        appBar: AppBar(
          title: const Text(
            "การแจ้งเตือน 🔔",
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
            // เรียกใช้ฟังก์ชันกดกลับของเรา
            onPressed: _onBackPressed,
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              )
            : _notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "ไม่มีการแจ้งเตือน",
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _fetchNotifications,
                color: AppColors.primaryGreen,
                child: ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final item = _notifications[index];
                    final bool isRead = item['read'] ?? false;

                    // กัน Error เรื่องวันที่
                    String dateStr = "";
                    try {
                      if (item['createDate'] != null) {
                        final date = DateTime.parse(item['createDate']);
                        dateStr = DateFormat('dd MMM HH:mm').format(date);
                      }
                    } catch (e) {
                      dateStr = "-"; // กรณีวันที่ผิด format
                    }

                    return GestureDetector(
                      onTap: () => _markAsRead(item['notificationId'], index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isRead
                              ? Colors.white.withOpacity(0.6)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: isRead
                              ? []
                              : [
                                  BoxShadow(
                                    color: AppColors.primaryGreen.withOpacity(
                                      0.1,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                          border: isRead
                              ? Border.all(color: Colors.grey.withOpacity(0.2))
                              : Border.all(
                                  color: AppColors.primaryGreen.withOpacity(
                                    0.3,
                                  ),
                                ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildIcon(item['icon']),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['briefMessage'] ?? "แจ้งเตือน",
                                          style: TextStyle(
                                            fontWeight: isRead
                                                ? FontWeight.normal
                                                : FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.textDarkGreen,
                                          ),
                                        ),
                                      ),
                                      if (!isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: AppColors.errorRed,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    item['message'] ?? "",
                                    style: TextStyle(
                                      color: isRead
                                          ? Colors.grey
                                          : AppColors.textDarkGreen.withOpacity(
                                              0.8,
                                            ),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    dateStr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

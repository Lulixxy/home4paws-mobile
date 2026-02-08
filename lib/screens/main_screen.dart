// lib/screens/main_screen.dart

// ignore_for_file: deprecated_member_use, avoid_print, curly_braces_in_flow_control_structures

import 'dart:convert'; // 1. สำหรับแปลง JSON
import 'package:http/http.dart' as http; // 2. สำหรับยิง API
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/api_config.dart'; // 3. Import ไฟล์ Config
import 'home_page.dart';
import 'search_page.dart';
import 'login_page.dart';
import 'post_animal_page.dart';
import 'activity_menu_page.dart';
import 'notification_page.dart';

class MainScreen extends StatefulWidget {
  final bool isGuest;
  final String? username;

  const MainScreen({super.key, this.isGuest = true, this.username});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // ตัวแปรเก็บสถานะจุดแดง (True = มีข้อความยังไม่อ่าน)
  bool _hasUnread = false;

  // Key สำหรับสั่งรีเฟรชหน้าต่างๆ
  Key _homeKey = UniqueKey();
  Key _activityKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    // เช็คแจ้งเตือนทันทีที่เปิดหน้านี้ (ถ้าไม่ใช่ Guest)
    if (!widget.isGuest) {
      _checkUnreadStatus();
    }
  }

  // ฟังก์ชันเช็คแจ้งเตือน
  Future<void> _checkUnreadStatus() async {
    if (widget.isGuest || widget.username == null) return;

    try {
      final url = Uri.parse(
        "${ApiConfig.notificationList}?username=${widget.username}",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        // แปลงข้อมูล JSON (รองรับภาษาไทยด้วย utf8.decode)
        List<dynamic> notifications = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        // เช็คว่ามีรายการไหนที่ 'read' เป็น false บ้างไหม?
        bool foundUnread = notifications.any((item) => item['read'] == false);

        if (mounted) {
          setState(() {
            _hasUnread = foundUnread;
          });
          // print("🔔 Noti Status: Has Unread? $_hasUnread"); // เปิดดู Log ได้ถ้าอยากเช็ค
        }
      }
    } catch (e) {
      print("❌ Error checking notification: $e");
    }
  }

  //  ฟังก์ชันสั่งรีเฟรชหน้า Home
  void _refreshHome() {
    print("🔄 Refreshing Home requested...");
    setState(() {
      _homeKey = UniqueKey();
    });
    // อัปเดตจุดแดงด้วย
    _checkUnreadStatus();
  }

  //  Logic: กดปุ่มบวก (Post)
  void _onPostButtonPressed() async {
    if (widget.isGuest) {
      _showLoginAlert(
        message: "คุณต้องเป็นสมาชิกเพื่อลงประกาศหาบ้านให้สัตว์ค่ะ",
      );
    } else {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => PostAnimalPage(username: widget.username!),
        ),
      );

      if (result == true) {
        print("🎉 Post success! Refreshing...");
        setState(() {
          _homeKey = UniqueKey();
          _activityKey = UniqueKey();
          _selectedIndex = 0;
        });
        _checkUnreadStatus(); // เช็คแจ้งเตือนใหม่
      }
    }
  }

  //  Logic: เปลี่ยนแท็บเมนู
  void _onItemTapped(int index) async {
    // 1. เช็คว่าเป็น Guest ไหม
    if (widget.isGuest && index != 0) {
      String msg = "กรุณาเข้าสู่ระบบเพื่อใช้งานเมนูนี้ค่ะ";
      if (index == 1) msg = "ฟังก์ชันค้นหาสงวนสิทธิ์สำหรับสมาชิกเท่านั้นค่ะ 🔒";
      if (index == 3) msg = "กรุณาเข้าสู่ระบบเพื่อดูการแจ้งเตือนค่ะ 🔔";

      _showLoginAlert(message: msg);
      return; // จบการทำงาน ไม่ทำต่อ
    }

    // 2. กรณีพิเศษ: ถ้ากดปุ่มแจ้งเตือน (Index 3) ให้เปิดหน้าใหม่แบบ Push
    if (index == 3) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => NotificationPage(username: widget.username!),
        ),
      );

      // ถ้ากลับมาแล้วมีการอ่าน (result == true) ให้เช็คจุดแดงใหม่
      if (result == true) {
        _checkUnreadStatus();
      }

      return; // 🛑 สำคัญมาก! สั่งหยุดตรงนี้ ไม่ให้มันไปเปลี่ยน Tab ด้านล่าง
    }

    // 3. กรณีปกติ: เปลี่ยน Tab ไปหน้า Home, Search, Activity
    setState(() => _selectedIndex = index);

    // เช็ค Noti เล่นๆ เผื่อมีอะไรอัปเดตระหว่างเล่น
    if (!widget.isGuest) {
      _checkUnreadStatus();
    }
  }

  //  Logic: ออกจากระบบ
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("ออกจากระบบ"),
        content: const Text("คุณต้องการออกจากระบบใช่หรือไม่?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (c) => const MainScreen(isGuest: true),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("ออก", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLoginAlert({required String message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.lock, color: AppColors.primaryGreen),
            const SizedBox(width: 10),
            const Text("สมาชิกเท่านั้น"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก", style: TextStyle(color: Colors.grey)),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "เข้าสู่ระบบ",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    final List<Widget> pages = [
      HomePage(
        key: _homeKey,
        isGuest: widget.isGuest,
        username: widget.username,
      ),
      SearchPage(isGuest: widget.isGuest, username: widget.username),
      widget.isGuest
          ? const SizedBox()
          : ActivityMenuPage(
              key: _activityKey,
              username: widget.username!,
              onPostUpdate: _refreshHome,
            ),
      widget.isGuest
          ? const SizedBox()
          : NotificationPage(username: widget.username!),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      resizeToAvoidBottomInset: false,

      appBar: _selectedIndex == 0 ? _buildHomeAppBar() : null,

      body: IndexedStack(index: _selectedIndex, children: pages),

      floatingActionButton: isKeyboardOpen
          ? null
          : SizedBox(
              height: 65,
              width: 65,
              child: FloatingActionButton(
                onPressed: _onPostButtonPressed,
                backgroundColor: AppColors.accentCopper,
                elevation: 4,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, size: 32, color: Colors.white),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, "หน้าหลัก", 0),
              _buildNavItem(Icons.search_rounded, "ค้นหา", 1),
              const SizedBox(width: 40),
              _buildNavItem(Icons.assignment_rounded, "กิจกรรม", 2),
              _buildNavItem(
                Icons.notifications_rounded,
                "แจ้งเตือน",
                3,
              ), // ปุ่มแจ้งเตือน
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildHomeAppBar() {
    return AppBar(
      backgroundColor: AppColors.bgCream,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
        child: Image.asset(
          'assets/images/logo_app.png',
          errorBuilder: (_, __, ___) =>
              Icon(Icons.pets, color: AppColors.primaryGreen),
          fit: BoxFit.contain,
        ),
      ),
      leadingWidth: 80,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: widget.isGuest
              ? TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const LoginPage()),
                  ),
                  icon: Icon(
                    Icons.login,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                  label: Text(
                    "เข้าสู่ระบบ",
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    elevation: 1,
                  ),
                )
              : IconButton(
                  onPressed: _logout,
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.errorRed,
                    size: 28,
                  ),
                  tooltip: 'ออกจากระบบ',
                ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    final bool isDisabled = widget.isGuest && index != 0;

    final Color iconColor = isSelected
        ? AppColors.primaryGreen
        : (isDisabled ? Colors.grey.withOpacity(0.3) : Colors.grey);

    // สร้าง Widget ของ Icon
    Widget iconWidget = Icon(icon, color: iconColor, size: 28);

    // Logic จุดแดง: ใส่ Badge ถ้ามี Noti และไม่ใช่ Guest
    if (index == 3 && !widget.isGuest && _hasUnread) {
      iconWidget = Badge(
        smallSize: 10, // จุดแดงเล็กๆ (ไม่มีตัวเลข)
        backgroundColor: AppColors.errorRed,
        child: iconWidget,
      );
    }

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget, // ใช้ icon ที่อาจจะมีจุดแดง
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: iconColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

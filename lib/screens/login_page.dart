// ignore_for_file: avoid_print, deprecated_member_use, avoid_unnecessary_containers

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home4paws/constants/api_config.dart';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';
import 'main_screen.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // --- CONTROLLERS ---
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  // --- STATE VARIABLES ---
  bool _isObscure = true;

  // --- API LOGIN FUNCTION ---
  Future<void> _login() async {
    // 1. ตรวจสอบว่ากรอกครบไหม
    if (usernameCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
      _showSnackBar(
        "กรุณากรอก Username และ Password ให้ครบถ้วน",
        isError: true,
      );
      return;
    }

    // 2. ตรวจสอบตาม SRS (Regex)
    final bool usernameValid = RegExp(
      r'^[a-zA-Z0-9]{6,12}$',
    ).hasMatch(usernameCtrl.text);
    if (!usernameValid) {
      _showSnackBar(
        "Username ต้องเป็นภาษาอังกฤษหรือตัวเลข (6-12 ตัวอักษร)",
        isError: true,
      );
      return;
    }

    final bool passwordValid = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,16}$',
    ).hasMatch(passwordCtrl.text);

    if (!passwordValid) {
      _showSnackBar(
        "รหัสผ่านต้องมี 8-16 ตัวอักษร (ตัวใหญ่+เล็ก+ตัวเลข+อักขระพิเศษ)",
        isError: true,
      );
      return;
    }

    // Show Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
    );

    final String url = ApiConfig.login;

    try {
      Map<String, String> body = {
        "username": usernameCtrl.text,
        "password": passwordCtrl.text,
      };

      print("🔵 Logging in to $url");
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (mounted) Navigator.pop(context); // ปิด Loading

      String result = response.body.trim();
      print("🟠 Server Response: '$result'");

      if (response.statusCode == 200 && result == "true") {
        print("✅ Login Success");
        if (mounted) {
          _showSnackBar("ยินดีต้อนรับกลับบ้าน! 🏡", isError: false);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MainScreen(isGuest: false, username: usernameCtrl.text),
            ),
            (route) => false,
          );
        }
      } else {
        String message = "เข้าสู่ระบบไม่สำเร็จ";
        if (result == "nodata") {
          message = "ไม่พบชื่อผู้ใช้นี้ กรุณาสมัครสมาชิกก่อน";
          usernameCtrl.clear();
          passwordCtrl.clear();
        } else if (result == "false") {
          message = "รหัสผ่านไม่ถูกต้อง";
          passwordCtrl.clear();
        } else if (result == "noactive") {
          message = "บัญชีนี้ถูกระงับการใช้งาน";
        }
        if (mounted) _showSnackBar(message, isError: true);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) _showSnackBar("เชื่อมต่อ Server ไม่ได้: $e", isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorRed : AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    //TODO:
                    //color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo_app.png',
                    width: 100,
                    height: 100,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.pets,
                        size: 80,
                        color: AppColors.primaryGreen,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Home4Paws",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDarkGreen,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  "พาเพื่อนรักกลับบ้าน",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textDarkGreen.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 40),

                // Input Fields
                _buildTextField(
                  controller: usernameCtrl,
                  label: "Username",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: passwordCtrl,
                  label: "Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Row(
                            children: [
                              Icon(
                                Icons.help_outline,
                                color: AppColors.accentCopper,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "ลืมรหัสผ่าน?",
                                style: TextStyle(
                                  color: AppColors.textDarkGreen,
                                ),
                              ),
                            ],
                          ),
                          content: const Text(
                            "กรุณาติดต่อผู้ดูแลระบบเพื่อรีเซ็ตรหัสผ่าน\n\n📞 02-123-4567\n📧 admin@home4paws.com",
                            style: TextStyle(fontSize: 14),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "ตกลง",
                                style: TextStyle(color: AppColors.primaryGreen),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      "ลืมรหัสผ่าน?",
                      style: TextStyle(
                        color: AppColors.textDarkGreen.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: AppColors.primaryGreen.withOpacity(0.4),
                    ),
                    child: const Text(
                      "เข้าสู่ระบบ (Login)",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "ยังไม่มีบัญชีใช่มั้ย? ",
                      style: TextStyle(color: AppColors.textDarkGreen),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "สมัครสมาชิกเลย",
                        style: TextStyle(
                          color: AppColors.accentCopper,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _isObscure : false,
        style: const TextStyle(color: AppColors.textDarkGreen),
        cursorColor: AppColors.primaryGreen,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.textDarkGreen.withOpacity(0.6),
          ),
          prefixIcon: Icon(icon, color: AppColors.primaryGreen),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }
}

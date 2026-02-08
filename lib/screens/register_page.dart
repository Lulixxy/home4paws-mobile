// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home4paws/constants/api_config.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 1. VARIABLES
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // 2. IMAGE PICKER
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      File tempFile = File(pickedFile.path);
      int sizeInBytes = tempFile.lengthSync();
      double sizeInMb = sizeInBytes / (1024 * 1024);

      if (sizeInMb > 1) {
        _showError("ขนาดรูปภาพต้องไม่เกิน 1 MB");
        return;
      }

      setState(() {
        _imageFile = tempFile;
      });
    }
  }

  // 3. MOCK ADDRESS DATA
  final Map<String, Map<String, List<String>>> thaiAddressData = {
    "กรุงเทพมหานคร": {
      "จตุจักร": ["จอมพล", "จตุจักร", "ลาดยาว", "เสนานิคม", "จันทรเกษม"],
      "บางรัก": ["มหาพฤฒาราม", "สีลม", "สุริยวงศ์", "บางรัก", "สี่พระยา"],
      "ห้วยขวาง": ["ห้วยขวาง", "บางกะปิ", "สามเสนนอก"],
      "ปทุมวัน": ["รองเมือง", "วังใหม่", "ปทุมวัน", "ลุมพินี"],
      "บางนา": ["บางนาเหนือ", "บางนาใต้"],
      "วัฒนา": ["คลองเตยเหนือ", "คลองตันเหนือ", "พระโขนงเหนือ"],
    },
    "สมุทรปราการ": {
      "เมืองสมุทรปราการ": ["ปากน้ำ", "สำโรงเหนือ", "บางเมือง", "ท้ายบ้าน"],
      "บางพลี": ["บางพลีใหญ่", "บางแก้ว", "บางปลา", "ราชาเทวะ"],
      "พระประแดง": ["ตลาด", "บางพึ่ง", "บางครุ", "ทรงคนอง"],
    },
    "นนทบุรี": {
      "เมืองนนทบุรี": ["สวนใหญ่", "ตลาดขวัญ", "บางเขน", "บางกระสอ", "ท่าทราย"],
      "ปากเกร็ด": ["ปากเกร็ด", "บางพูด", "บ้านใหม่", "บางตลาด"],
      "บางกรวย": ["วัดชลอ", "บางกรวย", "บางสีทอง", "มหาสวัสดิ์"],
    },
    "ปทุมธานี": {
      "เมืองปทุมธานี": ["บางปรอก", "บ้านใหม่", "บ้านกลาง", "บ้านฉาง"],
      "คลองหลวง": ["คลองหนึ่ง", "คลองสอง", "คลองสาม", "คลองสี่"],
      "ธัญบุรี": ["ประชาธิปัตย์", "บึงยี่โถ", "รังสิต"],
    },
    "เชียงใหม่": {
      "เมืองเชียงใหม่": [
        "ศรีภูมิ",
        "พระสิงห์",
        "หายยา",
        "ช้างม่อย",
        "ช้างคลาน",
        "สุเทพ",
      ],
      "แม่ริม": ["ริมใต้", "ริมเหนือ", "สันโป่ง", "ขี้เหล็ก", "แม่แรม"],
      "หางดง": ["หางดง", "หนองแก๋ว", "หารแก้ว", "หนองตอง"],
      "สันทราย": ["สันทรายหลวง", "สันทรายน้อย", "แม่แฝก", "หนองจ๊อม"],
    },
    "เชียงราย": {
      "เมืองเชียงราย": ["เวียง", "รอบเวียง", "บ้านดู่", "นางแล"],
      "แม่สาย": ["แม่สาย", "เวียงพางคำ", "โป่งผา"],
    },
    "ชลบุรี": {
      "เมืองชลบุรี": ["บางปลาสร้อย", "มะขามหย่ง", "บ้านโขด", "แสนสุข"],
      "บางละมุง": ["หนองปรือ", "นาเกลือ", "บางละมุง", "ห้วยใหญ่"],
      "ศรีราชา": ["ศรีราชา", "สุรศักดิ์", "ทุ่งสุขลา", "บึง", "หนองขาม"],
      "สัตหีบ": ["สัตหีบ", "นาจอมเทียน", "พลูตาหลวง", "บางเสร่"],
    },
    "ขอนแก่น": {
      "เมืองขอนแก่น": ["ในเมือง", "พระลับ", "เมืองเก่า", "บ้านเป็ด"],
      "ชุมแพ": ["ชุมแพ", "โนนหัน", "นาหนองทุ่ม"],
    },
    "นครราชสีมา": {
      "เมืองนครราชสีมา": ["ในเมือง", "โพธิ์กลาง", "หัวทะเล", "หนองจะบก"],
      "ปากช่อง": ["ปากช่อง", "กลางดง", "หนองน้ำแดง", "หมูสี"],
    },
    "ภูเก็ต": {
      "เมืองภูเก็ต": ["ตลาดใหญ่", "ตลาดเหนือ", "เกาะแก้ว", "รัษฎา", "วิชิต"],
      "กะทู้": ["กะทู้", "ป่าตอง", "กมลา"],
      "ถลาง": ["เทพกระษัตรี", "ศรีสุนทร", "เชิงทะเล", "ป่าคลอก"],
    },
    "สงขลา": {
      "เมืองสงขลา": ["บ่อยาง", "เขารูปช้าง", "พะวง"],
      "หาดใหญ่": ["หาดใหญ่", "ควนลัง", "คอหงส์", "บ้านพรุ"],
    },
    "สุราษฎร์ธานี": {
      "เมืองสุราษฎร์ธานี": ["ตลาด", "มะขามเตี้ย", "บางกุ้ง"],
      "เกาะสมุย": [
        "อ่างทอง",
        "ลิปะน้อย",
        "ตลิ่งงาม",
        "หน้าเมือง",
        "มะเร็ต",
        "บ่อผุด",
      ],
    },
  };

  String? selectedProvince;
  String? selectedDistrict;
  String? selectedSubDistrict;
  String? selectedAddressType;

  final List<String> addressTypeOptions = [
    "บ้านเดี่ยว",
    "บ้านเช่า",
    "อพาร์ตเมนต์",
    "บ้านแฝด",
    "คอนโดมิเนียม",
    "สำนักงาน",
    "หอพัก",
    "อื่นๆ",
  ];

  // 4. CONTROLLERS
  String memberType = "Member";
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController ageCtrl = TextEditingController();
  final TextEditingController dobCtrl = TextEditingController();
  final TextEditingController incomeCtrl = TextEditingController();
  String? selectedGender;

  final TextEditingController shelterNameCtrl = TextEditingController();
  final TextEditingController regNumberCtrl = TextEditingController();

  final TextEditingController addressDetailCtrl = TextEditingController();
  final TextEditingController subDistrictCtrl = TextEditingController();
  final TextEditingController postalCodeCtrl = TextEditingController();

  // 5. STATE FOR PASSWORD VISIBILITY
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  // 6. LOGIC & VALIDATION

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      if (usernameCtrl.text.isEmpty ||
          emailCtrl.text.isEmpty ||
          passwordCtrl.text.isEmpty ||
          confirmPasswordCtrl.text.isEmpty ||
          phoneCtrl.text.isEmpty) {
        _showError("กรุณากรอกข้อมูลบัญชีให้ครบทุกช่อง");
        return false;
      }
      if (_imageFile == null) {
        _showError("กรุณาเลือกรูปโปรไฟล์");
        return false;
      }
      if (!RegExp(r'^[a-zA-Z0-9]{6,12}$').hasMatch(usernameCtrl.text)) {
        _showError("ชื่อบัญชีต้องเป็นภาษาอังกฤษหรือตัวเลข (6-12 ตัวอักษร)");
        return false;
      }
      if (emailCtrl.text.length < 10 || emailCtrl.text.length > 60) {
        _showError("อีเมลต้องมีความยาว 10 - 60 ตัวอักษร");
        return false;
      }
      if (!RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      ).hasMatch(emailCtrl.text)) {
        _showError("รูปแบบอีเมลไม่ถูกต้อง");
        return false;
      }
      if (!RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,16}$',
      ).hasMatch(passwordCtrl.text)) {
        _showError(
          "รหัสผ่านต้องมี 8-16 ตัว (ต้องมีตัวพิมพ์เล็ก, ใหญ่, ตัวเลข และอักขระพิเศษ)",
        );
        return false;
      }
      if (passwordCtrl.text != confirmPasswordCtrl.text) {
        _showError("รหัสผ่านและการยืนยันรหัสผ่านไม่ตรงกัน");
        return false;
      }
      if (!RegExp(r'^0[689][0-9]{8}$').hasMatch(phoneCtrl.text)) {
        _showError("เบอร์โทรศัพท์ต้องเป็น 10 หลัก และขึ้นต้นด้วย 06, 08, 09");
        return false;
      }
    } else if (_currentStep == 1) {
      // Step 2: Role Selection (No validation needed)
    } else if (_currentStep == 2) {
      if (memberType == "Member") {
        if (firstNameCtrl.text.isEmpty ||
            lastNameCtrl.text.isEmpty ||
            dobCtrl.text.isEmpty ||
            ageCtrl.text.isEmpty ||
            selectedGender == null) {
          _showError("กรุณากรอกข้อมูลส่วนตัวให้ครบถ้วน");
          return false;
        }
        if (!RegExp(
          r'^[a-zA-Z\u0E00-\u0E7F\s]{3,100}$',
        ).hasMatch(firstNameCtrl.text)) {
          _showError("ชื่อต้องยาว 3-100 ตัวอักษร");
          return false;
        }
        if (!RegExp(
          r'^[a-zA-Z\u0E00-\u0E7F\s]{3,100}$',
        ).hasMatch(lastNameCtrl.text)) {
          _showError("นามสกุลต้องยาว 3-100 ตัวอักษร");
          return false;
        }
        int? age = int.tryParse(ageCtrl.text);
        if (age == null || age < 20 || age > 80) {
          _showError("อายุต้องอยู่ระหว่าง 20 - 80 ปี");
          return false;
        }
        if (incomeCtrl.text.isEmpty) {
          _showError("กรุณาระบุรายได้");
          return false;
        }
      } else {
        if (shelterNameCtrl.text.isEmpty || regNumberCtrl.text.isEmpty) {
          _showError("กรุณากรอกข้อมูลมูลนิธิให้ครบถ้วน");
          return false;
        }
      }
    } else if (_currentStep == 3) {
      if (addressDetailCtrl.text.isEmpty ||
          selectedProvince == null ||
          selectedDistrict == null ||
          selectedSubDistrict == null ||
          postalCodeCtrl.text.isEmpty) {
        _showError("กรุณากรอกที่อยู่และเลือกพื้นที่ให้ครบ");
        return false;
      }
      if (addressDetailCtrl.text.length > 255) {
        _showError("ที่อยู่มีความยาวเกินกำหนด");
        return false;
      }
      if (memberType == "Member" && selectedAddressType == null) {
        _showError("กรุณาเลือกประเภทที่อยู่");
        return false;
      }
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _nextPage() {
    if (!_validateCurrentStep()) return;
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      _submitRegister();
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  //  ฟังก์ชันเลือกวันที่
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(now.year - 80, now.month, now.day);
    final DateTime lastDate = DateTime(now.year - 20, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: lastDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.textDarkGreen,
            ),
            dialogBackgroundColor: AppColors.bgCream,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dobCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
        final age = now.year - picked.year;
        ageCtrl.text = age.toString();
      });
    }
  }

  // API SUBMIT
  Future<void> _submitRegister() async {
    if (!_validateCurrentStep()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
    );

    final String url = memberType == "Member"
        ? ApiConfig.registerMember
        : ApiConfig.registerShelter;

    try {
      String profilePicBase64 = "";
      if (_imageFile != null) {
        List<int> imageBytes = await _imageFile!.readAsBytes();
        profilePicBase64 = base64Encode(imageBytes);
      }

      Map<String, dynamic> body = {
        "username": usernameCtrl.text,
        "password": passwordCtrl.text,
        "email": emailCtrl.text,
        "phoneNumber": phoneCtrl.text,
        "memberType": memberType,
        "profilePicture": profilePicBase64,
      };

      if (memberType == "Member") {
        body.addAll({
          "address": addressDetailCtrl.text,
          "province": selectedProvince ?? "",
          "district": selectedDistrict ?? "",
          "subDistrict": selectedSubDistrict ?? "",
          "postalCode": postalCodeCtrl.text,
          "firstName": firstNameCtrl.text,
          "lastName": lastNameCtrl.text,
          "gender": selectedGender ?? "Other",
          "age": ageCtrl.text,
          "dateOfBirth": dobCtrl.text,
          "income": double.tryParse(incomeCtrl.text) ?? 0.0,
          "addressType": selectedAddressType ?? "Home",
        });
      } else {
        String fullAddress =
            "${addressDetailCtrl.text} ต.${selectedSubDistrict ?? '-'} อ.${selectedDistrict ?? '-'} จ.${selectedProvince ?? '-'} ${postalCodeCtrl.text}";
        body.addAll({
          "address": fullAddress,
          "shelterName": shelterNameCtrl.text,
          "registrationNumber": regNumberCtrl.text,
        });
      }

      print("🔵 Sending to $url");
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ ลงทะเบียนสำเร็จ! กรุณาเข้าสู่ระบบ"),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        print("❌ Error: ${response.body}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("❌ สมัครไม่สำเร็จ: ${response.body}"),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("⚠️ เชื่อมต่อ Server ไม่ได้: $e"),
            backgroundColor: AppColors.textDarkGreen,
          ),
        );
      }
    }
  }

  List<String> _getDistricts() {
    if (selectedProvince == null) return [];
    return thaiAddressData[selectedProvince]!.keys.toList();
  }

  List<String> _getSubDistricts() {
    if (selectedProvince == null || selectedDistrict == null) return [];
    return thaiAddressData[selectedProvince]![selectedDistrict] ?? [];
  }

  // UI BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _step1AccountInfo(),
                  _step2SelectRole(),
                  memberType == "Member"
                      ? _step3MemberInfo()
                      : _step3ShelterInfo(),
                  _step4AddressInfo(),
                ],
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Colors.white.withOpacity(0.5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textDarkGreen,
                ),
                onPressed: _prevPage,
              ),
              Text(
                "ขั้นตอนที่ ${_currentStep + 1} จาก 4",
                style: const TextStyle(
                  color: AppColors.textDarkGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / 4,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryGreen,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // STEPS
  Widget _step1AccountInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle("สร้างบัญชีผู้ใช้ 🐾"),
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!) as ImageProvider
                      : const NetworkImage(
                          "https://cdn-icons-png.flaticon.com/512/616/616408.png",
                        ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryGreen,
                        width: 3,
                      ),
                    ),
                    child: _imageFile == null
                        ? Icon(
                            Icons.camera_alt,
                            size: 30,
                            color: Colors.grey.withOpacity(0.5),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "แตะเพื่อเลือกรูปโปรไฟล์",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            "ชื่อบัญชี (Username)",
            usernameCtrl,
            icon: Icons.person_outline,
          ),

          // Password with Toggle
          _buildPasswordField(
            "รหัสผ่าน (Password)",
            passwordCtrl,
            _isPasswordHidden,
            () => setState(() => _isPasswordHidden = !_isPasswordHidden),
          ),
          _buildPasswordField(
            "ยืนยันรหัสผ่าน (Confirm Password)",
            confirmPasswordCtrl,
            _isConfirmPasswordHidden,
            () => setState(
              () => _isConfirmPasswordHidden = !_isConfirmPasswordHidden,
            ),
          ),

          _buildTextField(
            "อีเมล (Email)",
            emailCtrl,
            icon: Icons.email_outlined,
          ),
          _buildTextField(
            "เบอร์โทรศัพท์",
            phoneCtrl,
            icon: Icons.phone_outlined,
            isNumber: true,
          ),
        ],
      ),
    );
  }

  Widget _step2SelectRole() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle("เลือกสถานะของคุณ 🏠"),
          const SizedBox(height: 30),
          _buildRoleCard(
            "Member",
            "บุคคลทั่วไป ที่ต้องการรับเลี้ยง",
            Icons.pets,
            memberType == "Member",
          ),
          const SizedBox(height: 20),
          _buildRoleCard(
            "Shelter",
            "มูลนิธิ / สถานสงเคราะห์สัตว์",
            Icons.home_work_rounded,
            memberType == "Shelter",
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(
    String type,
    String desc,
    IconData icon,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => setState(() => memberType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
          border: Border.all(
            color: isSelected ? AppColors.accentCopper : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accentCopper.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accentCopper.withOpacity(0.1)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,

                color: isSelected ? AppColors.accentCopper : Colors.grey,
                size: 30,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDarkGreen,
                    ),
                  ),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textDarkGreen.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.accentCopper),
          ],
        ),
      ),
    );
  }

  Widget _step3MemberInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle("ข้อมูลสมาชิก 🙋‍♂️"),
          _buildTextField("ชื่อ (First Name)", firstNameCtrl),
          _buildTextField("นามสกุล (Last Name)", lastNameCtrl),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: _buildTextField(
                      "วันเกิด (DD/MM/YYYY)",
                      dobCtrl,
                      icon: Icons.calendar_today_rounded,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildTextField("อายุ (Age)", ageCtrl, isNumber: true),
              ),
            ],
          ),
          _buildDropdownSimple(
            "เพศ (Gender)",
            ["Male", "Female", "Other"],
            selectedGender,
            (val) => setState(() => selectedGender = val),
          ),
          _buildTextField(
            "รายได้ต่อเดือน (บาท)",
            incomeCtrl,
            isNumber: true,
            icon: Icons.monetization_on_rounded,
          ),
        ],
      ),
    );
  }

  Widget _step3ShelterInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle("ข้อมูลมูลนิธิ 🏥"),
          _buildTextField(
            "ชื่อมูลนิธิ (Shelter Name)",
            shelterNameCtrl,
            icon: Icons.business,
          ),
          _buildTextField(
            "เลขทะเบียน (Reg. No.)",
            regNumberCtrl,
            icon: Icons.badge,
          ),
        ],
      ),
    );
  }

  Widget _step4AddressInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle("ที่อยู่ปัจจุบัน 📍"),
          if (memberType == "Member")
            _buildDropdownSimple(
              "ประเภทที่อยู่",
              addressTypeOptions,
              selectedAddressType,
              (val) => setState(() => selectedAddressType = val),
            ),
          _buildTextField(
            "บ้านเลขที่ / ซอย / ถนน",
            addressDetailCtrl,
            icon: Icons.home,
          ),
          const SizedBox(height: 10),
          _buildAddressDropdown(
            label: "จังหวัด",
            value: selectedProvince,
            items: thaiAddressData.keys.toList(),
            onChanged: (val) {
              setState(() {
                selectedProvince = val;
                selectedDistrict = null;
                selectedSubDistrict = null;
              });
            },
          ),
          _buildAddressDropdown(
            label: "เขต/อำเภอ",
            value: selectedDistrict,
            items: _getDistricts(),
            isEnabled: selectedProvince != null,
            onChanged: (val) {
              setState(() {
                selectedDistrict = val;
                selectedSubDistrict = null;
              });
            },
          ),
          _buildAddressDropdown(
            label: "แขวง/ตำบล",
            value: selectedSubDistrict,
            items: _getSubDistricts(),
            isEnabled: selectedDistrict != null,
            onChanged: (val) {
              setState(() {
                selectedSubDistrict = val;
              });
            },
          ),
          const SizedBox(height: 10),
          _buildTextField("รหัสไปรษณีย์", postalCodeCtrl, isNumber: true),
        ],
      ),
    );
  }

  // WIDGETS
  Widget _buildTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textDarkGreen,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    bool isNumber = false,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label หัวข้อ
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDarkGreen,
            ),
          ),
          const SizedBox(height: 8),
          // Input Box
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              obscureText: isPassword,
              keyboardType: isNumber
                  ? TextInputType.number
                  : TextInputType.text,
              cursorColor: AppColors.primaryGreen,
              style: const TextStyle(color: AppColors.textDarkGreen),
              decoration: InputDecoration(
                prefixIcon: icon != null
                    ? Icon(icon, color: AppColors.primaryGreen)
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool isHidden,
    VoidCallback onToggle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDarkGreen,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              obscureText: isHidden,
              cursorColor: AppColors.primaryGreen,
              style: const TextStyle(color: AppColors.textDarkGreen),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: AppColors.primaryGreen,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isHidden ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: onToggle,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSimple(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDarkGreen,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: Text(
                  "เลือก$label",
                  style: const TextStyle(color: Colors.grey),
                ),
                items: items
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(
                            color: AppColors.textDarkGreen,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChanged as void Function(String?)?,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.primaryGreen,
                ),
                dropdownColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isEnabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDarkGreen,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: isEnabled ? Colors.white : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(15),
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: Text(
                  isEnabled ? "กรุณาเลือก..." : "เลือกรายการก่อนหน้าก่อน",
                  style: const TextStyle(color: Colors.grey),
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: isEnabled ? AppColors.primaryGreen : Colors.grey,
                ),
                items: isEnabled
                    ? items
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: const TextStyle(
                                  color: AppColors.textDarkGreen,
                                ),
                              ),
                            ),
                          )
                          .toList()
                    : [],
                onChanged: isEnabled ? onChanged : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    bool isLastPage = _currentStep == 3;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: AppColors.bgCream),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: isLastPage
                ? AppColors.accentCopper
                : AppColors.primaryGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
          ),
          child: Text(
            isLastPage ? "ยืนยันการสมัคร" : "ถัดไป",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// lib/screens/post_animal_page.dart

// ignore_for_file: avoid_print, deprecated_member_use, use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import '../constants/app_colors.dart';
import '../models/post_animal.dart';

class PostAnimalPage extends StatefulWidget {
  final String username;
  final PostAnimal? animalToEdit; // รับข้อมูลเก่า (ถ้ามี)

  const PostAnimalPage({super.key, required this.username, this.animalToEdit});

  @override
  State<PostAnimalPage> createState() => _PostAnimalPageState();
}

class _PostAnimalPageState extends State<PostAnimalPage> {
  final _formKey = GlobalKey<FormState>();

  File? _imageFile;
  String? _existingBase64Image;

  final ImagePicker _picker = ImagePicker();

  // Controllers
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController ageCtrl = TextEditingController();
  final TextEditingController personalityCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();

  // Dropdown Variables
  String selectedType = "-";
  String selectedGender = "-";
  String selectedBreed = "-";

  // --- Data Lists ---
  final List<String> animalTypes = ["-", "Dog", "Cat"];
  final List<String> genderTypes = ["-", "Male", "Female"];

  final List<String> dogBreeds = [
    "-",
    "ไทยบางแก้ว (Thai Bangkaew)",
    "ไทยหลังอาน (Thai Ridgeback)",
    "โกลเด้น รีทรีฟเวอร์ (Golden Retriever)",
    "ไซบีเรียน ฮัสกี้ (Siberian Husky)",
    "ลาบราดอร์ รีทรีฟเวอร์ (Labrador Retriever)",
    "ชิวาวา (Chihuahua)",
    "ปั๊ก (Pug)",
    "พุดเดิ้ล (Poodle)",
    "บีเกิล (Beagle)",
    "ชิสุ (Shih Tzu)",
    "ปอมเมอเรเนียน (Pomeranian)",
    "ชเนาเซอร์ (Schnauzer)",
    "ดัชชุน (Dachshund)",
    "คอร์กี้ (Corgi)",
    "ยอร์กเชียร์ เทอร์เรีย (Yorkshire Terrier)",
    "บูลด็อก (Bulldog)",
    "เฟรนช์ บูลด็อก (French Bulldog)",
    "ร็อตไวเลอร์ (Rottweiler)",
    "โดเบอร์แมน (Doberman)",
    "ซามอยด์ (Samoyed)",
    "อาคิตะ (Akita)",
    "ชิบะ อินุ (Shiba Inu)",
    "เซนต์เบอร์นาร์ด (Saint Bernard)",
    "พันธุ์ผสม (Mixed Breed)",
    "อื่น ๆ (Others)",
  ];

  final List<String> catBreeds = [
    "-",
    "แมวไทย (Thai Domestic)",
    "เปอร์เซีย (Persian)",
    "สกอตติช โฟลด์ (Scottish Fold)",
    "วิเชียรมาศ (Siamese)",
    "ขาวมณี (Khao Manee)",
    "สีสวาด (Korat)",
    "บริติช ชอร์ตแฮร์ (British Shorthair)",
    "เมนคูน (Maine Coon)",
    "เบงกอล (Bengal)",
    "แร็กดอลล์ (Ragdoll)",
    "อเมริกัน ชอร์ตแฮร์ (American Shorthair)",
    "เอ็กโซติก ชอร์ตแฮร์ (Exotic Shorthair)",
    "รัสเซียน บลู (Russian Blue)",
    "สฟิงซ์ (Sphynx)",
    "อาบิสซิเนียน (Abyssinian)",
    "เบอร์มีส (Burmese)",
    "เบอร์แมน (Birman)",
    "นอร์วีเจียน ฟอเรสต์ (Norwegian Forest Cat)",
    "โอเรียนทอล ชอร์ตแฮร์ (Oriental Shorthair)",
    "ท็องกินีส (Tonkinese)",
    "พันธุ์ผสม (Mixed Breed)",
    "อื่น ๆ (Others)",
  ];

  // Banned Keywords
  final List<String> bannedKeywords = [
    "ขาย",
    "ราคา",
    "บาท",
    "baht",
    "sale",
    "sell",
    "price",
    "line",
    "id",
    "ไลน์",
    "แอด",
    "@",
    "facebook",
    "fb",
    "face",
    "เฟส",
    "inbox",
    "ib",
    "dm",
    "ทักแชท",
    "08",
    "09",
    "06",
    "สินสอด",
  ];

  List<String> get currentBreedList {
    if (selectedType == "Dog") return dogBreeds;
    if (selectedType == "Cat") return catBreeds;
    return ["-"];
  }

  @override
  void initState() {
    super.initState();
    selectedBreed = currentBreedList.first;

    if (widget.animalToEdit != null) {
      final oldData = widget.animalToEdit!;
      nameCtrl.text = oldData.animalName;
      ageCtrl.text = oldData.age.toString();
      personalityCtrl.text = oldData.personality;
      locationCtrl.text = oldData.location;
      _existingBase64Image = oldData.animalImage;

      if (animalTypes.contains(oldData.animalType)) {
        selectedType = oldData.animalType;
      }
      if (genderTypes.contains(oldData.gender)) {
        selectedGender = oldData.gender;
      }

      List<String> targetList = (oldData.animalType == "Dog")
          ? dogBreeds
          : (oldData.animalType == "Cat" ? catBreeds : ["-"]);

      if (targetList.contains(oldData.breed)) {
        selectedBreed = oldData.breed;
      } else {
        selectedBreed = targetList.contains("อื่น ๆ (Others)")
            ? "อื่น ๆ (Others)"
            : targetList.first;
      }
    }
  }

  bool _containsBannedWords(String text) {
    if (text.isEmpty) return false;
    String lowerText = text.toLowerCase();
    for (String word in bannedKeywords) {
      if (lowerText.contains(word)) return true;
    }
    return false;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _submitPost() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (selectedType == "-" || selectedGender == "-" || selectedBreed == "-") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("กรุณาเลือก ประเภท, เพศ และสายพันธุ์ ให้ครบถ้วน"),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (_imageFile == null && _existingBase64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("กรุณาเลือกรูปภาพสัตว์เลี้ยง"),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    // 1. ตรวจสอบคำต้องห้าม
    bool isSuspicious =
        _containsBannedWords(personalityCtrl.text) ||
        _containsBannedWords(locationCtrl.text) ||
        _containsBannedWords(nameCtrl.text);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
    );

    try {
      String finalBase64Image = _existingBase64Image ?? "";
      if (_imageFile != null) {
        List<int> imageBytes = await _imageFile!.readAsBytes();
        finalBase64Image = base64Encode(imageBytes);
      }

      Map<String, dynamic> body = {
        "username": widget.username,
        "animalName": nameCtrl.text,
        "animalType": selectedType,
        "breed": selectedBreed,
        "age": int.tryParse(ageCtrl.text) ?? 0,
        "gender": selectedGender,
        "personality": personalityCtrl.text,
        "location": locationCtrl.text,
        "animalImage": finalBase64Image,
        "appropriate": !isSuspicious,
      };

      final bool isEditing = widget.animalToEdit != null;
      String url;
      http.Response response;

      if (isEditing) {
        url = "${ApiConfig.editPost}/${widget.animalToEdit!.animalId}";
        response = await http.put(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );
      } else {
        url = ApiConfig.postAdd;
        response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );
      }

      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop(); // Close Loading
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        String serverMessage = response.body;
        bool isUnderReview =
            isSuspicious || serverMessage.contains("pending_review");

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(
                  isUnderReview ? Icons.info_outline : Icons.check_circle,
                  color: isUnderReview
                      ? AppColors.accentCopper
                      : AppColors.primaryGreen,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  isUnderReview ? "รอการตรวจสอบ" : "สำเร็จ!",
                  style: const TextStyle(
                    color: AppColors.textDarkGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              isUnderReview
                  ? "ข้อมูลถูกบันทึกแล้ว 📝\nแต่เนื่องจากมีข้อความที่อาจเกี่ยวข้องกับการซื้อขายหรือข้อมูลส่วนตัว โพสต์นี้จะถูกส่งให้ Admin ตรวจสอบก่อนแสดงผลนะคะ"
                  : (isEditing
                        ? "แก้ไขข้อมูลเรียบร้อยแล้ว!"
                        : "ลงประกาศเรียบร้อยแล้ว!\nน้องๆ จะแสดงบนหน้าแรกทันที 🐾"),
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textDarkGreen,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close Dialog
                  Navigator.pop(context, true); // Close Page
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
            content: Text("ทำรายการไม่สำเร็จ: ${response.statusCode}"),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context))
        Navigator.of(context, rootNavigator: true).pop();
      print("❌ Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("เกิดข้อผิดพลาด: $e"),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.animalToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: Text(
          isEditing ? "แก้ไขประกาศ ✏️" : "ลงประกาศหาบ้าน 🏡",
          style: const TextStyle(
            color: AppColors.textDarkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.bgCream,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ส่วนแสดงรูป ---
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceModal,
                  child: Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryGreen.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      image: _imageFile != null
                          ? DecorationImage(
                              image: FileImage(_imageFile!),
                              fit: BoxFit.cover,
                            )
                          : (_existingBase64Image != null
                                ? DecorationImage(
                                    image: MemoryImage(
                                      base64Decode(_existingBase64Image!),
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null),
                    ),
                    child: (_imageFile == null && _existingBase64Image == null)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_rounded,
                                size: 60,
                                color: AppColors.primaryGreen.withOpacity(0.4),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "แตะเพื่อเพิ่มรูป",
                                style: TextStyle(
                                  color: AppColors.textDarkGreen.withOpacity(
                                    0.5,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              if (isEditing)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Center(
                    child: Text(
                      "แตะที่รูปเพื่อเปลี่ยนรูปใหม่",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              _buildSectionTitle("ข้อมูลทั่วไป"),

              _buildTextField("ชื่อสัตว์เลี้ยง", nameCtrl, icon: Icons.pets),

              Row(
                children: [
                  Expanded(
                    child: _buildDropdown("ประเภท", animalTypes, selectedType, (
                      val,
                    ) {
                      setState(() {
                        selectedType = val!;
                        selectedBreed = currentBreedList.first;
                      });
                    }),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildDropdown(
                      "เพศ",
                      genderTypes,
                      selectedGender,
                      (val) => setState(() => selectedGender = val!),
                    ),
                  ),
                ],
              ),

              _buildDropdown(
                "สายพันธุ์",
                currentBreedList,
                selectedBreed,
                (val) => setState(() => selectedBreed = val!),
              ),

              _buildTextField(
                "อายุ (ปี)",
                ageCtrl,
                icon: Icons.cake,
                isNumber: true,
              ),

              const SizedBox(height: 20),
              _buildSectionTitle("รายละเอียดเพิ่มเติม"),

              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: AppColors.accentCopper,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        "ห้ามระบุราคาขาย หรือข้อมูลติดต่อส่วนตัวในช่องนี้",
                        style: TextStyle(
                          color: AppColors.accentCopper,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _buildTextField(
                "นิสัย / จุดเด่น",
                personalityCtrl,
                icon: Icons.favorite,
                maxLines: 3,
              ),

              _buildTextField(
                "สถานที่ / พิกัด",
                locationCtrl,
                icon: Icons.location_on,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'กรุณากรอกสถานที่';
                  if (value.length < 3)
                    return 'ระบุสถานที่ให้ชัดเจนกว่านี้หน่อยนะคะ';
                  return null;
                },
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentCopper,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: AppColors.accentCopper.withOpacity(0.4),
                  ),
                  child: Text(
                    isEditing ? "บันทึกการแก้ไข" : "ลงประกาศ (Post)",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---
  void _showImageSourceModal() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppColors.primaryGreen,
              ),
              title: const Text("ถ่ายรูป"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primaryGreen,
              ),
              title: const Text("เลือกจากอัลบั้ม"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    bool isNumber = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        validator:
            validator ??
            (value) =>
                (value == null || value.isEmpty) ? 'กรุณากรอกข้อมูล' : null,
        style: const TextStyle(color: AppColors.textDarkGreen),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.textDarkGreen.withOpacity(0.6),
          ),
          prefixIcon: icon != null
              ? Icon(icon, color: AppColors.primaryGreen)
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
          errorStyle: const TextStyle(color: AppColors.errorRed),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String value,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label หัวข้อ
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 6),
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textDarkGreen.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // ตัว Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
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
                onChanged: onChanged,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
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
}

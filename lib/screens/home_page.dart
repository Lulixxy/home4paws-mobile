// lib/screens/home_page.dart
// ignore_for_file: avoid_print, deprecated_member_use, curly_braces_in_flow_control_structures

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';
import '../models/post_animal.dart';
import '../constants/api_config.dart';
import 'post_detail_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final bool isGuest;
  final String? username;
  const HomePage({super.key, this.isGuest = true, this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<PostAnimal>> _futureAnimals;
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Set<String> _myRequestedAnimalIds = {};
  final List<Map<String, String>> _bannerData = [
    {
      "image":
          "https://cdn.pixabay.com/photo/2018/03/31/06/31/dog-3277416_1280.jpg",
      "title": "โครงการทำหมันฟรี 💉",
      "subtitle": "สำหรับสุนัขและแมวจรจัดทั่วประเทศ",
    },
    {
      "image":
          "https://cdn.pixabay.com/photo/2017/08/07/18/57/dog-2606759_1280.jpg",
      "title": "ร่วมบริจาคอาหาร 🍖",
      "subtitle": "ช่วยน้องๆ ที่ศูนย์พักพิงให้อิ่มท้อง",
    },
    {
      "image":
          "https://cdn.pixabay.com/photo/2016/02/19/15/46/labrador-retriever-1210559_1280.jpg",
      "title": "หาบ้านให้น้อง 🏡",
      "subtitle": "รับเลี้ยงวันนี้ เพื่อชีวิตที่ดีกว่า",
    },
  ];

  Future<void> _fetchMyRequests() async {
    if (widget.isGuest || widget.username == null)
      return; // ถ้าเป็น Guest ไม่ต้องทำ

    try {
      final String url = "${ApiConfig.adoptionHistory}/${widget.username}";
      print("🔍 Fetching History URL: $url");
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print("📦 History Response: ${utf8.decode(response.bodyBytes)}");
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));

        // ดึงเฉพาะ animalId มาเก็บไว้ใน Set
        setState(() {
          _myRequestedAnimalIds = body
              .map((item) => item['animalId'].toString())
              .toSet();
        });
        print("✅ My Requested IDs List: $_myRequestedAnimalIds");
      } else {
        print("❌ Error Fetching History: Status ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching my requests: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _futureAnimals = fetchAnimals();
    _fetchMyRequests();
  }

  Future<List<PostAnimal>> fetchAnimals() async {
    final String url = ApiConfig.allAvailable;
    try {
      final response = await http.get(Uri.parse(url));
      // print("📦 Raw JSON from Server: ${utf8.decode(response.bodyBytes)}");
      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> body = jsonDecode(responseBody);
        return body.map((item) => PostAnimal.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching animals: $e");
      return [];
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _futureAnimals = fetchAnimals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.primaryGreen,
      child: ListView(
        children: [
          // --- Header ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isGuest
                      ? "ยินดีต้อนรับสู่ Home4Paws 🐾"
                      : "สวัสดีสมาชิก 🐾",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDarkGreen,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "วันนี้น้องๆ ตัวไหนจะได้กลับบ้านกับคุณนะ?",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textDarkGreen.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // --- Banner ---
          _buildBannerSlider(),
          const SizedBox(height: 10),

          // --- Section Title ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Text(
              "น้องๆ ที่กำลังหาบ้าน",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
          ),

          // --- Animal List ---
          FutureBuilder<List<PostAnimal>>(
            future: _futureAnimals,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                );
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.pets,
                          size: 60,
                          color: AppColors.textDarkGreen.withOpacity(0.2),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "ยังไม่มีประกาศหาบ้านในขณะนี้",
                          style: TextStyle(
                            color: AppColors.textDarkGreen.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  widget.isGuest ? 20 : 80,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) =>
                    _buildAnimalCard(snapshot.data![index]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSlider() {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _bannerData.length,
            onPageChanged: (index) =>
                setState(() => _currentBannerIndex = index),
            itemBuilder: (context, index) =>
                _buildBannerItem(_bannerData[index]),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_bannerData.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentBannerIndex == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentBannerIndex == index
                    ? AppColors.primaryGreen
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBannerItem(Map<String, String> banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(banner['image']!),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              banner['title']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              banner['subtitle']!,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalCard(PostAnimal animal) {
    bool isMale = animal.gender.toLowerCase() == 'male';

    Color genderColor = isMale ? Colors.blue : Colors.pink;
    Color genderBgColor = isMale ? Colors.blue.shade50 : Colors.pink.shade50;
    IconData genderIcon = isMale ? Icons.male : Icons.female;

    bool isMine =
        widget.username != null &&
        widget.username!.isNotEmpty &&
        widget.username == animal.username;

    if (animal.animalName.contains("ดินสอ")) {
      print(
        "🐶 Checking Dinso: ID=[${animal.animalId}] vs MyList=$_myRequestedAnimalIds",
      );
      print(
        "👉 Is In List? : ${_myRequestedAnimalIds.contains(animal.animalId)}",
      );
    }

    bool isRequested = _myRequestedAnimalIds.contains(animal.animalId);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isMine
            ? Border.all(color: AppColors.accentCopper, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            if (widget.isGuest) {
              _showLoginRequiredDialog();
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailPage(
                    animal: animal,
                    isGuest: widget.isGuest,
                    currentUsername: widget.username,
                    isRequested: isRequested,
                  ),
                ),
              ).then((value) {
                // ให้ทำการดึงรายการที่ขอใหม่อีกรอบทันที
                print("🔄 Returning from Detail Page, refreshing requests...");
                _fetchMyRequests();
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'animal_${animal.animalName}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 110,
                      height: 110,
                      color: AppColors.bgCream,
                      child: animal.animalImage.isNotEmpty
                          ? Image.memory(
                              base64Decode(animal.animalImage),
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.pets, size: 40, color: Colors.grey[300]),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Badge ประเภทสัตว์
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  animal.animalType.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ),

                              if (isMine) ...[
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentCopper.withOpacity(
                                      0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 10,
                                        color: AppColors.accentCopper,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        "My Post",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.accentCopper,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              if (isRequested)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  margin: const EdgeInsets.only(left: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.orange),
                                  ),
                                  child: const Text(
                                    "ขอแล้ว",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: genderBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              genderIcon,
                              size: 16,
                              color: genderColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        animal.animalName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDarkGreen,
                          height: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        animal.breed,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.cake,
                            size: 14,
                            color: AppColors.accentCopper,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${animal.age} ปี",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: AppColors.accentCopper,
                                ),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    _getProvince(animal.location),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
          "กรุณาเข้าสู่ระบบก่อน เพื่อดูรายละเอียดและขอรับเลี้ยงน้องๆ ค่ะ 🐾",
          style: TextStyle(fontSize: 14, color: AppColors.textDarkGreen),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("ยกเลิก", style: TextStyle(color: Colors.grey[600])),
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

  String _getProvince(String fullLocation) {
    if (fullLocation.isEmpty) return "-";
    if (fullLocation.contains("กรุงเทพ") || fullLocation.contains("กทม")) {
      return "กรุงเทพฯ";
    }
    final regex = RegExp(r'(?:จ\.|จังหวัด)\s*([^\s,]+)');
    final match = regex.firstMatch(fullLocation);
    if (match != null) return match.group(1) ?? fullLocation;
    List<String> parts = fullLocation.trim().split(' ');
    if (parts.length > 1) return parts.last;
    return fullLocation;
  }
}

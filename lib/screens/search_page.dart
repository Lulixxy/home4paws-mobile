// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home4paws/constants/api_config.dart';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';
import '../models/post_animal.dart';
import 'post_detail_page.dart';
import 'login_page.dart';

class SearchPage extends StatefulWidget {
  // 1. เพิ่มตัวแปรรับค่า User
  final bool isGuest;
  final String? username;

  const SearchPage({super.key, this.isGuest = true, this.username});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<PostAnimal> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  Future<void> _doSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    final String url = "${ApiConfig.search}?q=$keyword";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> body = jsonDecode(responseBody);

        setState(() {
          _searchResults = body
              .map((item) => PostAnimal.fromJson(item))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error searching: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 1. Search Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCream,
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ค้นหาเพื่อนรัก 🔎",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDarkGreen,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _searchCtrl,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) => _doSearch(value),
                  cursorColor: AppColors.primaryGreen,
                  decoration: InputDecoration(
                    hintText: "เช่น สุนัข, แมว, สีขาว...",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.primaryGreen,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() {
                          _searchResults.clear();
                          _hasSearched = false;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Result Area
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  )
                : _buildResultList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultList() {
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.manage_search,
              size: 80,
              color: AppColors.primaryGreen.withOpacity(0.3),
            ),
            const SizedBox(height: 10),
            Text(
              "พิมพ์คำค้นหาเพื่อเริ่มตามหาเพื่อนใหม่",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: AppColors.errorRed.withOpacity(0.5),
            ),
            const SizedBox(height: 10),
            Text(
              "ไม่พบข้อมูลสัตว์ที่ค้นหา",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildAnimalCard(_searchResults[index]);
      },
    );
  }

  Widget _buildAnimalCard(PostAnimal animal) {
    bool isMale = animal.gender.toLowerCase() == 'male';
    Color genderColor = isMale ? Colors.blue : Colors.pink;
    Color genderBgColor = isMale ? Colors.blue.shade50 : Colors.pink.shade50;
    IconData genderIcon = isMale ? Icons.male : Icons.female;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // 2. เช็คสิทธิ์และส่งค่าไป PostDetailPage
            if (widget.isGuest) {
              _showLoginRequiredDialog();
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailPage(
                    animal: animal,
                    isGuest: widget.isGuest,
                    currentUsername: widget.username, // ส่ง user ไปด้วย
                  ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  // 3. Tag ตรงกับ HomePage (รูปเด้งได้)
                  tag: 'animal_${animal.animalName}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      width: 100,
                      height: 100,
                      color: AppColors.bgCream,
                      child: animal.animalImage.isNotEmpty
                          ? Image.memory(
                              base64Decode(animal.animalImage),
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.pets,
                              size: 40,
                              color: AppColors.primaryGreen.withOpacity(0.3),
                            ),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              animal.animalType.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: genderBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              genderIcon,
                              size: 14,
                              color: genderColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        animal.animalName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDarkGreen,
                          height: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${animal.breed} • ${animal.age} ปี",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppColors.accentCopper,
                          ),
                          const SizedBox(width: 4),
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
            Text("สมาชิกเท่านั้น"),
          ],
        ),
        content: const Text("กรุณาเข้าสู่ระบบเพื่อดูรายละเอียดเพิ่มเติมค่ะ 🐾"),
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

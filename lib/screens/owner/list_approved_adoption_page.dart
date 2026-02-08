// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants/api_config.dart';
import '../../constants/app_colors.dart';
import '../monitor_animal_page.dart';

class ListApprovedAdoptionPage extends StatefulWidget {
  final String username;
  const ListApprovedAdoptionPage({super.key, required this.username});

  @override
  State<ListApprovedAdoptionPage> createState() =>
      _ListApprovedAdoptionPageState();
}

class _ListApprovedAdoptionPageState extends State<ListApprovedAdoptionPage> {
  List<dynamic> _adoptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdoptions();
  }

  Future<void> _fetchAdoptions() async {
    try {
      final url = Uri.parse(
        "${ApiConfig.ownerAdoptions}?username=${widget.username}",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _adoptions = jsonDecode(utf8.decode(response.bodyBytes));
          _isLoading = false;
        });
      } else {
        setState(() {
          _adoptions = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching adoptions: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text("ติดตามผล & ส่งมอบ 🚚"),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            )
          : _adoptions.isEmpty
          ? Center(
              child: Text(
                "ยังไม่มีรายการที่อนุมัติแล้ว",
                style: TextStyle(
                  color: AppColors.textDarkGreen.withOpacity(0.5),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _adoptions.length,
              itemBuilder: (context, index) {
                final item = _adoptions[index];
                return _buildCard(item);
              },
            ),
    );
  }

  Widget _buildCard(dynamic item) {
    bool isHandoverCompleted = item['handoverDate'] != null;
    String? base64Image = item['animalImage'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // รูปโปรไฟล์สัตว์
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: AppColors.bgCream,
                    child: (base64Image != null && base64Image.isNotEmpty)
                        ? Image.memory(
                            base64Decode(base64Image),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.pets,
                              color: Colors.grey.shade400,
                              size: 30,
                            ),
                          )
                        : Icon(
                            Icons.pets,
                            color: Colors.grey.shade400,
                            size: 30,
                          ),
                  ),
                ),
                const SizedBox(width: 16),

                // ข้อมูลชื่อ
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['animalName'] ?? "Unknown",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.textDarkGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "ผู้รับเลี้ยง: ${item['adopterName'] ?? '-'}",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textDarkGreen.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // ไอคอนสถานะ
                if (isHandoverCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primaryGreen,
                    size: 24,
                  ),
              ],
            ),
            const Divider(height: 24),

            // ปุ่ม Action
            if (!isHandoverCompleted)
              // กรณี 1: ยังไม่ส่งมอบ
              ElevatedButton.icon(
                onPressed: () {
                  if (item['adoptionId'] != null) {
                    _showHandoverDialog(
                      item['adoptionId'],
                      item['animalName'] ?? "น้อง",
                    );
                  }
                },
                icon: const Icon(Icons.edit_calendar),
                label: const Text("บันทึกการส่งมอบ"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentCopper,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
              )
            else
              // กรณี 2: ส่งมอบแล้ว
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showHandoverDialog(
                          item['adoptionId'],
                          item['animalName'] ?? "น้อง",
                          currentPerson: item['handoverPerson'],
                          currentRemarks: item['remarks'],
                          currentDateString: item['handoverDate'],
                          isViewOnly: true,
                        );
                      },
                      icon: const Icon(Icons.assignment),
                      label: const Text("ดูข้อมูล"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textDarkGreen,
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (item['adoptionId'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MonitorAnimalPage(
                                adoptionId: item['adoptionId'],
                                animalName: item['animalName'] ?? "น้อง",
                                animalImage: item['animalImage'] ?? "",
                                canPost: false,
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.pets),
                      label: const Text("ติดตามชีวิต"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showHandoverDialog(
    String adoptionId,
    String animalName, {
    String? currentPerson,
    String? currentRemarks,
    String? currentDateString,
    bool isViewOnly = false,
  }) {
    final personController = TextEditingController(text: currentPerson ?? "");
    final remarksController = TextEditingController(text: currentRemarks ?? "");

    DateTime selectedDate = DateTime.now();
    if (currentDateString != null) {
      try {
        selectedDate = DateTime.parse(currentDateString);
      } catch (e) {
        print("Error parsing date: $e");
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    isViewOnly
                        ? Icons.assignment_turned_in
                        : Icons.local_shipping,
                    color: isViewOnly
                        ? AppColors.primaryGreen
                        : AppColors.accentCopper,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isViewOnly ? "รายละเอียด" : "ส่งมอบน้อง $animalName",
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.textDarkGreen,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // วันที่
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "วันที่ส่งมอบจริง:",
                        style: TextStyle(color: AppColors.textDarkGreen),
                      ),
                      subtitle: Text(
                        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
                        style: TextStyle(
                          color: isViewOnly
                              ? AppColors.textDarkGreen
                              : AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      trailing: isViewOnly
                          ? null
                          : const Icon(
                              Icons.calendar_month,
                              color: Colors.grey,
                            ),
                      onTap: isViewOnly
                          ? null
                          : () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: AppColors.primaryGreen,
                                        onPrimary: Colors.white,
                                        onSurface: AppColors.textDarkGreen,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setStateDialog(() => selectedDate = picked);
                              }
                            },
                    ),
                    const Divider(),

                    // ชื่อผู้ส่ง
                    TextField(
                      controller: personController,
                      readOnly: isViewOnly,
                      cursorColor: AppColors.primaryGreen,
                      decoration: InputDecoration(
                        labelText: "ชื่อผู้ทำการส่งมอบ",
                        labelStyle: const TextStyle(color: Colors.grey),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryGreen),
                        ),
                        hintText: "เช่น ชื่อคุณ หรืออาสา",
                        icon: const Icon(
                          Icons.person_outline,
                          color: AppColors.primaryGreen,
                        ),
                        border: isViewOnly
                            ? InputBorder.none
                            : const UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // หมายเหตุ
                    TextField(
                      controller: remarksController,
                      readOnly: isViewOnly,
                      cursorColor: AppColors.primaryGreen,
                      decoration: InputDecoration(
                        labelText: "หมายเหตุ (ถ้ามี)",
                        labelStyle: const TextStyle(color: Colors.grey),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryGreen),
                        ),
                        hintText: "เช่น มอบวัคซีนให้แล้ว...",
                        icon: const Icon(
                          Icons.note_alt_outlined,
                          color: AppColors.primaryGreen,
                        ),
                        border: isViewOnly
                            ? InputBorder.none
                            : const OutlineInputBorder(),
                      ),
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    isViewOnly ? "ปิด" : "ยกเลิก",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                if (!isViewOnly)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _submitHandover(
                        adoptionId,
                        selectedDate,
                        personController.text,
                        remarksController.text,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentCopper,
                    ),
                    child: const Text(
                      "บันทึกข้อมูล",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitHandover(
    String adoptionId,
    DateTime date,
    String person,
    String remarks,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
    );

    try {
      final url = Uri.parse("${ApiConfig.updateHandover}/$adoptionId/handover");

      final body = jsonEncode({
        "handoverDate":
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "handoverPerson": person.isEmpty ? "Owner" : person,
        "remarks": remarks,
      });

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("บันทึกการส่งมอบเรียบร้อย! 🎉"),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        }
        _fetchAdoptions();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("เกิดข้อผิดพลาด: ${response.body}"),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      print("Error handover: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }
}

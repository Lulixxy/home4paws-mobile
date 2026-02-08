import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/member.dart';
import '../models/shelter.dart';

class ApiService {
  static const baseUrl = "http://10.0.2.2:9090"; // emulator Android

  static Future<String> registerMember(Member member) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register/member"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(member.toJson()),
    );
    return response.body;
  }

  static Future<String> registerShelter(Shelter shelter) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register/shelter"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(shelter.toJson()),
    );
    return response.body;
  }
}

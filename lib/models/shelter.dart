class Shelter {
  final String username;
  final String password;
  final String email;
  final String phoneNumber;
  final String memberType;
  final String address;
  final String profilePicture;

  // Shelter-specific fields
  final String shelterName;
  final String registrationNumber;

  Shelter({
    required this.username,
    required this.password,
    required this.email,
    required this.phoneNumber,
    this.memberType =
        "Shelter", // ตั้งค่า Default ให้ตรงกับที่หลังบ้านคาดหวัง (เช็คว่าหลังบ้านใช้ตัวใหญ่หรือตัวเล็ก)
    required this.address,
    required this.profilePicture,
    required this.shelterName,
    required this.registrationNumber,
  });

  // 📤 1. toJson: ส่งข้อมูลไป Server (ตอนลงทะเบียน)
  Map<String, dynamic> toJson() => {
    "username": username,
    "password": password,
    "email": email,
    "phoneNumber": phoneNumber,
    "memberType": memberType,
    "address": address,
    "profilePicture": profilePicture,
    "shelterName": shelterName,
    "registrationNumber": registrationNumber,
  };

  // 📥 2. fromJson: รับข้อมูลจาก Server (ตอนดู/แก้ไขโปรไฟล์)
  factory Shelter.fromJson(Map<String, dynamic> json) {
    return Shelter(
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      memberType: json['memberType'] ?? 'Shelter',
      address: json['address'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      shelterName: json['shelterName'] ?? '',
      registrationNumber: json['registrationNumber'] ?? '',
    );
  }
}

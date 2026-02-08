class Member {
  final String username;
  final String password;
  final String email;
  final String phoneNumber;
  final String memberType;
  final String address;
  final String profilePicture;

  // Member-specific fields
  final String firstName;
  final String lastName;
  final String gender;
  final String age;
  final String dateOfBirth;
  final String province;
  final String district;
  final String subDistrict;
  final String postalCode;
  final String addressType;
  final double income;

  Member({
    required this.username,
    required this.password,
    required this.email,
    required this.phoneNumber,
    this.memberType = "Member", // ค่า Default
    required this.address,
    required this.profilePicture,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.age,
    required this.dateOfBirth,
    required this.province,
    required this.district,
    required this.subDistrict,
    required this.postalCode,
    required this.addressType,
    required this.income,
  });

  // 📤 1. toJson: ส่งข้อมูลไป Server (ตอนสมัครสมาชิก)
  Map<String, dynamic> toJson() => {
    "username": username,
    "password": password,
    "email": email,
    "phoneNumber": phoneNumber,
    "memberType": memberType,
    "address": address,
    "profilePicture": profilePicture,
    "firstName": firstName,
    "lastName": lastName,
    "gender": gender,
    "age": age,
    "dateOfBirth": dateOfBirth,
    "province": province,
    "district": district,
    "subDistrict": subDistrict,
    "postalCode": postalCode,
    "addressType": addressType,
    "income": income,
  };

  // 📥 2. fromJson: รับข้อมูลจาก Server (ตอนดูโปรไฟล์)
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      username: json['username'] ?? '',
      password:
          json['password'] ?? '', // ปกติ Server มักจะไม่ส่ง password กลับมา
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      memberType: json['memberType'] ?? 'Member',
      address: json['address'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age']?.toString() ?? '0', // แปลงเป็น String กันเหนียว
      dateOfBirth: json['dateOfBirth'] ?? '',
      province: json['province'] ?? '',
      district: json['district'] ?? '',
      subDistrict: json['subDistrict'] ?? '',
      postalCode: json['postalCode'] ?? '',
      addressType: json['addressType'] ?? '',
      income: (json['income'] ?? 0).toDouble(), // แปลงเป็น double
    );
  }
}

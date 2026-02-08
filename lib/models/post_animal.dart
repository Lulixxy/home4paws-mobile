class PostAnimal {
  final String animalId;
  final String username;
  final String animalName;
  final String animalType;
  final String breed;
  final int age;
  final String gender;
  final String personality;
  final String location;
  final String animalImage;
  final String animalStatus;
  final bool appropriate;

  PostAnimal({
    required this.animalId,
    required this.username,
    required this.animalName,
    required this.animalType,
    required this.breed,
    required this.age,
    required this.gender,
    required this.personality,
    required this.location,
    required this.animalImage,
    required this.animalStatus,
    required this.appropriate,
  });

  factory PostAnimal.fromJson(Map<String, dynamic> json) {
    return PostAnimal(
      animalId: json['animalId']?.toString() ?? "",
      username: json['username']?.toString() ?? "",
      animalName: json['animalName'] ?? "",
      animalType: json['animalType'] ?? "",
      breed: json['breed'] ?? "",
      age: json['age'] is int
          ? json['age']
          : int.tryParse(json['age'].toString()) ?? 0,
      gender: json['gender'] ?? "",
      personality: json['personality'] ?? "",
      location: json['location'] ?? "",
      animalImage: json['animalImage'] ?? "",
      animalStatus: json['animalStatus'] ?? "Available",
      appropriate: json['appropriate'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // เวลาส่งกลับไปหลังบ้าน ก็ต้องใช้ Key ให้ตรงกับ Java เช่นกัน
      "animalId": animalId,
      "username": username,
      "animalName": animalName,
      "animalType": animalType,
      "breed": breed,
      "age": age,
      "gender": gender,
      "personality": personality,
      "location": location,
      "animalImage": animalImage,
      "animalStatus": animalStatus,
      "appropriate": appropriate,
    };
  }
}

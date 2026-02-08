class ApiConfig {
  // เวลาเปลี่ยน WiFi มาแก้เลข IP ตรงนี้ที่เดียวจบ!
  static const String myIp = "172.20.10.2"; // ใส่เลข IPv4 ที่ได้จาก ipconfig
  static const String port = "9090";

  // Base URL (ไม่ต้องแก้)
  static const String baseUrl = "http://$myIp:$port";

  // Endpoints (ลิ้งค์ย่อยๆ)
  static const String login = "$baseUrl/user/login";
  static const String postAdd = "$baseUrl/posts/add";
  static const String allAvailable = "$baseUrl/posts/allAvailable";
  static const String registerMember = "$baseUrl/user/register/member";
  static const String registerShelter = "$baseUrl/user/register/shelter";
  static const String search = "$baseUrl/posts/search";
  static const String listPostByUser = "$baseUrl/posts/list"; // + /{username}
  static const String editPost = "$baseUrl/posts/edit"; // + /{id}
  static const String deletePost = "$baseUrl/posts/delete"; // + /{id}
  static const String makeRequest = "$baseUrl/requests/make-request";
  static const String incomingRequests = "$baseUrl/requests/incoming";
  static const String approveRequest = "$baseUrl/requests";
  static const String ownerAdoptions = "$baseUrl/adoptions/from-my-posts";
  static const String updateHandover = "$baseUrl/adoptions"; // + /{id}/handover
  static const String myAdoptions = "$baseUrl/adoptions/my-adoptions";
  static const String adoptionHistory = "$baseUrl/adoptions/my-history";
  static const String wellbeingList = "$baseUrl/well-being/list";
  static const String wellbeingAdd = "$baseUrl/well-being/add";
  static const String addReview = "$baseUrl/review/add";
  static const String notificationList = "$baseUrl/notifications/my-list";
  static const String notificationRead = "$baseUrl/notifications";
}

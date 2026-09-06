class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String image;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.image,
  });

  // LOGIC GHÉP CHUỖI NẰM Ở ĐÂY: Tạo một getter để UI gọi cho tiện
  String get fullName => "$firstName $lastName".trim();

  // LOGIC CHECK NULL NẰM Ở ĐÂY: Chuyển từ Map (JSON) sang Object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'] ?? 'https://dummyjson.com/icon/emilys/128', // Ảnh mặc định
    );
  }
}
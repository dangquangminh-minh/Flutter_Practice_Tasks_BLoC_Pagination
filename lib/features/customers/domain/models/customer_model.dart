class Customer {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String image; // avarta
  final String role;  // 
  final String companyTitle; 
  final String addressCity; 

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.image,
    required this.role,
    required this.companyTitle,
    required this.addressCity,
  });

  String get fullName => '$firstName $lastName'; // gom họ,tên thành 1 chuỗi 

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'] ?? '',
      role: json['role'] ?? 'user',
      companyTitle: json['company'] != null ? json['company']['title'] ?? 'N/A' : 'N/A', // ktra có tồn tại k trc khi truy xuất vào thuộc tính con
      addressCity: json['address'] != null ? json['address']['city'] ?? 'N/A' : 'N/A',
    );
  }
}
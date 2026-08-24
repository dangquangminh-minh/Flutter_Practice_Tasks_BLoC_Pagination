
class Product {
  final int id;
  final String title;
  final double price;
  final String thumbnail;
  bool isFavorite; // biến cho phần yêu thích của bonus

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.thumbnail,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: json['price']?.toDouble() ?? 0.0,
      thumbnail: json['thumbnail'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'thumbnail': thumbnail,
    };
  }
}

// các lỗi
class ClientException implements Exception {} // lỗi 400, 401, 403, 404 (K retry)
class ServerException implements Exception {} // lỗi 500+ (có retry)
class NetworkException implements Exception {} // rớt mạng, Timeout (có retry)
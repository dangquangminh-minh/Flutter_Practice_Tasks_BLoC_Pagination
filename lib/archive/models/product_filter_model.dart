// task 5
// model Sản phẩm
class Product {
  final int id;
  final String title;
  final double price;
  final String thumbnail;
  final String category;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.thumbnail,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: json['price']?.toDouble() ?? 0.0,
      thumbnail: json['thumbnail'] ?? '',
      category: json['category'] ?? '',
    );
  }
}

//model Truy vấn 
class QueryModel {
  final String keyword;
  final String category;
  final String sortOrder; 
  final int limit;
  final int skip;

  const QueryModel({
    this.keyword = '',
    this.category = '',
    this.sortOrder = '',
    this.limit = 10,
    this.skip = 0,
  });

  // hàm copyWith để dễ dàng thay đổi 1 tham số mà giữ nguyên các tham số khác
  QueryModel copyWith({
    String? keyword,
    String? category,
    String? sortOrder,
    int? limit,
    int? skip,
  }) {
    return QueryModel(
      keyword: keyword ?? this.keyword,
      category: category ?? this.category,
      sortOrder: sortOrder ?? this.sortOrder,
      limit: limit ?? this.limit,
      skip: skip ?? this.skip,
    );
  }
}
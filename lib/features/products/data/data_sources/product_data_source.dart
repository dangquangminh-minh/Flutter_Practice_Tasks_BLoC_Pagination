import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
class ProductService {
  final Dio _dio = Dio();

  // hàm lấy dssp
  Future<List<dynamic>?> getProducts() async {
    try {
      final response = await _dio.get('https://dummyjson.com/products');

      if (response.statusCode == 200) {
        
        return response.data['products']; 
      }
      return null;
    } catch (e) {
      debugPrint('Lỗi lấy danh sách sản phẩm: $e');
      return null;
    }
  }
}
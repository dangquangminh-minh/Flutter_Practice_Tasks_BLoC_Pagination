
import 'package:bai_01/features/carts/domain/models/cart_model.dart';
import 'package:dio/dio.dart';

class CartRemoteDataSource {
  final Dio dio = Dio();

  CartRemoteDataSource();

  // lấy ds giỏ theo id của khách
  Future<List<CartModel>> getCartsByUser(int userId) async {
    try {
      final response = await dio.get('https://dummyjson.com/carts/user/$userId');
      final data = response.data['carts'] as List;
      return data.map((json) => CartModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải giỏ hàng: $e');
    }
  }

  // update slg item 
  Future<CartModel> updateCart(int cartId, List<Map<String, dynamic>> products) async {
    try {
      final response = await dio.put(
        'https://dummyjson.com/carts/$cartId',
        data: {
          'merge': false,
          'products': products,
        },
      );
      return CartModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật giỏ hàng: $e');
    }
  }

  // Tạo giỏ hàng mới
  Future<CartModel> addCart(int userId, List<Map<String, dynamic>> products) async {
    try {
      final response = await dio.post(
        'https://dummyjson.com/carts/add',
        data: {
          'userId': userId,
          'products': products,
        },
      );
      return CartModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi tạo giỏ hàng mới: $e');
    }
  }
}
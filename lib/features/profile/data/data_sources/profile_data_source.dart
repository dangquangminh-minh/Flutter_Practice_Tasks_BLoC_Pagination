import 'package:dio/dio.dart';

class ProfileService {
  // Tạo 1 biến Dio dùng chung cho cả class
  final Dio _dio = Dio();

  // --- API CẬP NHẬT THÔNG TIN CÁ NHÂN ---
  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    try {
      final response = await _dio.put(
        'https://dummyjson.com/users/$userId',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
        },
      );

      if (response.statusCode == 200) {
        // Trả về dữ liệu mới lấy từ Server
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Lỗi server: Code ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // --- API ĐỔI MẬT KHẨU ---
  Future<bool> changePassword({
    required int userId,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.put(
        'https://dummyjson.com/users/$userId',
        data: {
          'password': newPassword,
        },
      );
      
      // Trả về true nếu thành công (mã 200)
      return response.statusCode == 200;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
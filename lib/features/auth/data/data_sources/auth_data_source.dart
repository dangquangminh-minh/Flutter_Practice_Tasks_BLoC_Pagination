
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
//import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // dùng secure_storage thay vì shared
class AuthService {
  final Dio _dio = Dio();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

//dùng splash để đưa ng dùng dô trang sp hay trag login sau hi họ đăng nhập
Future<bool> hasToken() async { // ktra coi ng dùng đã đnhap chưa dựa trên có token hay 0
    try {
      final token = await _storage.read(key: 'accessToken');
      return token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('Lỗi đọc token: $e');
      return false;
    }
  }


  // api đăng nhập
  Future<bool> loginAPI(String username, String password) async {
    try {
      final response = await _dio.post(
        'https://dummyjson.com/auth/login',
        data: {
          'username': username, //lấy dl từ ô nhập liệu
          'password': password,
          'expiresInMins': 60, // token hết hạn trog 60p
        },
      );

      // nếu server trả về 200 thì ok
      if (response.statusCode == 200) {

       // final token = response.data['token']; 
        final token = response.data['accessToken']; // trả về accesstoken đúng vs api 
        
        // dùng  secure storage để lưu thay vì dùng shared
        await _storage.write(key: 'accessToken', value: token);
        debugPrint('Đăng nhập thành công! Đã lưu Token an toàn.');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Lỗi đăng nhập: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getProfile() async { // lấy tt user hiện tại đăng nhập qua token
    try {
      // lấy token đã lưu
      final token = await _storage.read(key: 'accessToken');

      if (token == null) {
        debugPrint('Không tìm thấy token!');
        return null;
      }

      // lấy khóa và đưa thông tin lên server của user đăng nhập
      final response = await _dio.get(
        'https://dummyjson.com/auth/me',
        options: Options(
          headers: {  // kèm token dô đây để đưa lên server so sánh 
            'Authorization': 'Bearer $token', 
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data; // trả  về thông tin đầy đủ của user
      }
      return null;
    } catch (e) {
      debugPrint('Lỗi lấy thông tin User: $e');
      return null;
    }
  }

  // hàm đăng xuất
  Future<void> logout() async {
    try {
      // xóa khóa ra khỏi nơi lưu
      await _storage.delete(key: 'accessToken');
      debugPrint('Đã xóa Token, đăng xuất thành công!');
    } catch (e) {
      debugPrint('Lỗi khi đăng xuất: $e');
    }
  }

  // 4. Hàm Đăng ký 
  Future<bool> registerAPI({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        'https://dummyjson.com/users/add',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'username': username,
          'email': email,
          'password': password,
        },
      );

      // 201 là tạo thành công 
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Đăng ký thành công User: ${response.data['username']}');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Lỗi đăng ký: $e');
      return false;
    }
  }
}
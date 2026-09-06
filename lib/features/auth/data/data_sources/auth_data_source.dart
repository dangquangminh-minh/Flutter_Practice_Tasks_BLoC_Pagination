
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
//import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // dùng secure_storage thay vì shared
class AuthService {
  final Dio _dio = Dio();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) async {
          // ktra có pk lỗi 401 k , ktra api lỗi đó không pk là api /auth/refresh để tránh api refresh cx bị 401 mà gọi lại chính nó thì sẽ lặp vô tận
          if (e.response?.statusCode == 401 && !e.requestOptions.path.contains('/auth/refresh')) {
            debugPrint('Token hết hạn! Đang tự động xin Token mới...');
            
            // gọi hàm xin token mới 
            bool isRefreshed = await refreshSession();
            
            if (isRefreshed) {
              //lấy cái token mới ra
              final newToken = await _storage.read(key: 'accessToken');
              
              // gắn token mới này lên cái token cũ hết hạn vừa báo lỗi 
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              
              try {
                // gọi lại api lấy thông tin 
                debugPrint('Đã có Token mới, đang thử gọi lại API lấy Profile...');
                final retryResponse = await _dio.fetch(e.requestOptions);
                
                // trả kq lên ui 
                return handler.resolve(retryResponse);
              } catch (retryError) {              
                return handler.next(e);
              }
            }
          }         
          return handler.next(e);
        },
      ),
    );
  }

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
          'expiresInMins': 1, // token hết hạn trog 60p
        },
      );

      // nếu server trả về 200 thì ok
      if (response.statusCode == 200) {

       // final token = response.data['token']; 
        final token = response.data['accessToken']; // trả về accesstoken đúng vs api 
        final refreshToken = response.data['refreshToken'];
        
        // dùng  secure storage để lưu thay vì dùng shared
        await _storage.write(key: 'accessToken', value: token);
        await _storage.write(key: 'refreshToken', value: refreshToken);

        debugPrint('Đăng nhập thành công! Đã lưu Token an toàn.');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Lỗi đăng nhập: $e');
      return false;
    }
  }

  Future<bool> refreshSession() async {
    try {
      // lấy cái refreshtoken đã đc lưu ra
      final refreshToken = await _storage.read(key: 'refreshToken');
      
      if (refreshToken == null) {
        debugPrint('Không tìm thấy refreshToken, user cần đăng nhập lại');
        return false;
      }

      // mang nó đi đổi với cái có token mới
      final response = await _dio.post(
        'https://dummyjson.com/auth/refresh',
        data: {
          'refreshToken': refreshToken,
          'expiresInMins': 60, // xin token mới h.động thêm 60p nữa
        },
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];

        // sau khi ok thì cất token mới này dô lại nơi lưu trữ
        await _storage.write(key: 'accessToken', value: newAccessToken);
        await _storage.write(key: 'refreshToken', value: newRefreshToken);
        
        debugPrint('Refresh Session thành công!');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Lỗi Refresh Session: $e');
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

  // hàm đăng kí 
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
        debugPrint('Đăng ký thành công User: ${response.data['username']}');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Lỗi đăng ký: $e');
      return false;
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://dummyjson.com/users/filter',
        queryParameters: {
          'key': 'email',
          'value': email,
        },
      );

      final data = response.data;
      final users = data['users'] as List;

      // trả về true if tìm thấy email và ngc lại
      return users.isNotEmpty; 
      
    } catch (e) {
      //ném lỗi ra khi mất mạng
      throw Exception('Lỗi kết nối máy chủ API'); 
    }
  }
}
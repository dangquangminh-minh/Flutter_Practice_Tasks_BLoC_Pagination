import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/model_6.dart';

class RemoteDataSource {
  Future<List<Product>> fetchProducts(int skip, int limit) async {
    final url = Uri.parse('https://dummyjson.com/products?limit=$limit&skip=$skip');
    
    const int maxRetries = 3;
    final List<int> backoffDelays = [1000, 2000, 4000]; //đợi 1s, 2s, 4s
    // bài 5 là cứ mạng rớt là báo lỗi
    // bài 6 dùng vòng lặp chạy 3l để gọi lại , nếu sau 3l mà thất bại thì mới throw netwworkexception
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        // rút ngắn timeout xuống 3s để test cho lẹ
        final response = await http.get(url).timeout(const Duration(seconds: 3));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = json.decode(response.body);
          final List list = data['products'];
          return list.map((e) => Product.fromJson(e)).toList();
        } 
        else if (response.statusCode >= 400 && response.statusCode < 500) { //link api sai or lỗi , throw ra liền tránh treo app
          throw ClientException();
        } else {
          throw ServerException(); //  lỗi 500 server quá tải
        }

      } catch (e) {
        // Nếu là lỗi 400, 404... thì văng luôn không thử lại
        if (e is ClientException) rethrow;

        // BẤT KỂ LÀ LỖI GÌ (SocketException, Timeout...), ném hết về NetworkException
        if (attempt == maxRetries) {
          print('🔴 Đã thử đủ 3 lần nhưng rớt mạng!');
          throw NetworkException(); 
        }

        print('🟡 Mạng chập chờn. Đang Retry lần ${attempt + 1}...');
        await Future.delayed(Duration(milliseconds: backoffDelays[attempt]));
      }
    }
    
    throw NetworkException();
  }
}
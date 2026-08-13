import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/post.dart';

// múc dữ liệu thô Json từ trên mạng (API trong file) và đi qua Post.fromjson
class PostRepository {
 
 
  Future<List<Post>> fetchPosts({int page=1,int limit=10}) async {
    try {
      //Api được anh cung cấp trong tài liệu
       final String apiUrl = 'https://jsonplaceholder.typicode.com/posts?_page=$page&_limit=$limit';

      final response = await http.get(Uri.parse(apiUrl));

      // 200: yêu cầu hợp lệ => trả dl.
      // 404: sai đường link api.
      // 401/403: không có quyền truy cập
      // 500: máy chủ bị sập
      if (response.statusCode == 200) {
        // Decode body của response từ String sang List
        
        List<dynamic> data = json.decode(response.body);
        
        // Map List<dynamic> thành List<Post>
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra mạng.');
    }
  }
}
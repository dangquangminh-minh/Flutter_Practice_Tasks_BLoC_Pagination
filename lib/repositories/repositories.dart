import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/model.dart'; 

class SearchRepository {
  Future<List<Post>> searchPosts({required String keyword, int skip = 0}) async {
    // Nếu từ khóa rỗng, có thể gọi API lấy danh sách mặc định hoặc trả về list rỗng tùy logic
    // thay skip thành page: gọi trang 2 thì bỏ qua bài ở trang 1 để hiển thị ds trang 2
    final url = Uri.parse('https://dummyjson.com/posts/search?q=$keyword&limit=10&skip=$skip');
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // DummyJSON bọc data trong key 'posts'
      final List postsJson = data['posts']; 
      return postsJson.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Lỗi tải dữ liệu tìm kiếm');
    }
  }
}
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // dùng công cụ này để lưu trữ tạm thời 
import '../../domain/models/cache_retry_model.dart';

class LocalDataSource {
  static const String _cacheKey = 'CACHED_PRODUCTS_PAGE_1';

  // lưu đè danh sách trang 1 vào máy
  //khi repo ném ds ra , nó sẽ mã hóa thành 1 chuồi văn bản json string để lưu bộ nhớ đthoại
  
  Future<void> cacheFirstPage(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = products.map((p) => p.toJson()).toList();// chuyển thành dạng tù điển map
    await prefs.setString(_cacheKey, json.encode(jsonList)); // dung encode để mã hóa thành 1 chuỗi string duy nhất thì mới có thể nhét đủ vào bnhớ sharedfreferences
  }

  // đọc danh sách từ máy lên khi rớt mạng
  // lấy chuỗi văn bản đc mã hóa trước đó dịch ngược lại thành danh sách sản phẩm đem lên ui
  Future<List<Product>?> getCachedFirstPage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey); 
    if (jsonString != null) {
      final List decoded = json.decode(jsonString); // làm ngược lại với hàm trên
      return decoded.map((e) => Product.fromJson(e)).toList();
    }
    return null;
  }
}
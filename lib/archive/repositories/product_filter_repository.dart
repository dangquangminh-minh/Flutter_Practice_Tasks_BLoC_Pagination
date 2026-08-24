import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_filter_model.dart';


class ProductRepository {
  Future<List<Product>> fetchProducts(QueryModel query) async {
    String baseUrl = 'https://dummyjson.com/products';

    // Quyết định dùng Endpoint nào dựa vào QueryModel
    if (query.keyword.isNotEmpty) { // ng dùng nhập keyword thì dùng api search
      baseUrl = '$baseUrl/search?q=${query.keyword}'; 
    } else if (query.category.isNotEmpty) {// ng dùng nhập category thì dùng api danh mục
      baseUrl = '$baseUrl/category/${query.category}?'; 
    } else {
      baseUrl = '$baseUrl?';// không tìm thì trả về tất cả sp
    }

    // cấu trúc chuẩn api: URL + ? + tham số 1 & ts2 & ts3
    // trong link api có sẵn '?' , nên khi nếu nối limit cx có ? thì lỗi
    // if link có ? rồi thi dùng & để nối limit vs skip
    String urlString = baseUrl.contains('?') && !baseUrl.endsWith('?') 
        ? '$baseUrl&' 
        : baseUrl;

    // Nối limit và skip
    urlString += 'limit=${query.limit}&skip=${query.skip}';

    // Nối Sắp xếp (Sort) nếu có
    if (query.sortOrder.isNotEmpty) {
      urlString += '&sortBy=price&order=${query.sortOrder}';
    }

    final response = await http.get(Uri.parse(urlString));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List productsJson = data['products'];
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Lỗi tải dữ liệu sản phẩm');
    }
  }

  // hàm phụ: Lấy danh sách danh mục cho menu Lọc (Filter)
  Future<List<String>> fetchCategories() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/products/categories'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      // API dummyjson mới trả về Object, nên cần map lấy trường 'slug'
      return data.map((e) => e is String ? e : e['slug'].toString()).toList();
    }
    return [];
  }
}

import 'package:dio/dio.dart';
import '../../domain/models/customer_model.dart'; 

class CustomerRemoteDataSource {
  final Dio dio = Dio();

  Future<List<Customer>> fetchCustomers(
    int skip, 
    int limit, 
    {String searchQuery = '', String? filterRole, String? sortOrder}
  ) async {
    String url = 'https://dummyjson.com/users'; 
    final Map<String, dynamic> queryParams = {'limit': limit, 'skip': skip};

   //xử lý xung đột , ưu tiên search rồi ms tới filter vì dummyjson không hỗ trợ trên cùng 1 y/c
    if (searchQuery.isNotEmpty) {
      url = 'https://dummyjson.com/users/search';
      queryParams['q'] = searchQuery;
    } else if (filterRole != null && filterRole.isNotEmpty) {
      url = 'https://dummyjson.com/users/filter';
      queryParams['key'] = 'role';
      queryParams['value'] = filterRole;
    }

    
    if (sortOrder != null && sortOrder.isNotEmpty) {
      queryParams['sortBy'] = 'firstName'; // sx theo tên
      queryParams['order'] = sortOrder; // sx theo chiều tăng giảm
    }

    //gửi y/c lên máy chủ
    final response = await dio.get(url, queryParameters: queryParams);
    if (response.statusCode == 200) {
      final List list = response.data['users']; //dio bài trc
      return list.map((e) => Customer.fromJson(e)).toList(); // dio bài trc
    }
    throw Exception('Lỗi tải danh sách khách hàng');
  }

// gọi api lấy thông tin ct của k.hàng bằng id
  Future<Customer> fetchCustomerDetail(int id) async {
    final response = await dio.get('https://dummyjson.com/users/$id');
    if (response.statusCode == 200) {
      return Customer.fromJson(response.data);
    }
    throw Exception('Không tìm thấy chi tiết');
  }
}
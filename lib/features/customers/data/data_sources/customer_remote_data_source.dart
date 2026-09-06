
import 'package:dio/dio.dart';
import '../../domain/models/customer_model.dart'; 
import 'package:bai_01/features/products/domain/models/cache_retry_model.dart'; 
import 'package:flutter/foundation.dart';

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
   // retry khi rớt mạng 
    const int maxRetries = 3;
    final List<int> backoffDelays = [1000, 2000, 4000]; 

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        //gửi y/c lên máy chủ
        final response = await dio.get(url, queryParameters: queryParams);

        if (response.statusCode == 200) {
          final List list = response.data['users']; //dio bài trc
          return list.map((e) => Customer.fromJson(e)).toList(); // dio bài trc
        } else {         
          throw ServerException(); 
        }
      } on DioException catch (dioError) {
        if (dioError.response?.statusCode != null) {
          final statusCode = dioError.response!.statusCode!;
          if (statusCode >= 400 && statusCode < 500) throw ClientException(); 
        }
        if (attempt == maxRetries) {
          debugPrint('Đã thử đủ 3 lần nhưng rớt mạng (Dio)!'); 
          throw NetworkException(); 
        }
        debugPrint('Mạng chập chờn. Đang Retry lần ${attempt + 1}...');
        await Future.delayed(Duration(milliseconds: backoffDelays[attempt])); 
      } catch (e) {
        if (e is ClientException) rethrow; 
        throw ServerException();
      }
    }
    throw NetworkException();
  }

// gọi api lấy thông tin ct của k.hàng bằng id
  Future<Customer> fetchCustomerDetail(int id) async {
    final response = await dio.get('https://dummyjson.com/users/$id');
    if (response.statusCode == 200) {
      return Customer.fromJson(response.data);
    }
    throw ServerException();
  }

  // thêm k.h
  Future<Customer> addCustomer({
    required String firstName, 
    required String lastName, 
    required String email, 
    required String role, 
    required String image
  }) async {
    final response = await dio.post('https://dummyjson.com/users/add', data: {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'image': image.isNotEmpty ? image : 'https://dummyjson.com/icon/emilys/128',
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Customer.fromJson(response.data);
    }
    throw ServerException();
  }

  // update k.h
  Future<Customer> updateCustomer({
    required int id, 
    required String firstName, 
    required String lastName, 
    required String email, 
    required String role
  }) async {
    final response = await dio.patch('https://dummyjson.com/users/$id', data: {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
    });
    if (response.statusCode == 200) {
      return Customer.fromJson(response.data);
    }
    throw ServerException();
  }

  // xóa k.h
  Future<bool> deleteCustomer(int id) async {
    final response = await dio.delete('https://dummyjson.com/users/$id');
    if (response.statusCode == 200) {
      return true;
    }
    throw ServerException();
  }
}
import 'dart:async';
import '../../domain/models/cache_retry_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
class RemoteDataSource {
  final Dio dio = Dio(); 
  
  Future<List<Product>> fetchProducts(
    int skip, 
    int limit, {
    String searchQuery = '',
    String? selectedCategory,
    String? sortOrder,
  }) async {
    
    // url theo bộ lọc
    String baseUrl = 'https://dummyjson.com/products';
    
    if (searchQuery.isNotEmpty) {
      baseUrl = 'https://dummyjson.com/products/search';
    } else if (selectedCategory != null && selectedCategory.isNotEmpty) {
      baseUrl = 'https://dummyjson.com/products/category/$selectedCategory';
    }

    // tham sô phân trag
    final Map<String, dynamic> queryParams = {
      'limit': limit,
      'skip': skip,
    };

    if (searchQuery.isNotEmpty) {
      queryParams['q'] = searchQuery;
    }
    
    if (sortOrder != null && sortOrder.isNotEmpty) {
       queryParams['sortBy'] = 'price'; 
       queryParams['order'] = sortOrder; 
    }


    // nếu rớt mạng thì retry 3l 
    const int maxRetries = 3;
    final List<int> backoffDelays = [1000, 2000, 4000]; // time chờ 1s 2s 4s

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        // gọi api qua dio
        final response = await dio.get(baseUrl, queryParameters: queryParams);

        if (response.statusCode == 200) {
          final List list = response.data['products'];
          return list.map((e) => Product.fromJson(e)).toList();
        } else {         
          throw ServerException(); 
        }

      } on DioException catch (dioError) {

        if (dioError.response?.statusCode != null) {
          final statusCode = dioError.response!.statusCode!;
          // không retry 
          if (statusCode >= 400 && statusCode < 500) {
            throw ClientException(); 
          }
        }
        if (attempt == maxRetries) {
          debugPrint('Đã thử đủ 3 lần nhưng rớt mạng (Dio)!'); // đủ 3l mà vẫn k đc thì ném ra luôn netwwork
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


  //api lấy danh mục sp
  Future<List<String>> fetchCategories() async {
    try {
      final response = await dio.get('https://dummyjson.com/products/categories');
      if (response.statusCode == 200) {
        
        final data = response.data;
        if (data is List) {
          // api trả về slug hoặc chuỗi nên lm cả 2
          return data.map((e) {
            if (e is Map) {
              return e['slug'].toString();
            }
            return e.toString();
          }).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Lỗi lấy danh mục: $e');
      return [];
    }
  }


  // thêm sp
  Future<Product> addProduct({required String title, required double price, required String thumbnail}) async {
    final response = await dio.post('https://dummyjson.com/products/add', data: {
      'title': title,
      'price': price,
      'thumbnail': thumbnail.isNotEmpty ? thumbnail : 'https://i.dummyjson.com/data/products/1/thumbnail.jpg',
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Product.fromJson(response.data);
    }
    throw ServerException();
  }

  // update sp
  Future<Product> updateProduct({required int id, required String title, required double price}) async {
    final response = await dio.patch('https://dummyjson.com/products/$id', data: {
      'title': title,
      'price': price,
    });
    if (response.statusCode == 200) {
      return Product.fromJson(response.data);
    }
    throw ServerException();
  }

  // xóa sp
  Future<bool> deleteProduct(int id) async {
    final response = await dio.delete('https://dummyjson.com/products/$id');
    if (response.statusCode == 200) {
      return true;
    }
    throw ServerException();
  }






}
import '../../domain/models/customer_model.dart';
import '../data_sources/customer_remote_data_source.dart';
import '../data_sources/customer_local_data_source.dart'; 
import 'package:bai_01/features/products/domain/models/cache_retry_model.dart';

class CustomerRepository {

  final CustomerRemoteDataSource remoteDataSource;
  final CustomerLocalDataSource localDataSource;

  CustomerRepository({
    required this.remoteDataSource,
    required this.localDataSource, //truyền vào local
  });


  Future<({List<Customer> data, bool isOffline})> getCustomers(
    int skip, 
    int limit, 
    {String searchQuery = '', String? filterRole, String? sortOrder}
  ) async {
    
    // chỉ lưu cache khi tải trag đầu và kh có lọc hay tìm
    if (skip == 0 && searchQuery.isEmpty && (filterRole == null || filterRole.isEmpty)) {
      try {          
        // Gọi API lấy dữ liệu mới nhất
        final remoteData = await remoteDataSource.fetchCustomers(
          skip, limit,
          searchQuery: searchQuery,
          filterRole: filterRole,
          sortOrder: sortOrder,
        );

        // t.công thì cất dô cache 
        await localDataSource.cacheFirstPage(remoteData);
        return (data: remoteData, isOffline: false);
      } catch (e) {
        if (e is NetworkException || e is ServerException) {
          // if rớt mạng thì lấy dl cache ra 
          final cachedData = await localDataSource.getCachedFirstPage(); 
          if (cachedData != null && cachedData.isNotEmpty) {
            return (data: cachedData, isOffline: true);
          }
        }
        rethrow;
      }
    } else { 
      // load thêm hay dùng bộ lọc thì k lưu cache
      final remoteData = await remoteDataSource.fetchCustomers(
        skip, limit,
        searchQuery: searchQuery,
        filterRole: filterRole,
        sortOrder: sortOrder,
      );
      return (data: remoteData, isOffline: false);
    }
  }

  // chi tiết k.h
  Future<Customer> getCustomerDetail(int id) async {
    return await remoteDataSource.fetchCustomerDetail(id);
  }

  // thêm k.h 
  Future<Customer> addCustomer({
    required String firstName, required String lastName, required String email, required String role, required String image
  }) async {
    // gọi api
    final newCustomer = await remoteDataSource.addCustomer(
      firstName: firstName, lastName: lastName, email: email, role: role, image: image
    );
    
    // lấy đc ds thì mới lưu dô
    final cachedData = await localDataSource.getCachedFirstPage();
    if (cachedData != null) {
      final updatedList = List<Customer>.from(cachedData)..insert(0, newCustomer);
      await localDataSource.cacheFirstPage(updatedList); 
    }
    
    return newCustomer;
  }

  // update khách
  Future<Customer> updateCustomer({
    required int id, required String firstName, required String lastName, required String email, required String role
  }) async {
    final updatedCustomer = await remoteDataSource.updateCustomer(
      id: id, firstName: firstName, lastName: lastName, email: email, role: role
    );
    
    final cachedData = await localDataSource.getCachedFirstPage();
    if (cachedData != null) {
      final updatedList = cachedData.map((item) {
        return item.id == id ? updatedCustomer : item;
      }).toList();
      await localDataSource.cacheFirstPage(updatedList); 
    }
    
    return updatedCustomer;
  }

  // xóa k.h
  Future<bool> deleteCustomer(int id) async {
    final isSuccess = await remoteDataSource.deleteCustomer(id);
    if (isSuccess) {
      final cachedData = await localDataSource.getCachedFirstPage();
      if (cachedData != null) {
        final updatedList = cachedData.where((item) => item.id != id).toList();
        await localDataSource.cacheFirstPage(updatedList);
      }
    }
    return isSuccess;
  }
}
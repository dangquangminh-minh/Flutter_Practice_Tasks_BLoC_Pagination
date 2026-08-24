import '../../domain/models/customer_model.dart';
import '../data_sources/customer_remote_data_source.dart';

class CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;

  CustomerRepository({required this.remoteDataSource});

//chuyển y/c lấy dskh từ bloc xuống data
  Future<List<Customer>> getCustomers(
    int skip, 
    int limit, 
    {String searchQuery = '', String? filterRole, String? sortOrder}
  ) =>
      remoteDataSource.fetchCustomers(
        skip, 
        limit, 
        searchQuery: searchQuery, 
        filterRole: filterRole, 
        sortOrder: sortOrder
      );

 // chuyển y/c ctkh
  Future<Customer> getCustomerDetail(int id) async {
    return await remoteDataSource.fetchCustomerDetail(id);
  }
}
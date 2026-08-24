import '../../domain/models/cache_retry_model.dart';
import '../data_sources/local_data_source.dart';
import '../data_sources/remote_data_source.dart';

class ProductRepository6 {
  final LocalDataSource localDataSource;
  final RemoteDataSource remoteDataSource;

  ProductRepository6({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  Future<({List<Product> data, bool isOffline})> getProducts(
    int skip, 
    int limit, {
    String searchQuery = '',
    String? selectedCategory,
    String? sortOrder,
  }) async {
    
    // chỉ lưu cache khi tải trag đầu,k có từ hóa tìm kiếm ,và k có lọc danh mục

    if (skip == 0 && searchQuery.isEmpty && selectedCategory == null) {
      try {
        // gọi api lấy dl mới nhất
        final remoteData = await remoteDataSource.fetchProducts(
          skip, limit,
          searchQuery: searchQuery,
          selectedCategory: selectedCategory,
          sortOrder: sortOrder,
        );

        // nếu t.công thì lưu dô local để mốt rớt mạng thì vẫn có
        await localDataSource.cacheFirstPage(remoteData);
        return (data: remoteData, isOffline: false);
      } catch (e) {
        // if rớt mạng hay sập
        if (e is NetworkException || e is ServerException) {
          //lấy dl cache ra xài
          final cachedData = await localDataSource.getCachedFirstPage(); 
          if (cachedData != null && cachedData.isNotEmpty) {
            //và bật offline
            return (data: cachedData, isOffline: true);
          }
        }
        rethrow;
      }
    } else { // khi k cache
      // khi load thêm  hoặc đang dùng bộ lọc, bỏ qua local cache
      final remoteData = await remoteDataSource.fetchProducts(
        skip, limit,
        searchQuery: searchQuery,
        selectedCategory: selectedCategory,
        sortOrder: sortOrder,
      );
      return (data: remoteData, isOffline: false);
    }
  }

  Future<List<String>> getCategories() async {
    return await remoteDataSource.fetchCategories();
  }


  Future<Product> addProduct({required String title, required double price, required String thumbnail}) async {
    return await remoteDataSource.addProduct(title: title, price: price, thumbnail: thumbnail);
  }

  Future<Product> updateProduct({required int id, required String title, required double price}) async {
    return await remoteDataSource.updateProduct(id: id, title: title, price: price);
  }

  Future<bool> deleteProduct(int id) async {
    return await remoteDataSource.deleteProduct(id);
  }
}
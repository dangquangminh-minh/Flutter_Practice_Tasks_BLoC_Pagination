import '../models/model_6.dart';
import '../data_sources/local_data_source.dart';
import '../data_sources/remote_data_source.dart';

class ProductRepository6 {
  final LocalDataSource localDataSource;
  final RemoteDataSource remoteDataSource;

  ProductRepository6({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  
  Future<({List<Product> data, bool isOffline})> getProducts(int skip, int limit) async {
    if (skip == 0) { // lần đầu tiên mở app , trang đầu
      try {
        final remoteData = await remoteDataSource.fetchProducts(skip, limit);
        await localDataSource.cacheFirstPage(remoteData); // cất dl trang đầu dô đthoai
        return (data: remoteData, isOffline: false); // Trả về kèm cờ isOffline = false
      } catch (e) {
        if (e is NetworkException || e is ServerException) {
          final cachedData = await localDataSource.getCachedFirstPage(); 
          if (cachedData != null && cachedData.isNotEmpty) {
            return (data: cachedData, isOffline: true); // Trả về kèm cờ isOffline = true
          } // if bị lỗi mạng or server mà ktra cachedata có dl thì hiện thông báo offline lên ui
        }
        rethrow;// nào mà ds rỗng thì mới ném lỗi
      }
    } else { // if skip>0 thì khỏi cần đưa dô localdata 
      final remoteData = await remoteDataSource.fetchProducts(skip, limit);
      return (data: remoteData, isOffline: false);
    }
  }
}
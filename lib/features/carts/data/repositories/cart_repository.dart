
import 'package:bai_01/features/carts/domain/models/cart_model.dart';
import '../data_sources/cart_local_data_source.dart';
import '../data_sources/cart_remote_data_source.dart';

class CartRepository {
  final CartRemoteDataSource remoteDataSource;
  final CartLocalDataSource localDataSource;

  CartRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // gọi api, nếu lỗi mạng thì lấy từ cache
  Future<List<CartModel>> getCartsByUser(int userId) async {
    try {
      final carts = await remoteDataSource.getCartsByUser(userId);
      await localDataSource.saveUserCarts(userId, carts);
      return carts;
    } catch (e) {
      final cachedCarts = await localDataSource.getCachedUserCarts(userId);
      if (cachedCarts != null && cachedCarts.isNotEmpty) {
        return cachedCarts; 
      }
      throw Exception('Không có kết nối mạng. Vui lòng kiểm tra lại Wifi/4G!');
    }
  }

  Future<CartModel> updateCartApi(int cartId, List<Map<String, dynamic>> products) async {
    return await remoteDataSource.updateCart(cartId, products);
  }
  
  Future<CartModel> addProductToCartApi(int userId, List<Map<String, dynamic>> products) async {
    return await remoteDataSource.addCart(userId, products);
  }

  Future<void> saveCartsToLocal(int userId, List<CartModel> carts) async {
    await localDataSource.saveUserCarts(userId, carts);
  }
}
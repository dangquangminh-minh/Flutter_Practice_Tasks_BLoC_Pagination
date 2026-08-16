import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'event.dart';
import 'state.dart';
import '../repositories/repository_6.dart';
import '../models/model_6.dart';
import '../data_sources/remote_data_source.dart'; // để nhận diện lỗi 

class ProductBloc6 extends Bloc<ProductEvent6, ProductState6> {
  final ProductRepository6 repository;

  ProductBloc6(this.repository) : super(const ProductState6()) {
    on<FetchInitialData6>(_onFetchInitial);
    on<LoadMoreProducts6>(_onLoadMore, transformer: droppable());
    on<ToggleFavorite6>(_onToggleFavorite);
  }

  Future<void> _onFetchInitial(FetchInitialData6 event, Emitter<ProductState6> emit) async {
    emit(state.copyWith(isInitialLoading: true, initialError: ''));
    try {
      final result = await repository.getProducts(0, 10);
      emit(state.copyWith(
        isInitialLoading: false,
        products: result.data,
        isOffline: result.isOffline, // Lấy cờ Offline từ Repository
        hasReachedMax: result.data.length < 10,
      ));
    } catch (e) { 
      String errorMsg = 'Lỗi không xác định.';
      if (e is ClientException) errorMsg = 'Yêu cầu không hợp lệ (Lỗi 400).';
      else if (e is NetworkException) errorMsg = 'Mất kết nối mạng hoàn toàn.';
      
      emit(state.copyWith(isInitialLoading: false, initialError: errorMsg));
    }
  }

  Future<void> _onLoadMore(LoadMoreProducts6 event, Emitter<ProductState6> emit) async {
    if (state.isLoadingMore || state.hasReachedMax || state.isOffline) return; // Không tải thêm nếu đang offline

    emit(state.copyWith(isLoadingMore: true, loadMoreError: ''));
    try {
      final result = await repository.getProducts(state.products.length, 10);
      emit(state.copyWith(
        isLoadingMore: false,
        products: List.of(state.products)..addAll(result.data), // if mạng b thường thì dùng ds cũ để nối api ds mới 
        hasReachedMax: result.data.isEmpty,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, loadMoreError: 'Lỗi mạng khi tải thêm. Vui lòng thử lại.'));
    }
  }

// thả tim
  Future<void> _onToggleFavorite(ToggleFavorite6 event, Emitter<ProductState6> emit) async {
    // Tìm sản phẩm đang được bấm
    final targetProduct = event.product;
    final index = state.products.indexWhere((p) => p.id == targetProduct.id);
    if (index == -1) return;

    // optimistic update emit cập nhật ra trái tim đỏ liền 
    final bool currentFavStatus = targetProduct.isFavorite;
    final updatedProducts = List<Product>.from(state.products);
    
    updatedProducts[index] = Product(
      id: targetProduct.id,
      title: targetProduct.title,
      price: targetProduct.price,
      thumbnail: targetProduct.thumbnail,
      isFavorite: !currentFavStatus, // Đảo trạng thái
    );
    emit(state.copyWith(products: updatedProducts));

    // gọi api ngầm
    try {
      // Giả lập thời gian gọi API mất 1 giây
      await Future.delayed(const Duration(seconds: 1));
      
      // 
      final bool isApiFailed = DateTime.now().second % 2 == 0; 
      
      if (isApiFailed) throw Exception("Lỗi Server khi thả tim");
      // Nếu thành công thì không cần làm gì thêm vì UI đã xanh sẵn rồi

    } catch (e) {
      // rollback: if lỗi api thì lấy lại ds cũ và xóa hết phần trái tim đỏ
      final rollbackProducts = List<Product>.from(state.products);
      rollbackProducts[index] = Product(
        id: targetProduct.id,
        title: targetProduct.title,
        price: targetProduct.price,
        thumbnail: targetProduct.thumbnail,
        isFavorite: currentFavStatus, // Trả về lúc chưa bấm
      );
      
      // Trả lại state cũ và bắn lỗi ra bằng loadMoreError 
      emit(state.copyWith(
        products: rollbackProducts,
        loadMoreError: 'Lỗi hệ thống: Không thể thả tim!', 
      ));
    }
  }
}